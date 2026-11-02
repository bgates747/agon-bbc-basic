"""Package assembly bytes as BBC DATA; never parse or compile BASIC source.

The BBC compiler performs the final relocation itself. Check every relocation
and compare its action with independent GNU links at two distinct addresses.
"""

import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess

COMPILER = Path(__file__).resolve().parents[1]
ROOT = COMPILER.parent
TASK = COMPILER / "runtime"


def run(*args):
    return subprocess.check_output([str(arg) for arg in args], text=True)


def build(toolchain, source=None, output=None):
    source = (source or TASK / "expression_runtime.s").resolve(strict=True)
    output = (output or COMPILER / "build/numeric-runtime").resolve()
    output.mkdir(parents=True, exist_ok=True)
    assembler = toolchain / "ez80-none-elf-as"
    linker = toolchain / "ez80-none-elf-ld"
    obj = output / "runtime.o"
    run(assembler, "-march=ez80+full", "-I", TASK,
        f"-al={output / 'runtime.lst'}", "-o", obj, source)
    undefined = run(toolchain / "ez80-none-elf-nm", "-u", obj)
    assert not undefined.strip(), undefined
    relocations = []
    listing = run(toolchain / "ez80-none-elf-readelf", "-r", obj)
    (output / "relocations.txt").write_text(listing)
    for line in listing.splitlines():
        match = re.match(r"\s*([0-9a-f]{8})\s+[0-9a-f]{8}\s+(R_Z80_\S+)", line)
        if match:
            assert match[2] == "R_Z80_24", line
            relocations.append(int(match[1], 16))
    assert relocations and len(set(relocations)) == len(relocations)
    symbols = {}
    for line in run(toolchain / "ez80-none-elf-nm", "-n", obj).splitlines():
        fields = line.split()
        if len(fields) == 3 and fields[1] in ("t", "T"):
            symbols[fields[2]] = int(fields[0], 16)
    names = ("rt_numeric", "rt_literal", "rt_negate", "rt_printnum", "rt_val", "rt_strnum", "rt_strhex")
    exports = [symbols[name] for name in names]
    images = {}
    for base in (0, 0x41000, 0x47000):
        path = output / f"runtime-{base:x}.bin"
        run(linker, f"-Ttext=0x{base:x}", "-e", "rt_numeric", "--oformat=binary",
            "-o", path, obj)
        images[base] = path.read_bytes()
    template = images[0]
    for base in (0x41000, 0x47000):
        relocated = bytearray(template)
        for offset in relocations:
            assert 0 <= offset <= len(template) - 3
            value = int.from_bytes(template[offset:offset+3], "little")
            assert 0 <= value < len(template), (offset, value)
            relocated[offset:offset+3] = (value + base).to_bytes(3, "little")
        assert relocated == images[base], f"relocation mismatch at {base:x}"
    records = [",".join(map(str, [len(template), len(relocations), *exports]))]
    records += ['"' + template[i:i+40].hex().upper() + '"'
                for i in range(0, len(template), 40)]
    records += [",".join(map(str, relocations[i:i+20]))
                for i in range(0, len(relocations), 20)]
    data = "\n".join(f"{20000+i*10} DATA {row}" for i, row in enumerate(records)) + "\n"
    (output / "runtime_data.bas").write_text(data)
    report = {
        "bytes": len(template), "relocations": len(relocations),
        "exports": dict(zip(names, exports)),
        "independent_link_bases": [0x41000, 0x47000],
        "unresolved_symbols": 0,
        "scratch": {"val_text": {"offset": symbols["val_text"], "bytes": 256}},
        "hashes": {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
                   for p in [TASK / "numeric.s", source,
                             TASK / "vendor/MATH.Z80", TASK / "vendor/LICENSE.txt",
                             output / "runtime_data.bas", output / "runtime-0.bin"]},
    }
    (output / "runtime.json").write_text(json.dumps(report, indent=2) + "\n")
    return report


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--toolchain", type=Path,
                        default=Path("/Agon/agondev/release/bin"))
    parser.add_argument("--update-compiler", action="store_true")
    parser.add_argument("--source", type=Path)
    parser.add_argument("--output", type=Path, default=COMPILER / "build/numeric-runtime")
    parser.add_argument("--compiler", type=Path, default=COMPILER / "compiler.bas")
    args = parser.parse_args()
    report = build(args.toolchain, args.source, args.output)
    if args.update_compiler:
        compiler = args.compiler
        source, previous = compiler.read_text().split("20000 DATA", 1)
        strings = "30000 DATA" + previous.split("30000 DATA", 1)[1] if "30000 DATA" in previous else ""
        compiler.write_text(source + (args.output / "runtime_data.bas").read_text() + strings)
    print(json.dumps(report, indent=2))

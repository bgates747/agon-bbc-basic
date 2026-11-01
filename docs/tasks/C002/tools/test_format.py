"""Qualify standalone BBC formatting against actual BASIC strings and guards."""

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import shutil
import subprocess
import time

TASK = Path(__file__).resolve().parents[1]
ROOT = TASK.parents[2]


def values():
    return ["0", "1", "-1", "&7FFFFFFF", "&80000000", "16777217", "2147483648.0",
            "2147483648.0*2", "(2147483648.0*2)+3", "1/10", "-1/10", "1/3", "-1/3",
            "1E38", "-1E38", "1E-38", "-1E-38", "9.99999999", "999999999",
            "9999999999", "0.000000001", "0.0000000001", "0.9999999999", "PI",
            "SQR(2)"] + [f"10^({i})" for i in range(-38, 39, 5)] + [
                # BASIC writes exact valid packed boundaries; no host float model.
                "0:p%=^value:p%?4=1",
                "0:p%=^value:p%?3=128:p%?4=1",
                "0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=127:p%?4=255",
                "0:p%=^value:p%?0=255:p%?1=255:p%?2=255:p%?3=255:p%?4=255",
            ]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cli", required=True, type=Path)
    parser.add_argument("--runtime-dir", type=Path, default=ROOT / "compiler/runtime")
    parser.add_argument("--runtime-build", type=Path, default=ROOT / "compiler/build/numeric-runtime")
    args = parser.parse_args()
    args.runtime_dir = args.runtime_dir.resolve(strict=True)
    args.runtime_build = args.runtime_build.resolve(strict=True)
    spec = importlib.util.spec_from_file_location("harness", ROOT / "compiler/tools/test_compiler.py")
    harness = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(harness)
    profile = ROOT / ".emulator"
    assert (profile / ".compiler-tests").is_file()
    assert (profile / "fab-agon-emulator.bin").resolve() == args.cli.resolve(strict=True)
    sd = profile / "sdcard"
    build = TASK / "build/format"
    build.mkdir(parents=True, exist_ok=True)
    source = ['10 ON ERROR REPORT:PRINT:CLOSE#0:OSCLI "BYE"',
              '20 @%=&90A:ch%=OPENOUT("format.dat")']
    for i, expression in enumerate(values()):
        source += [f'{100+i*20} value={expression}:text$=STR$(value):PROCsave']
    source += ['10000 CLOSE#ch%:PRINT "FORMAT_REFERENCE_DONE":OSCLI "BYE"',
               '11000 DEF PROCsave:LOCAL i%,p%',
               '11010 p%=^value:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT',
               '11020 IF LEN(text$)>31 ERROR 100,"Format too long"',
               '11030 BPUT#ch%,LEN(text$):FOR i%=1 TO 32',
               '11040 IF i%<=LEN(text$) THEN BPUT#ch%,ASC(MID$(text$,i%,1)) ELSE BPUT#ch%,0',
               '11050 NEXT:ENDPROC']
    text = "\n".join(source)+"\n"
    (build / "reference.bas").write_text(text)
    (sd / "format-reference.bas").write_text(text)
    (sd / "format.dat").unlink(missing_ok=True)
    started = time.monotonic()
    reference = harness.run_profile(profile, "load /bin/basic.bin\nrun . /format-reference.bas\n",
                                    "FORMAT_REFERENCE_DONE", "format-reference.log")
    fixture = (sd / "format.dat").read_bytes()
    assert len(fixture) == len(values())*38
    (build / "format.dat").write_bytes(fixture)
    tc = Path("/Agon/agondev/release/bin")
    subprocess.run([str(tc / "ez80-none-elf-as"), "-march=ez80+full", "-I", str(build),
                    f'-al={build / "probe.lst"}', "-o", str(build / "probe.o"),
                    str(TASK / "output/format_probe.s")], check=True)
    subprocess.run([str(tc / "ez80-none-elf-ld"), "-Ttext=0x40000", "-e", "_start", "--oformat=binary",
                    f'-Map={build / "probe.map"}', "-o", str(build / "probe.bin"),
                    str(build / "probe.o"), str(args.runtime_build / "runtime.o")], check=True)
    symbols = subprocess.check_output([str(tc / "ez80-none-elf-nm"), str(build / "probe.o")], text=True)
    buffer = int(re.search(r"^([0-9a-f]+) [a-zA-Z] text_buffer$", symbols, re.M)[1], 16)
    assert buffer % 256 != 0, "probe must cover a non-page-aligned buffer"
    assert buffer % 256 + max(fixture[5::38]) + 1 > 256, "text must cross a page"
    shutil.copy2(build / "probe.bin", sd / "fmtprobe.bin")
    native = harness.run_profile(profile, "try /fmtprobe.bin\necho FORMAT_STATUS:<Try$ReturnCode>\n",
                                 "FORMAT_STATUS:", "format-native.log")
    assert "FORMAT_STATUS:0\n" in native
    records = re.findall(r"^F:([0-9A-F]{70})$", native, re.M)
    assert len(records) == len(values()), (len(records), native)
    for i, record in enumerate(records):
        got = bytes.fromhex(record)
        expected = fixture[i*38:(i+1)*38]
        length = expected[5]
        assert got[0] == 0 and got[1] == length and got[-1] == 0, (i, got.hex())
        assert got[2:2+length+1] == expected[6:6+length+1], (i, got, expected)
    report = dict(cases=len(values()), mismatches=0, buffer_bytes=32,
                  buffer_alignment=buffer % 256, nul_checked=True,
                  stack_index_input_canaries_checked=True,
                  duration_seconds=round(time.monotonic()-started, 3),
                  hashes={str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
                          for p in [ROOT / "bin/basic.bin", args.runtime_dir / "expression_runtime.s",
                                    args.runtime_dir / "numeric.s", build / "format.dat"]})
    (build / "results.json").write_text(json.dumps(report, indent=2)+"\n")
    (build / "reference.log").write_text(reference)
    (build / "native.log").write_text(native)
    (build / "values.json").write_text(json.dumps(values(), indent=2)+"\n")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()

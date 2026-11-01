"""Execute the BBC BASIC compiler and its native output on an eZ80 emulator.

Python only prepares fixtures and checks results; it never compiles BASIC.
The generated profile is exclusively for automated text-only tests.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import time


TASK_ROOT = Path(__file__).resolve().parents[1]
ROOT = TASK_ROOT.parent


def run_profile(profile: Path, script: str, marker: str, log_name: str,
                timeout_seconds: float = 45) -> str:
    (profile / "sdcard/autoexec.txt").write_bytes(
        script.replace("\n", "\r\n").encode("ascii")
    )
    log_path = profile / log_name
    with log_path.open("w") as log:
        process = subprocess.Popen(
            ["./fab-agon-emulator", "-u", "-z"], cwd=profile,
            stdin=subprocess.PIPE, stdout=log, stderr=subprocess.STDOUT,
        )
        try:
            deadline = time.monotonic() + timeout_seconds
            while time.monotonic() < deadline:
                output = log_path.read_text(errors="replace")
                if marker in output:
                    break
                if process.poll() is not None:
                    raise AssertionError(f"Emulator exited before {marker}: {output}")
                time.sleep(0.1)
            else:
                raise AssertionError(f"Timed out waiting for {marker}; see {log_path}")
        finally:
            process.stdin.close()
            try:
                process.wait(timeout=4)
            except subprocess.TimeoutExpired:
                process.terminate()
                try:
                    process.wait(timeout=4)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait()
    return log_path.read_text(errors="replace")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cli", required=True, type=Path)
    parser.add_argument("--compiler", type=Path, default=TASK_ROOT / "compiler.bas")
    parser.add_argument("--runtime", type=Path, default=Path.home() / "Agon/fab-agon-emulator")
    parser.add_argument("--setup", type=Path, default=Path.home() / "Agon/mystuff/agon-dev-env/scripts/setup_emulator.py")
    parser.add_argument("--assembler", type=Path, default=Path.home() / "Agon/agondev/release/bin/ez80-none-elf-as")
    parser.add_argument("--linker", type=Path, default=Path.home() / "Agon/agondev/release/bin/ez80-none-elf-ld")
    args = parser.parse_args()
    cli = args.cli.resolve(strict=True)
    profile = ROOT / ".emulator"
    if (profile / ".compiler-tests").exists() is False and profile.exists():
        raise SystemExit(f"Refusing to reuse an unmarked profile: {profile}")
    spec = importlib.util.spec_from_file_location("canonical_setup", args.setup)
    setup = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(setup)
    sdcard = setup.link_shared_runtime(profile, args.runtime.resolve())
    # Keep the canonical wrapper and MOS guards. The upstream CLI backend is
    # text-only; its parser warns about the wrapper's unused --firmware option.
    setup.replace_symlink(profile / "fab-agon-emulator.bin", cli)
    (profile / ".compiler-tests").write_text("Automated CLI qualification only\n")
    basic = ROOT / "bin/basic.bin"
    shutil.copy2(basic, sdcard / "bin/basic.bin")

    # (source bytes, exact native output, expected compilation diagnostic)
    cases = [
        (b'PRINT "ok":END\n', "ok\n", None),
        ((TASK_ROOT / "examples/hello.bas").read_bytes(),
         'Native BBC BASIC on Agon\nA quoted "hello" from ADL code\n', None),
        (b'10 PRINT "numbered"\r\n20 GOSUB 100\r\n30 END\r\n100 PRINT "sub"\r\n110 RETURN\r\n', "numbered\nsub\n", None),
        (b'GOTO @main\n@sub:PRINT "back":RETURN\n@main:GOSUB @sub:END', "back\n", None),
        (b'PRINT "";:PRINT "x";"y"\nPRINT\nEND\n', "xy\n\n", None),
        (b'PRINT "a:b";"""c""":END\n', 'a:b"c"\n', None),
        (b'VDU 65,66,&43,13,10\nREM EVAL : rubbish\nEND\n', "ABC\n", None),
        (b'GOSUB @a:PRINT "bad":END\n@a:GOSUB @b:RETURN\n@b:PRINT "unwind":END\n', "unwind\n", None),
        (b'GOSUB @a:PRINT "done":END\n@a:GOSUB @b:RETURN\n@b:PRINT "nested":RETURN\n', "nested\ndone\n", None),
        (b'\n \t\nREM nothing\n', "", None),
        (b'', "", None),
        (b'GOTO @missing\n', None, "Undefined target @missing"),
        (b'GOTO 123\n', None, "Undefined target #123"),
        (b'@a:\n@a:\n', None, "Duplicate target @a"),
        (b'10 END\n10 END\n', None, "Line numbers must increase"),
        (b'20 END\n10 END\n', None, "Line numbers must increase"),
        (b'65280 END\n', None, "Number outside supported range"),
        (b'VDU &100000000\n', None, "Hex literal exceeds eight digits"),
        (b'VDU 1.5\n', None, "Fractional literals are not yet supported"),
        (b'VDU -1E3\n', None, "Exponent literals are not yet supported"),
        (b'PRINT "unterminated\n', None, "Unterminated string"),
        (b'PRINT EVAL("1")\n', None, "EVAL is deliberately unsupported"),
        (b'EVAL("1")\n', None, "EVAL is deliberately unsupported"),
        (b'LOCAL a%\n', None, "Unsupported statement LOCAL"),
        (b'DEF PROCtest\n', None, "Unsupported statement DEF"),
        (b'a%=1\n', None, "Unsupported statement a"),
        (b'GOTO a%\n', None, "Expected an unsigned integer constant"),
        (b'GOTO @A\n@a:END\n', None, "Undefined target @A"),
        (b'@no_colon\n', None, "Expected :"),
        (b'@%:END\n', None, "Expected a name"),
        (b'@'+b'a'*33+b':END\n', None, "Name exceeds 32 characters"),
        (b'REM '+b'a'*252+b'\n', None, "Source line exceeds 255 bytes"),
        (b'REM \x00\n', None, "NUL byte in source"),
        (b'PRINT "ok" rubbish\n', None, "Unexpected text after statement"),
        (b'PRINT "a","b"\n', None, "Unexpected text after statement"),
        (b'RETURN\n', "No GOSUB\n", None),
        (b'@again:GOSUB @again\n', "Too many GOSUBs\n", None),
        (b'0 GOTO 00010\n10 PRINT "zero":END\n', "zero\n", None),
        (b'@again:GOTO @last\n@last:PRINT "labels":END\n', "labels\n", None),
    ]
    sentinel = b"existing output must survive a compilation error"
    for index, (source, _, _) in enumerate(cases):
        (sdcard / f"t{index}.bas").write_bytes(source)
        (sdcard / f"t{index}.bin").write_bytes(sentinel)
    # Compile the same input again to check re-entrancy and determinism.
    (sdcard / "repeat.bas").write_bytes(cases[0][0])
    definitions = args.compiler.read_text().split("1000 DEF", 1)[1]
    driver = [
        "10 PROCinit:RESTORE 200", "20 test%=0", "30 test%=test%+1",
        f'40 IF test%>{len(cases)+1} THEN PRINT "COMPILE_DONE":OSCLI "BYE"',
        "50 READ src$,dst$",
        '60 ON ERROR PRINT "CASE_ERR:";src$:REPORT:PRINT:CLOSE#0:GOTO 90',
        "70 PROCcompile(src$,dst$)", '80 PRINT "CASE_OK:";src$', "90 GOTO 30",
    ]
    for index in range(len(cases)):
        driver.append(f'{200+index*10} DATA "t{index}.bas","t{index}.bin"')
    driver.append(f'{200+len(cases)*10} DATA "repeat.bas","repeat.bin"')
    (sdcard / "driver.bas").write_text("\n".join(driver)+"\n1000 DEF"+definitions)
    started = time.monotonic()
    output = run_profile(profile, "load /bin/basic.bin\nrun . /driver.bas\n",
                         "COMPILE_DONE", "compile.log")
    for index, (_, _, diagnostic) in enumerate(cases):
        if diagnostic is None:
            assert f"CASE_OK:t{index}.bas\n" in output, output
            image = (sdcard / f"t{index}.bin").read_bytes()
            assert image[64:69] == b"MOS\0\1"
            assert image[0] == 0xC3 and len(image) > 100
        else:
            record = output.split(f"CASE_ERR:t{index}.bas\n", 1)[1].split("CASE_", 1)[0]
            assert diagnostic in record, record
            assert (sdcard / f"t{index}.bin").read_bytes() == sentinel
    assert (sdcard / "repeat.bin").read_bytes() == (sdcard / "t0.bin").read_bytes()

    build = TASK_ROOT / "build"
    build.mkdir(exist_ok=True)
    subprocess.run([str(args.assembler), "-march=ez80+full", "-o", str(build / "golden.o"),
                    str(TASK_ROOT / "tests/golden.s")], check=True)
    subprocess.run([str(args.linker), "-Ttext=0x40000", "-e", "0x40000", "--oformat=binary", "-o",
                    str(build / "golden.bin"), str(build / "golden.o")], check=True)
    assert (build / "golden.bin").read_bytes() == (sdcard / "t0.bin").read_bytes(), "Assembler oracle mismatch"

    script = []
    for index, (_, expected, _) in enumerate(cases):
        if expected is not None:
            script += [f"echo BEGIN_{index}", f"try /t{index}.bin",
                       f"echo STATUS_{index}:<Try$ReturnCode>", f"echo END_{index}"]
    script.append("echo NATIVE_DONE")
    native = run_profile(profile, "\n".join(script)+"\n", "NATIVE_DONE", "native.log")
    for index, (_, expected, _) in enumerate(cases):
        if expected is not None:
            record = native.split(f"BEGIN_{index}\n", 1)[1].split(f"END_{index}\n", 1)[0]
            status = 1 if index in (35, 36) else 0
            wanted = expected + f"STATUS_{index}:{status}\n"
            assert record == wanted, (index, repr(record), repr(wanted))
    report = {
        "cases": len(cases), "native_executions": sum(c[1] is not None for c in cases),
        "deterministic_repeat": True, "assembler_oracle": True,
        "duration_seconds": round(time.monotonic() - started, 3),
        "basic_sha256": hashlib.sha256(basic.read_bytes()).hexdigest(),
        "compiler_sha256": hashlib.sha256(args.compiler.read_bytes()).hexdigest(),
        "cli_sha256": hashlib.sha256(cli.read_bytes()).hexdigest(),
        "mos_sha256": hashlib.sha256((profile / "mos_platform.bin").read_bytes()).hexdigest(),
    }
    (build / "test-results.json").write_text(json.dumps(report, indent=2)+"\n")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()

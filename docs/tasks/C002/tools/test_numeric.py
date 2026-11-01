"""Compare an isolated native numeric adapter with real BBC BASIC evaluation.

Python generates test descriptions, builds the probe and compares byte records.
All input encoding, expected arithmetic and conversions are performed by BASIC.
"""
from __future__ import annotations

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
RUNTIME = ROOT / "compiler/runtime"
UNARY = dict(enumerate(["ABS", "ACS", "ASN", "ATN", "COS", "DEG", "EXP", "INT",
                        "LN", "LOG", "NOT", "RAD", "SGN", "SIN", "SQR", "TAN"], 16))
OPERATORS = ["AND", "DIV", "EOR", "MOD", "OR", "<=", "<>", ">=", "<", "=", "*", "+", ">", "-", "^", "/"]


def cases() -> list[dict]:
    pairs = [("0", "0"), ("1", "1"), ("-7", "3"), ("7", "-3"),
             ("&7FFFFFFF", "1"), ("&80000000", "-1"), ("&00FFFFFF", "1"),
             ("65536", "65536"), ("0.5", "0.25"), ("1.5", "2"),
             ("0.1", "0.2"), ("1E38", "10"), ("1E-38", "100"), ("-0.5", "0.25")]
    tests = []
    for op in range(16):
        if op != 14:
            for left, right in pairs:
                tests.append(dict(op=op, left=left, right=right, alias=0))
    for left, right in [("2", "10"), ("-2", "3"), ("0", "0"), ("-2", "0.5"),
                        ("10", "38"), ("10", "39"), ("0.25", "0.5")]:
        tests.append(dict(op=14, left=left, right=right, alias=0))
    for op in [38, 39]:
        for left in ["0", "1", "-1", "3.9", "-3.9", "&7FFFFFFF", "&80000000",
                     "2147483648.0", "1E38", "-1E38", "1E-38"]:
            tests.append(dict(op=op, left=left, right="0", alias=0))
    for op in [10, 11, 13, 15]:
        for left in ["-7", "0.1"]:
            tests.append(dict(op=op, left=left, right=left, alias=1))
    for left, right in [("16777216.0", "1"), ("2147483648.0", "1"),
                        ("2147483648.0*2", "1"), ("2147483648.0*2", "3")]:
        tests.append(dict(op=11, left=left, right=right, alias=0))
    for op in UNARY:
        for left in ["0", "1", "-1", "1/2", "-1/2", "3.9", "-3.9", "&7FFFFFFF",
                     "&80000000", "1E38", "1E-38"]:
            tests.append(dict(op=op, left=left, right="0", alias=0))
    for left in ["0", "-1", "1E38"]:
        tests.append(dict(op=35, left=left, right="0", alias=0))
    for op in [16, 23, 26, 28, 30, 35]:
        for left in ["7/2", "-1"]:
            tests.append(dict(op=op, left=left, right=left, alias=1))
    for op in [32, 33, 34, 36, 37, 40, 255]:
        tests.append(dict(op=op, left="7", right="3", alias=0))
    return tests


def reference_source(tests: list[dict]) -> str:
    lines = ['10 ON ERROR PRINT "REFERENCE_SETUP_ERROR ";ERR:REPORT:PRINT:CLOSE#0:OSCLI "BYE"',
             '20 ch%=OPENOUT("cases.dat")', '30 IF ch%=0 ERROR 100,"Cannot create cases"']
    for index, case in enumerate(tests):
        n = 100 + index * 80
        op = case["op"]
        if op < 16:
            expr = f'result=left {OPERATORS[op]} right'
        elif op in UNARY:
            expr = f'result={UNARY[op]}(left)'
        elif op == 35:
            expr = 'result=PI'
        elif op == 38:
            expr = 'converted%=left:result=converted%'
        elif op == 39:
            expr = 'result=left/1'
        else:
            expr = 'status%=1:result=left'
        statements = [f'left={case["left"]}:right={case["right"]}',
                      f'opcode%={op}:alias%={case["alias"]}', 'PROCinputs', 'status%=0',
                      f'ON ERROR status%=ERR:PROCfinish:GOTO {n+80}', expr,
                      'PROCfinish', f'REM case {index} complete']
        lines += [f'{n+j*10} {s}' for j, s in enumerate(statements)]
    lines += [f'{100+len(tests)*80} CLOSE#ch%:PRINT "REFERENCE_DONE":OSCLI "BYE"',
              '50000 DEF PROCinputs', '50010 LOCAL i%,p%',
              '50020 BPUT#ch%,opcode%:BPUT#ch%,alias%',
              '50030 p%=^left:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT',
              '50040 p%=^right:FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT', '50050 ENDPROC',
              '50100 DEF PROCfinish', '50110 LOCAL i%,p%', '50120 BPUT#ch%,status%',
              '50130 IF status%=0 THEN p%=^result ELSE p%=^left',
              '50140 FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT', '50150 ENDPROC']
    return "\n".join(lines)+"\n"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cli", required=True, type=Path)
    parser.add_argument("--toolchain", type=Path, default=Path.home()/"Agon/agondev/release/bin")
    args = parser.parse_args()
    cli = args.cli.resolve(strict=True)
    # Reuse the promoted compiler's canonical-profile orchestration.
    spec = importlib.util.spec_from_file_location("compiler_tests", ROOT/"compiler/tools/test_compiler.py")
    harness = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(harness)
    profile = ROOT/".emulator"
    if not (profile/".compiler-tests").is_file():
        raise SystemExit("Run compiler/tools/test_compiler.py first to provision the canonical profile")
    if (profile/"fab-agon-emulator.bin").resolve() != cli:
        raise SystemExit("Profile CLI differs from --cli; reprovision with the compiler test runner")
    sdcard = profile/"sdcard"
    build = TASK/"build"
    build.mkdir(parents=True, exist_ok=True)
    tests = cases()
    source = reference_source(tests)
    (build/"reference.bas").write_text(source)
    (sdcard/"reference.bas").write_text(source)
    (sdcard/"cases.dat").unlink(missing_ok=True)
    started = time.monotonic()
    reference_log = harness.run_profile(profile, "load /bin/basic.bin\nrun . /reference.bas\n",
                                        "REFERENCE_DONE", "numeric-reference.log")
    fixture = (sdcard/"cases.dat").read_bytes()
    assert len(fixture) == len(tests)*18, (len(fixture), len(tests)*18)
    # Independent byte anchors for 32-bit significand precision and tie rounding.
    anchors = {("16777216.0", "1"): "8000000098",
               ("2147483648.0", "1"): "010000009f",
               ("2147483648.0*2", "1"): "01000000a0",
               ("2147483648.0*2", "3"): "01000000a0"}
    for index, case in enumerate(tests):
        key = (case['left'], case['right'])
        if case['op'] == 11 and key in anchors:
            assert fixture[index*18+12:index*18+18] == b'\0'+bytes.fromhex(anchors[key]), case
    (build/"cases.dat").write_bytes(fixture)
    assembler = args.toolchain/"ez80-none-elf-as"
    linker = args.toolchain/"ez80-none-elf-ld"
    for name in ["numeric", "probe"]:
        subprocess.run([str(assembler), "-march=ez80+full", "-I", str(RUNTIME), "-I", str(build),
                        f'-al={build/name}.lst', "-o", str(build/f"{name}.o"),
                        str((RUNTIME if name == "numeric" else TASK)/f"{name}.s")], check=True)
    undefined = subprocess.run([str(args.toolchain/"ez80-none-elf-nm"), "-u", str(build/"numeric.o")],
                               check=True, capture_output=True, text=True).stdout
    assert not undefined.strip(), undefined
    subprocess.run([str(linker), "-Ttext=0x40000", "-e", "_start", "--oformat=binary",
                    f'-Map={build/"probe.map"}', "-o", str(build/"probe.bin"),
                    str(build/"probe.o"), str(build/"numeric.o")], check=True)
    shutil.copy2(build/"probe.bin", sdcard/"numprobe.bin")
    native_log = harness.run_profile(profile, "try /numprobe.bin\necho PROBE_STATUS:<Try$ReturnCode>\n",
                                     "PROBE_STATUS:", "numeric-native.log")
    assert "PROBE_STATUS:0\n" in native_log, native_log
    records = re.findall(r'^R:([0-9A-F]{14})$', native_log, re.MULTILINE)
    assert len(records) == len(tests), (len(records), len(tests), native_log)
    failures = []
    for index, (case, record) in enumerate(zip(tests, records)):
        row = fixture[index*18:(index+1)*18]
        expected = row[12:18]+b'\0'
        got = bytes.fromhex(record)
        if got != expected:
            failures.append(dict(index=index, case=case, expected=expected.hex(), got=got.hex()))
    report = dict(cases=len(tests), failures=failures, fixture_record_bytes=18,
                  packed_result_bytes=5, independent_precision_anchors=len(anchors),
                  unresolved_numeric_symbols=0, duration_seconds=round(time.monotonic()-started,3),
                  status_counts={str(s):sum(fixture[i*18+12]==s for i in range(len(tests)))
                                 for s in sorted(set(fixture[12::18]))},
                  hashes={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest()
                          for p in [ROOT/"bin/basic.bin", RUNTIME/"numeric.s", TASK/"probe.s",
                                    RUNTIME/"vendor/MATH.Z80", build/"cases.dat", build/"probe.bin"]})
    (build/"results.json").write_text(json.dumps(report,indent=2)+"\n")
    (build/"reference.log").write_text(reference_log)
    (build/"native.log").write_text(native_log)
    (build/"cases.json").write_text(json.dumps(tests,indent=2)+"\n")
    print(json.dumps(report,indent=2))
    assert not failures, f'{len(failures)} numeric/ABI mismatches; see {build/"results.json"}'


if __name__ == "__main__":
    main()

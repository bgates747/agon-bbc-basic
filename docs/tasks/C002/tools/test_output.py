"""Compare compiled numeric PRINT transcripts with actual interpreter output.

Programs bundle many observations to avoid repeatedly compiling the same runtime.
Python orchestrates source files and comparisons, never arithmetic or formatting.
"""

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import time

TASK = Path(__file__).resolve().parents[1]
ROOT = TASK.parents[2]


def programs():
    groups = [
        ["PRINT 0", "PRINT 1", "PRINT -1", "PRINT &7FFFFFFF", "PRINT &80000000",
         "PRINT 2147483648.0*2", "PRINT 16777216.0+1", "PRINT 1/3", "PRINT -1/3"],
        ['PRINT ;ABS -7;":";INT(-7/2);":";SGN(-7);":";SQR16+9',
         'PRINT ;SIN0;":";COS0;":";EXP0;":";LN1;":";LOG100;":";ATN0;":";ASN0;":";ACS1',
         'PRINT ;RAD180;":";DEG PI;":";SIN(PI/2);":";COS PI;":";TAN(PI/4)',
         'PRINT ;SQR 2;":";EXP 1;":";LN 2;":";LOG 2;":";ATN1;":";ASN(1/2);":";ACS(1/2)',
         'PRINT ;NOT1;":";NOT(-7/2);":";SGN0;":";ABS(&80000000)'],
        ['PRINT ;1/1000000000;"|";1/(10^38);"|";10^38',
         'PRINT ;-1/(10^38);"|";-(10^38);"|";(2147483648.0*2)+3',
         'PRINT ;PI;"|";TRUE;"|";FALSE;"|";0.0',
         'PRINT ;999999999;"|";999999999+1'],
        ['PRINT "X";1;"/";2', 'PRINT 1;2;', 'PRINT 3', 'PRINT ;;4;;',
         'PRINT "Z"', 'PRINT ;', 'PRINT', 'PRINT "a""b";-7', 'PRINT 1:PRINT 2',
         'PRINT "";:PRINT 6;', 'PRINT "last";'],
        ['PRINT ;.125;":";-1.5;":";1.E1;":";1.25E-3',
         'PRINT ;SQR.25;":";INT -1.5;":";2E2+3;":";.5^-2',
         'PRINT ;2.5E-1^2;":";2E-2-1;":";(1E0=1)',
         'PRINT ;1EOR2;":";1.EOR2;":";1.0EOR2;":";1E2 EOR 1;":";1.E2 DIV 3;":";2.5E1 MOD 4'],
    ]
    result = [dict(source="\n".join(g)+"\n", reference=True, status=0) for g in groups]
    result += [dict(source=s, reference=True, reference_error=True, status=1) for s in [
        'PRINT "before":PRINT SQR(-1):PRINT "bad"\n',
        'PRINT EXP 1000\n',
        'PRINT LN 0\n',
        'PRINT SIN(10^20)\n',
        *[f'PRINT "before":PRINT ;{literal}:PRINT "bad"\n'
          for literal in ("1E39", "0E999", "1E000003")],
    ]]
    result.append(dict(source='GOTO @ok:PRINT 1E39\n@ok:PRINT "ok":END\n',
                       expected="ok\n", reference=False, status=0))
    result.append(dict(source='GOSUB @sub:PRINT "done":END\n@sub:PRINT ;SQR16:RETURN\n',
                       expected="4\ndone\n", reference=False, status=0))
    result += [dict(source=s, diagnostic=d) for s, d in [
        ('PRINT EVAL("1")\n', "EVAL is deliberately unsupported"),
        ('PRINT STR$(1)\n', "Unsupported string item STR"),
        ('PRINT ~65\n', "Expected a numeric item"),
        ('PRINT "x",1\n', "Unexpected text after statement"),
        ('PRINT SQR()\n', "Expected a numeric item"),
        ('PRINT ABS("x")\n', "Expected a numeric item"),
        ('PRINT PI()\n', "Unexpected text after statement"),
        ('PRINT SQR(1,2)\n', "Expected )"),
    ]]
    spec = importlib.util.spec_from_file_location("legacy_cases", TASK / "tools/test_expressions.py")
    legacy = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(legacy)
    old_cases = [c for c in legacy.cases() if "expression" in c]
    for start in range(0, len(old_cases), 12):
        block = old_cases[start:start+12]
        result.append(dict(source="".join(c["source"] for c in block), reference=True, status=0,
                           legacy_observations=len(block)))
    result.append(dict(source=(ROOT / "compiler/examples/numbers.bas").read_text(),
                       reference=True, status=0))
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cli", required=True, type=Path)
    parser.add_argument("--compiler", type=Path, default=ROOT / "compiler/compiler.bas")
    parser.add_argument("--runtime-build", type=Path, default=ROOT / "compiler/build/numeric-runtime")
    parser.add_argument("--skip-legacy", action="store_true")
    parser.add_argument("--string-runtime", type=Path, help="optional string runtime build to check independently")
    parser.add_argument("--isolate-reference", action="store_true", help="reset variables before each reference program")
    parser.add_argument("--timeout", type=float, default=180, help="compile-batch guard in seconds")
    args = parser.parse_args()
    args.compiler = args.compiler.resolve(strict=True)
    args.runtime_build = args.runtime_build.resolve(strict=True)
    spec = importlib.util.spec_from_file_location("harness", ROOT / "compiler/tools/test_compiler.py")
    harness = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(harness)
    profile = ROOT / ".emulator"
    assert (profile / ".compiler-tests").is_file()
    assert (profile / "fab-agon-emulator.bin").resolve() == args.cli.resolve(strict=True)
    sd = profile / "sdcard"
    build = TASK / "build/output-integration"
    build.mkdir(parents=True, exist_ok=True)
    (build / "results.json").unlink(missing_ok=True)
    tests = programs()
    if args.skip_legacy:
        tests = [case for case in tests if not case.get("legacy_observations")]
    started = time.monotonic()
    reference = ['10 ON ERROR REPORT:PRINT:OSCLI "BYE"', '20 @%=&90A']
    error_definitions = []
    for i, case in enumerate(tests):
        if case.get("reference"):
            if args.isolate_reference:
                reference += ['CLEAR', ':'.join(f'{letter}%=0' for letter in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')]
            body = case["source"].splitlines()
            if case.get("reference_error"):
                n = 10000+i*100
                error_definitions += [f'{n} DEF PROCerror{i}:LOCAL ERROR',
                                      f'{n+1} ON ERROR LOCAL REPORT:PRINT:ENDPROC',
                                      *[f'{n+2+j} {line}' for j,line in enumerate(body)],
                                      f'{n+90} ENDPROC']
                body = [f'PROCerror{i}']
            reference += [f'PRINT "REF_BEGIN_{i}"', *body, f'PRINT "REF_END_{i}"']
    reference = reference[:2] + [f'{100+i*10} {line}' for i, line in enumerate(reference[2:])]
    reference.append('9000 PRINT "OUTPUT_REFERENCE_DONE":OSCLI "BYE"')
    reference += error_definitions
    source = "\n".join(reference)+"\n"
    (build / "reference.bas").write_text(source)
    (sd / "output-reference.bas").write_text(source)
    oracle = harness.run_profile(profile, "load /bin/basic.bin\nrun . /output-reference.bas\n",
                                  "OUTPUT_REFERENCE_DONE", "output-reference.log")
    for i, case in enumerate(tests):
        if case.get("reference"):
            case["expected"] = oracle.split(f"REF_BEGIN_{i}\n", 1)[1].split(f"REF_END_{i}\n", 1)[0]
    (build / "cases.json").write_text(json.dumps(tests, indent=2)+"\n")
    (build / "reference.log").write_text(oracle)
    sentinel = b"Existing output survives output-expression errors"
    for i, case in enumerate(tests):
        (sd / f"p{i}.bas").write_text(case["source"])
        (sd / f"p{i}.bin").write_bytes(sentinel)
    defs = args.compiler.read_text().split("1000 DEF", 1)[1]
    before, after = defs.split("20000 DATA", 1)
    driver = ['10 PROCinit:RESTORE 10000', '20 test%=0', '30 test%=test%+1',
              f'40 IF test%>{len(tests)+1} THEN PRINT "OUTPUT_COMPILE_DONE":OSCLI "BYE"',
              '50 READ src$,dst$', '60 ON ERROR PRINT "ERR:";src$:REPORT:PRINT " at ";ERL:CLOSE#0:GOTO 90',
              '70 PROCcompile(src$,dst$)', '80 PRINT "OK:";src$', '90 GOTO 30']
    data = [f'{10000+i*10} DATA "p{i}.bas","p{i}.bin"' for i in range(len(tests))]
    data.append(f'{10000+len(tests)*10} DATA "p0.bas","output-repeat.bin"')
    source = "\n".join(driver)+"\n1000 DEF"+before+"\n".join(data)+"\n20000 DATA"+after
    (build / "driver.bas").write_text(source)
    (sd / "output-driver.bas").write_text(source)
    compiled = harness.run_profile(profile, "load /bin/basic.bin\nrun . /output-driver.bas\n",
                                    "OUTPUT_COMPILE_DONE", "output-compile.log", timeout_seconds=args.timeout)
    (build / "compile.log").write_text(compiled)
    for i, case in enumerate(tests):
        if "diagnostic" in case:
            record = compiled.split(f"ERR:p{i}.bas\n", 1)[1].split("ERR:", 1)[0].split("OK:", 1)[0]
            assert case["diagnostic"] in record, (i, record)
            assert (sd / f"p{i}.bin").read_bytes() == sentinel
        else:
            assert f"OK:p{i}.bas\n" in compiled, (i, compiled)
    assert (sd / "p0.bin").read_bytes() == (sd / "output-repeat.bin").read_bytes()
    template = (args.runtime_build / "runtime-0.bin").read_bytes()
    linked_bases = []
    string_link_bases = []
    for i, case in enumerate(tests):
        if "diagnostic" in case:
            continue
        image = (sd / f"p{i}.bin").read_bytes()
        position = image.find(template[:20])
        if position >= 0:
            base = 0x40000 + position
            output = build / f"runtime-{base:x}.bin"
            subprocess.run(["/Agon/agondev/release/bin/ez80-none-elf-ld", f"-Ttext=0x{base:x}",
                            "-e", "rt_numeric", "--oformat=binary", "-o", str(output),
                            str(args.runtime_build / "runtime.o")], check=True)
            assert image[position:position+len(template)] == output.read_bytes()
            linked_bases.append(base)
        if args.string_runtime:
            strings = (args.string_runtime / "runtime-0.bin").read_bytes()
            position = image.find(strings[:20])
            if position >= 0:
                base = 0x40000 + position
                output = build / f"strings-{base:x}.bin"
                subprocess.run(["/Agon/agondev/release/bin/ez80-none-elf-ld", f"-Ttext=0x{base:x}",
                                "-e", "rt_strliteral", "--oformat=binary", "-o", str(output),
                                str(args.string_runtime / "runtime.o")], check=True)
                assert image[position:position+len(strings)] == output.read_bytes()
                string_link_bases.append(base)
    commands = []
    for i, case in enumerate(tests):
        if "diagnostic" not in case:
            commands += [f"echo OUTPUT_BEGIN_{i}", f"try /p{i}.bin",
                         "echo OUTPUT_STATUS:<Try$ReturnCode>", f"echo OUTPUT_END_{i}"]
    commands.append("echo OUTPUT_NATIVE_DONE")
    native = harness.run_profile(profile, "\n".join(commands)+"\n", "OUTPUT_NATIVE_DONE", "output-native.log")
    (build / "native.log").write_text(native)
    for i, case in enumerate(tests):
        if "diagnostic" not in case:
            got = native.split(f"OUTPUT_BEGIN_{i}\n", 1)[1].split(f"OUTPUT_END_{i}\n", 1)[0]
            assert got == case["expected"]+f'OUTPUT_STATUS:{case["status"]}\n', (i, repr(got), case)
    report = dict(programs=len(tests), native_executions=sum("diagnostic" not in c for c in tests),
                  rejected_sources=sum("diagnostic" in c for c in tests),
                  reference_output_programs=sum(bool(c.get("reference")) for c in tests),
                  legacy_arithmetic_observations=sum(c.get("legacy_observations", 0) for c in tests),
                  deterministic_repeat=True, independent_link_bases=linked_bases,
                  string_link_bases=string_link_bases,
                  duration_seconds=round(time.monotonic()-started,3),
                  hashes={str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
                          for p in [args.compiler, ROOT / "bin/basic.bin", build / "cases.json"]})
    (build / "results.json").write_text(json.dumps(report, indent=2)+"\n")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()

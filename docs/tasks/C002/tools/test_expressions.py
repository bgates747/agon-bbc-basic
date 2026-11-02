"""Execute actual BBC compiler output; Python only prepares/checks fixtures."""

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import platform
import socket
import subprocess
import time

TASK = Path(__file__).resolve().parents[1]
ROOT = TASK.parents[2]


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


def cases():
    # Each predicate must independently be true. Reference BASIC also evaluates
    # every positive expression; expected B is not inferred from compiler output.
    pairs = [
        ("1+2*3", "7"), ("(1+2)*3", "9"), ("10-3-2", "5"),
        ("2^3^2", "64"), ("-2^2", "4"), ("-(2^2)", "-4"),
        ("2^-2", "1/4"), ("--7", "7"), ("+-7", "-7"),
        ("7 DIV 3", "2"), ("-7 DIV 3", "-2"), ("7 DIV -3", "-2"),
        ("-7 MOD 3", "-1"), ("7 MOD -3", "1"),
        ("1 OR 2 EOR 3", "0"), ("1 EOR 2 OR 4", "7"),
        ("1 OR 2 AND 0", "1"), ("NOT 1", "-2"), ("NOT (7/2)", "-4"),
        ("TRUE", "-1"), ("FALSE", "0"),
        ("1<2", "TRUE"), ("2>1", "TRUE"), ("2<=2", "TRUE"),
        ("2>=2", "TRUE"), ("2<>3", "TRUE"), ("2=3", "FALSE"),
        ("1<2 AND 3>2", "TRUE"),
        ("&FFFFFF", "16777215"), ("&1000000", "16777216"),
        ("&7FFFFFFF", "2147483647"), ("&80000000", "-2147483648"),
        ("&FFFFFFFF", "-1"), ("-&80000000", "&80000000"),
        ("&7FFFFFFF+1", "2147483648"),
        ("&80000000-1", "-2147483649"),
        ("65536*65536", "2147483648*2"),
        ("16777216.0+1", "16777217"),
        ("2147483648.0+1", "2147483649"),
        ("(2147483648.0*2)+1", "(2147483648.0*2)+2"),
        ("(2147483648.0*2)+3", "(2147483648.0*2)+2"),
        ("4294967295", "(2147483648.0*2)-1"),
        ("4294967296", "4294967290"),
        ("1/2+1/4", "3/4"), ("-1/2", "0-1/2"),
        ("1DIV2", "0"), ("1AND2", "0"),
    ]
    result = []
    for left, right in pairs:
        expression = f"65-(({left})=({right}))"
        case = dict(source=f"VDU {expression},13,10\n", expression=expression,
                    expected="B\n", status=0, diagnostic=None)
        result.append(case)
    expression = "65-(4294967296.0=4294967290)"
    result.append(dict(source=f"VDU {expression},13,10\n", expression=expression,
                       expected="B\n", status=0, diagnostic=None))
    for expression in ("65", "321", "-191", "131/2", "-381/2+256"):
        result.append(dict(source=f"VDU {expression},13,10\n", expression=expression,
                           expected="A\n", status=0, diagnostic=None))
    result += [
        dict(source='GOTO @main\n@sub:VDU 60+5:RETURN\n@main:GOSUB @sub:PRINT "B":END\n',
             expected="AB\n", status=0, diagnostic=None),
        dict(source='PRINT "' + "x"*70 + '":VDU 60+5,13,10:END\n',
             expected="x"*70+"\nA\n", status=0, diagnostic=None),
        dict(source='PRINT "ok":END\n', expected="ok\n", status=0, diagnostic=None),
        dict(source='VDU 1/0:PRINT "bad"\n', expected="Division by zero\n", status=1, diagnostic=None),
        dict(source='VDU 2^200:PRINT "bad"\n', expected="Number too big\n", status=1, diagnostic=None),
        dict(source='VDU 2147483648\n', expected="Number too big\n", status=1, diagnostic=None),
        dict(source='VDU (-2)^(1/2)\n', expected="Log range\n", status=1, diagnostic=None),
    ]
    failures = [
        ("VDU 1+\n", "Expected a numeric item"),
        ("VDU (1+2\n", "Expected )"),
        ("VDU 1<2<3\n", "Chained comparisons"),
        ("VDU 1<<2\n", "Shift operators"),
        ("VDU 1e3\n", "Unexpected text"),
        ("VDU 1E+ 3\n", "Unexpected text"),
        ("VDU 1E2EOR1\n", "Unsupported crunched text"),
        ("VDU &\n", "Expected digits"),
        ("VDU &100000000\n", "Hex literal exceeds"),
        ("VDU 1.2.3\n", "Unexpected text"),
        ("VDU EVAL(\"1\")\n", "EVAL is deliberately unsupported"),
        ("VDU a%(0)\n", "Arrays and function calls"),
        ("VDU \"A\"\n", "Expected a numeric item"),
        ("VDU 65;0\n", "Unexpected text"),
        ("PRINT INKEY$(1)\n", "Unsupported string item INKEY"),
        ("VDU "+"("*20+"1"+")"*20+"\n", "Expression nesting exceeds"),
        ("VDU 65\nGOTO @missing\n", "Undefined target"),
    ]
    result += [dict(source=s, diagnostic=d, expected=None) for s, d in failures]
    result += [
        dict(source='VDU FALSE AND (1/0)\n', expected="Division by zero\n", status=1, diagnostic=None),
        dict(source='GOSUB @sub:END\n@sub:VDU 1/0:RETURN\n',
             expected="Division by zero\n", status=1, diagnostic=None),
    ]
    for expression in ("65-(1.00=1.0)", "65-(0.0=FALSE)", "65-((1<2)=(2<3))",
                       "65-((-(1/2))=(0-1/2))", "65-((+(1/2))=(1/2))"):
        result.append(dict(source=f"VDU {expression},13,10\n", expression=expression,
                           expected="B\n", status=0, diagnostic=None))
    for literal in ("65.5", "6.5E1"):
        result.append(dict(source=f"VDU {literal},13,10\n",expected="A\n",status=0,diagnostic=None))
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cli", required=True, type=Path)
    parser.add_argument("--compiler", type=Path, default=ROOT / "compiler/compiler.bas")
    parser.add_argument("--runtime-build", type=Path, default=ROOT / "compiler/build/numeric-runtime")
    parser.add_argument("--start", type=int, default=0)
    parser.add_argument("--count", type=int, default=12)
    args = parser.parse_args()
    args.compiler = args.compiler.resolve(strict=True)
    args.runtime_build = args.runtime_build.resolve(strict=True)
    harness = module("bootstrap_harness", ROOT / "compiler/tools/test_compiler.py")
    profile = ROOT / ".emulator"
    assert (profile / ".compiler-tests").is_file()
    assert (profile / "fab-agon-emulator.bin").resolve() == args.cli.resolve(strict=True)
    sd = profile / "sdcard"
    build = TASK / f"build/expressions/promotion/batch-{args.start:03d}"
    build.mkdir(parents=True, exist_ok=True)
    tests = cases()[args.start:args.start+args.count]
    assert tests, "empty batch"
    (build / "cases.json").write_text(json.dumps(tests, indent=2)+"\n")
    started = time.monotonic()
    # The interpreter supplies output bytes; Python has no numeric model.
    reference = ['10 ON ERROR REPORT:PRINT:OSCLI "BYE"',
                 '20 ch%=OPENOUT("expr-oracle.dat")']
    oracle_indices = []
    for index, case in enumerate(tests):
        if "expression" in case:
            oracle_indices.append(index)
            reference.append(f'{100+index*10} byte%={case["expression"]}:BPUT#ch%,byte%')
    reference.append('5000 CLOSE#ch%:PRINT "EXPR_ORACLE_DONE":OSCLI "BYE"')
    (build / "reference.bas").write_text("\n".join(reference)+"\n")
    (sd / "expr-reference.bas").write_bytes((build / "reference.bas").read_bytes())
    reference_log = harness.run_profile(profile, "load /bin/basic.bin\nrun . /expr-reference.bas\n",
                                        "EXPR_ORACLE_DONE", "expr-reference.log")
    oracle = (sd / "expr-oracle.dat").read_bytes()
    assert len(oracle) == len(oracle_indices), (oracle, oracle_indices)
    for index, value in zip(oracle_indices, oracle):
        assert chr(value)+"\n" == tests[index]["expected"], (index, tests[index], value)
    (build / "oracle.dat").write_bytes(oracle)
    sentinel = b"Existing output survives rejected expression"
    for index, case in enumerate(tests):
        (sd / f"e{index}.bas").write_text(case["source"])
        (sd / f"e{index}.bin").write_bytes(sentinel)
    definitions = args.compiler.read_text().split("1000 DEF", 1)[1]
    repeat_index = next((i for i, c in enumerate(tests) if c["diagnostic"] is None), None)
    driver = ["10 PROCinit:RESTORE 10000", "20 test%=0", "30 test%=test%+1",
              f'40 IF test%>{len(tests)+int(repeat_index is not None)} THEN PRINT "EXPR_COMPILE_DONE":OSCLI "BYE"',
              "50 READ src$,dst$", '60 ON ERROR PRINT "ERR:";src$:REPORT:PRINT " at ";ERL:CLOSE#0:GOTO 90',
              '70 PROCcompile(src$,dst$)', '80 PRINT "OK:";src$', "90 GOTO 30"]
    for index in range(len(tests)):
        driver.append(f'{10000+index*10} DATA "e{index}.bas","e{index}.bin"')
    if repeat_index is not None:
        driver.append(f'{10000+len(tests)*10} DATA "e{repeat_index}.bas","expr-repeat.bin"')
    # Definitions end before DATA 10000, template starts at DATA 20000.
    before, after = definitions.split("20000 DATA", 1)
    content = "\n".join(driver[:9])+"\n1000 DEF"+before
    content += "\n".join(driver[9:])+"\n20000 DATA"+after
    (build / "driver.bas").write_text(content)
    (sd / "expr-driver.bas").write_text(content)
    compile_log = harness.run_profile(profile, "load /bin/basic.bin\nrun . /expr-driver.bas\n",
                                      "EXPR_COMPILE_DONE", "expr-compile.log", timeout_seconds=600)
    for index, case in enumerate(tests):
        diagnostic = case["diagnostic"]
        if diagnostic is None:
            assert f"OK:e{index}.bas\n" in compile_log, (index, compile_log)
        else:
            record = compile_log.split(f"ERR:e{index}.bas\n", 1)[1].split("ERR:", 1)[0].split("OK:", 1)[0]
            assert diagnostic in record, (index, diagnostic, record)
            assert (sd / f"e{index}.bin").read_bytes() == sentinel
    if repeat_index is not None:
        assert (sd / f"e{repeat_index}.bin").read_bytes() == (sd / "expr-repeat.bin").read_bytes()
    # Check the BBC-performed copy/relocation against an independent GNU link,
    # before executing an image. No arithmetic or BASIC code generation here.
    runtime_build = args.runtime_build
    template = (runtime_build / "runtime-0.bin").read_bytes()
    linked_bases = []
    for index, case in enumerate(tests):
        if case["diagnostic"] is None and "VDU" in case["source"]:
            image = (sd / f"e{index}.bin").read_bytes()
            position = image.index(template[:20])
            base = 0x40000 + position
            linked = build / f"runtime-{base:x}.bin"
            subprocess.run(["/Agon/agondev/release/bin/ez80-none-elf-ld", f"-Ttext=0x{base:x}",
                            "-e", "rt_numeric", "--oformat=binary", "-o", str(linked),
                            str(runtime_build / "runtime.o")], check=True)
            assert image[position:position+len(template)] == linked.read_bytes()
            linked_bases.append(base)
    golden_index = next((i for i, c in enumerate(tests) if c["source"] == 'PRINT "ok":END\n'), None)
    if golden_index is not None:
        assert (sd / f"e{golden_index}.bin").read_bytes() == (ROOT / "compiler/build/golden.bin").read_bytes()
    script = []
    for index, case in enumerate(tests):
        if case["expected"] is not None:
            script += [f"echo EXPR_BEGIN_{index}", f"try /e{index}.bin",
                       f"echo EXPR_STATUS:<Try$ReturnCode>", f"echo EXPR_END_{index}"]
    script.append("echo EXPR_NATIVE_DONE")
    native_log = harness.run_profile(profile, "\n".join(script)+"\n", "EXPR_NATIVE_DONE", "expr-native.log")
    for index, case in enumerate(tests):
        if case["expected"] is not None:
            record = native_log.split(f"EXPR_BEGIN_{index}\n", 1)[1].split(f"EXPR_END_{index}\n", 1)[0]
            assert record == case["expected"]+f'EXPR_STATUS:{case["status"]}\n', (index, case, record)
    report = dict(start=args.start, cases=len(tests), reference_expressions=len(oracle_indices),
                  native_executions=sum(c["expected"] is not None for c in tests),
                  rejected_sources=sum(c["diagnostic"] is not None for c in tests),
                  deterministic_repeat=repeat_index is not None, nonnumeric_assembly_golden=golden_index is not None,
                  independently_linked_image_bases=linked_bases,
                  duration_seconds=round(time.monotonic()-started, 3),
                  host=f"{socket.gethostname()}/{platform.machine()}", human_validation=False,
                  hashes={str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
                          for p in [args.compiler, ROOT / "bin/basic.bin", build / "oracle.dat"]})
    for name, log in [("reference", reference_log), ("compile", compile_log), ("native", native_log)]:
        (build / f"{name}.log").write_text(log)
    (build / "results.json").write_text(json.dumps(report, indent=2)+"\n")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()

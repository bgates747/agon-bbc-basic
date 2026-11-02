"""Compare literal bytes/errors/output with the same source in actual BASIC.

Python only orchestrates and compares. Historical exact anchors remain research
metadata; they never supply compatibility expectations.
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


def cases():
    anchors = [
        ("0", "0000000000"), ("1", "0100000000"), ("1.0", "0000000080"),
        (".5", "000000007F"), ("1.", "0100000000"), ("1E0", "0100000000"),
        ("1.E0", "0100000000"), (".0", "0000000000"),
        ("0.1", "CDCCCC4C7C"), ("1.5", "0000004080"),
        ("2147483647", "FFFFFF7F00"), ("2147483648", "000000009F"),
        ("4294967295", "FFFFFF7F9F"), ("4294967296", "00000000A0"),
        ("4294967297", "01000000A0"), ("4294967298", "01000000A0"),
        ("4294967299", "01000000A0"), ("4294967300", "02000000A0"),
        ("4294967301", "03000000A0"), ("4294967295.5", "FFFFFF7F9F"),
        ("4294967295.75", "00000000A0"), ("16777217.0", "8000000098"),
        ("5.87747175411143754E-39", "0000000001"),
        ("5.87747175411143753E-39", "0000000000"),
        ("340282366841710300949110269838224261120", "FFFFFF7FFF"),
        ("340282366881324382206242438634996236288", "FFFFFF7FFF"),
        ("0E999", "0000000000"), ("1E-999", "0000000000"),
        ("0.00000000000000000000000000000000000000001", "0000000000"),
        ("1e+3", "0000007A89"), ("1E-0", "0100000000"),
        ("000000000000000000000000000000000000000001", "0100000000"),
    ]
    result = [dict(literal=s, packed=h) for s, h in anchors]
    result += [dict(literal=s, oracle=e) for s, e in [
        (".25", "1/4"), (".125", "1/8"), ("12.75", "51/4"),
        (".01", "1/100"), (".001", "1/1000"), ("1.001", "1001/1000"),
        ("123.456789", "123456789/1000000"), ("123456.789", "123456789/1000"),
        ("1E3", "1000/1"), ("1.E+3", "1000/1"), ("1e-3", "1/1000"),
        (".5E+1", "5/1"), ("500E-3", "1/2"), ("1.0E0", "1/1"),
        ("000123.000", "123/1"), ("1E000003", "1000/1"),
    ]]
    result += [dict(literal=s,packed=h) for s,h in [
        ("0"*230+"1","0100000000"),
        ("1"+"0"*239+"E-239","0000000080"),
        ("0."+"0"*200+"1E+201","0000000080"),
        ("15"+"0"*230+".0E-231","0000004080"),
    ]]
    result += [dict(literal=s) for s in (".", ".E1", "1E", "1E+", "1E-", "1E 3", "1E  +3", "4294967296.0")]
    return [case for case in result if "e" not in case["literal"]]


def rejected():
    return [
        ("1e3", "Unexpected text after statement"),
        ("1e-3", "Unexpected text after statement"),
        ("1E+ 3", "Unexpected text after statement"),
        ("1.2.3", "Unexpected text after statement"),
        ("1E2E3", "Unsupported crunched text after exponent"),
        ("1E2EOR1", "Unsupported crunched text after exponent"),
        ("&100000000", "Hex literal exceeds eight digits"),
        ('EVAL("1")', "EVAL is deliberately unsupported"),
    ]


def tail_cases():
    result=[dict(literal=s,packed=h) for s,h in [
        ("1.00000000023283064365386962890625","0100000080"),
        ("1.00000000023283064365386962890624","0000000080"),
        ("1.00000000023283064365386962890626","0100000080"),
        ("1.00000000069849193096160888671875","0100000080"),
        ("4294967295.5"+"0"*80+"1","00000000A0"),
        ("4294967295.4"+"9"*80,"FFFFFF7F9F"),
        ("000.000E+999","0000000000"),
        ("1.E-0","0100000000"),
        ("0001.0000E-000","0000000080"),
    ]]
    return result+[dict(literal=s,oracle=e) for s,e in [
        ("3.1415926535897932384626433832795028841971693993751","PI"),
        ("0.33333333333333333333333333333333333333333333","1/3"),
        ("0.14285714285714285714285714285714285714285714","1/7"),
    ]]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cli", required=True, type=Path)
    parser.add_argument("--compiler", type=Path, default=ROOT / "compiler/compiler.bas")
    parser.add_argument("--start", type=int, default=0)
    parser.add_argument("--count", type=int, default=12)
    parser.add_argument("--reject", action="store_true")
    parser.add_argument("--generated", type=Path, help="BASIC-generated exact decimal/packed TSV")
    parser.add_argument("--generate", action="store_true", help="run the task's independent BASIC fixture generator")
    parser.add_argument("--single-pass", action="store_true", help="omit the extra determinism compile for supplemental batches")
    parser.add_argument("--timeout", type=float, default=180)
    args = parser.parse_args()
    compiler = args.compiler.resolve(strict=True)
    compiler_bytes = compiler.read_bytes()
    spec = importlib.util.spec_from_file_location("harness", ROOT / "compiler/tools/test_compiler.py")
    harness = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(harness)
    profile = ROOT / ".emulator"
    assert (profile / ".compiler-tests").is_file()
    assert (profile / "fab-agon-emulator.bin").resolve() == args.cli.resolve(strict=True)
    sd = profile / "sdcard"
    build = TASK / f"build/literal-compatibility/batch-{args.start:03d}"
    build.mkdir(parents=True, exist_ok=True)
    if args.generate:
        assert args.generated is None, "choose --generate or --generated"
        generator = TASK / "literals/generate.bas"
        (sd / "literal-generate.bas").write_bytes(generator.read_bytes())
        generation_started = time.monotonic()
        log = harness.run_profile(profile,"load /bin/basic.bin\nrun . /literal-generate.bas\n",
                                  "LITERAL_GENERATION_DONE","literal-generate.log",args.timeout)
        generated = TASK / "build/literals/generated"
        generated.mkdir(parents=True,exist_ok=True)
        args.generated = generated / "cases.tsv"
        args.generated.write_bytes((sd / "literal-generated.tsv").read_bytes())
        (generated / "generation.log").write_text(log)
        report = dict(duration_seconds=round(time.monotonic()-generation_started,3),
                      source_sha256=hashlib.sha256(generator.read_bytes()).hexdigest(),
                      fixture_sha256=hashlib.sha256(args.generated.read_bytes()).hexdigest())
        (generated / "results.json").write_text(json.dumps(report,indent=2)+"\n")
    all_cases = cases()
    if args.generated:
        all_cases += [dict(literal=s,packed=h,exact_binary_fixture=True)
                      for s,h in (line.split("|") for line in args.generated.read_text().splitlines())]
        all_cases += tail_cases()
    tests = all_cases[args.start:args.start+args.count]
    assert tests
    failures = rejected() if args.reject else []
    started = time.monotonic()
    reference = ['10 ON ERROR REPORT:PRINT:CLOSE#0:OSCLI "BYE"',
                 '20 @%=&90A:ch%=OPENOUT("literal.dat")']
    for i, case in enumerate(tests):
        # Direct source assignment uses tokenisation and CON, not a constructed
        # value or VAL. A separate VAL reading audits the compiler bootstrap path.
        reference.append(f'{30+i*10} PROCcase{i}')
        if "packed" in case: case["research_anchor"] = case.pop("packed")
        if "oracle" in case: case["research_expression"] = case.pop("oracle")
    reference += ['9000 CLOSE#ch%:PRINT "LITERAL_REFERENCE_DONE":OSCLI "BYE"']
    for i, case in enumerate(tests):
        n = 10000+i*100
        reference += [
            f'{n} DEF PROCcase{i}:LOCAL ERROR',
            f'{n+1} ON ERROR LOCAL v=0:PROCsave(v):BPUT#ch%,ERR:PRINT "LITERAL_{i}:";REPORT$:ENDPROC',
            f'{n+2} v={case["literal"]}',
            f'{n+3} PROCsave(v):BPUT#ch%,0:PRINT "LITERAL_{i}:";v',
        ]
        chunks=[case["literal"][j:j+70] for j in range(0,len(case["literal"]),70)]
        reference += [f'{n+4} readertext$="{chunks[0]}"']
        reference += [f'{n+5+k} readertext$=readertext$+"{chunk}"' for k,chunk in enumerate(chunks[1:])]
        reference += [f'{n+20} reader=VAL(readertext$):PROCsave(reader):ENDPROC']
    reference += ['60000 DEF PROCsave(v):LOCAL p%,i%:p%=^v',
                  '60010 FOR i%=0 TO 4:BPUT#ch%,p%?i%:NEXT:ENDPROC']
    source = "\n".join(reference)+"\n"
    (build / "reference.bas").write_text(source)
    (sd / "literal-reference.bas").write_text(source)
    (sd / "literal.dat").unlink(missing_ok=True)
    reference_log = harness.run_profile(profile, "load /bin/basic.bin\nrun . /literal-reference.bas\n",
                                        "LITERAL_REFERENCE_DONE", "literal-reference.log", args.timeout)
    (build / "reference.log").write_text(reference_log)
    fixture = (sd / "literal.dat").read_bytes()
    (build / "literal.dat").write_bytes(fixture)
    cursor = 0
    for i,case in enumerate(tests):
        case["expected_packed"] = fixture[cursor:cursor+5].hex().upper()
        case["reference_error"] = fixture[cursor+5]
        case["expected_text"] = reference_log.split(f"LITERAL_{i}:",1)[1].split("\n",1)[0]+"\n"
        cursor += 6
        if not case["reference_error"]:
            case["val_packed"] = fixture[cursor:cursor+5].hex().upper()
            assert case["val_packed"] == case["expected_packed"], case
            cursor += 5
    assert cursor == len(fixture), (cursor, len(fixture))
    positive = [c for c in tests if not c["reference_error"]]
    errors = [c for c in tests if c["reference_error"]]
    assert positive
    sources = ["".join(f'PRINT ;{c["literal"]}\n' for c in positive)]
    sources += [f'PRINT ;{c["literal"]}\n' for c in errors]
    sources += [f"PRINT ;{s}\n" for s,_ in failures]
    sentinel = b"Existing output survives literal diagnostics"
    for i,source in enumerate(sources):
        (sd / f"l{i}.bas").write_text(source)
        (sd / f"l{i}.bin").write_bytes(sentinel)
    definitions = compiler_bytes.decode().split("1000 DEF",1)[1]
    before,after = definitions.split("20000 DATA",1)
    driver = ['10 PROCinit:RESTORE 10000','20 test%=0','30 test%=test%+1',
              f'40 IF test%>{len(sources)+int(not args.single_pass)} THEN PRINT "LITERAL_COMPILE_DONE":OSCLI "BYE"',
              '50 READ src$,dst$',
              '60 ON ERROR PRINT "ERR:";src$:REPORT:PRINT " at ";ERL:CLOSE#0:GOTO 90',
              '70 PROCcompile(src$,dst$)','80 PRINT "OK:";src$','90 GOTO 30']
    data=[f'{10000+i*10} DATA "l{i}.bas","l{i}.bin"' for i in range(len(sources))]
    if not args.single_pass:
        data += [f'{10000+len(sources)*10} DATA "l0.bas","literal-repeat.bin"']
    source="\n".join(driver)+"\n1000 DEF"+before+"\n".join(data)+"\n20000 DATA"+after
    (build / "driver.bas").write_text(source)
    (sd / "literal-driver.bas").write_text(source)
    compiled=harness.run_profile(profile,"load /bin/basic.bin\nrun . /literal-driver.bas\n",
                                 "LITERAL_COMPILE_DONE","literal-compile.log",args.timeout)
    (build / "compile.log").write_text(compiled)
    assert "OK:l0.bas\n" in compiled, compiled
    for i in range(1, len(errors)+1):
        assert f"OK:l{i}.bas\n" in compiled, compiled
    for i,(_,diagnostic) in enumerate(failures,1+len(errors)):
        record=compiled.split(f"ERR:l{i}.bas\n",1)[1].split("ERR:",1)[0].split("OK:",1)[0]
        assert diagnostic in record,(i,record)
        assert (sd / f"l{i}.bin").read_bytes()==sentinel
    image=(sd/"l0.bin").read_bytes()
    if not args.single_pass:
        assert image==(sd/"literal-repeat.bin").read_bytes()
    runtime=ROOT/"compiler/build/numeric-runtime"
    template=(runtime/"runtime-0.bin").read_bytes()
    position=image.index(template[:20]);base=0x40000+position
    linked=build/"runtime.bin"
    subprocess.run(["/Agon/agondev/release/bin/ez80-none-elf-ld",f"-Ttext=0x{base:x}",
                    "-e","rt_numeric","--oformat=binary","-o",str(linked),str(runtime/"runtime.o")],check=True)
    assert image[position:position+len(template)]==linked.read_bytes()
    entry=json.loads((runtime/"runtime.json").read_text())["exports"]["rt_literal"]
    opcode=b"\xcd"+(base+entry).to_bytes(3,"little")
    payloads=[]
    for i in range(5,position-8):
        if image[i:i+4]==opcode and image[i-5:i-3]==b"\xdd\x21":
            payloads.append(image[i+4:i+9].hex().upper())
    assert len(payloads)==len(positive),(len(payloads),len(positive))
    for case,packed in zip(positive,payloads):case["compiled_packed"]=packed
    (build/"cases.json").write_text(json.dumps(tests,indent=2)+"\n")
    differences=[c for c in positive if c["compiled_packed"]!=c["expected_packed"]]
    assert not differences,differences
    commands = ["echo LITERAL_NATIVE_BEGIN", "try /l0.bin", "echo LITERAL_STATUS:<Try$ReturnCode>"]
    for i,case in enumerate(errors,1):
        commands += [f"echo LITERAL_ERROR_{i}", f"try /l{i}.bin", "echo LITERAL_STATUS:<Try$ReturnCode>"]
    commands += ["echo LITERAL_NATIVE_DONE"]
    native=harness.run_profile(profile,"\n".join(commands)+"\n",
                               "LITERAL_NATIVE_DONE","literal-native.log",args.timeout)
    (build/"native.log").write_text(native)
    expected="".join(c["expected_text"] for c in positive)+"LITERAL_STATUS:0\n"
    for i,case in enumerate(errors,1):
        expected += f'LITERAL_ERROR_{i}\n'+case["expected_text"]+"LITERAL_STATUS:1\n"
    actual=native.split("LITERAL_NATIVE_BEGIN\n",1)[1].split("LITERAL_NATIVE_DONE\n",1)[0]
    assert actual==expected,(expected,native)
    identities = [compiler,ROOT/"bin/basic.bin",build/"literal.dat",build/"cases.json"]
    assert compiler.read_bytes()==compiler_bytes, "compiler source changed during qualification"
    if args.generated: identities.append(args.generated.resolve(strict=True))
    report=dict(cases=len(tests),start=args.start,rejected_sources=len(failures),
                packed_mismatches=0,native_output_matches=True,deterministic_repeat=not args.single_pass,
                independent_runtime_link_base=base,
                reference_value_cases=len(positive), reference_error_cases=len(errors),
                expectation_source="direct reference BASIC source; no arithmetic substitutions",
                duration_seconds=round(time.monotonic()-started,3),
                hashes={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest()
                        for p in identities})
    (build/"results.json").write_text(json.dumps(report,indent=2)+"\n")
    print(json.dumps(report,indent=2))


if __name__=="__main__":
    main()

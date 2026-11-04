# Benchmark coverage and limits

The fixture exercises a broad portion of the supported language without adding
compiler features. Coverage here means source is prepared; Console8 compilation,
correctness and timing remain untested. A paired state match is necessary but
cannot prove that both engines implement the intended work correctly.

| Compatibility entry | Case / disposition |
| --- | --- |
| Compiler implementation and native MOS image | Author compiles suite.bas with the qualified compiler, records output image; no timed self-compile in this fixture |
| Unnumbered source / optional line numbers | Shared suite is conventionally numbered; existing manual suite covers mixed/unnumbered; excluded from runtime speed comparison |
| Source control bytes | CHR$(0) string case27; literal source control bytes excluded as unsupported |
| Named labels | Existing control/activation tests; excluded from paired conventional source |
| GOTO/GOSUB/RETURN/END, REM/colon | 8 and main/harness; GOSUB stays inside its PROC's activation |
| PRINT | 37 numeric/string formatting and screen delivery together; result reporting outside all other timers |
| VDU/CLS | checks.bas, correctness only; no claim of isolated byte-delivery speed |
| MODE/GCOL/PLOT | 38; MODE setup/restore outside timer; command enqueue time only, not rendered completion |
| GET | checks.bas manual Space key; excluded from CPU timing |
| Integer and byte values | 2,4,17,18,22,23,25,39,40; checks.bas includes full-width hex; no comprehensive overflow benchmark |
| Literals and float40 | Runtime operands in3,14–16,19–21,32–34; decimal/hex literals used; packed scalar result compared exactly, not decoded as IEEE |
| Arithmetic/conversion | 14–21,39–42; ^, DIV, MOD and promotion-independent groups; overflow/error boundary timings deferred to existing semantic tests |
| Standard math functions and PI | 18–20; ABS ACS ASN ATN COS DEG EXP INT LN LOG NOT RAD SGN SIN SQR TAN and PI |
| Formatting controls | STR$ default/hex in21; fixed G9 PRINT37; unsupported @% mutation excluded |
| Comparison and Boolean expressions | 5,18,29; all six numeric/string relations in checks.bas |
| Scalar variables and suffixes | 2–4, plus all kernels; %, &, unsuffixed numeric and $; variable-count/name-distance sweeps not implemented in this first fixture |
| Mutable strings, slicing/conversion/search/repetition | 12,21,27–30, including self-copy, NUL, slice stores, explicit counts; broader reference quirks remain existing regression coverage |
| IF forms | 5; inline/block IF throughout; line targets in8/error recovery; no separate IF target-distance sweep yet |
| FOR/STEP/NEXT, WHILE, REPEAT | 1–7,31–34; FOR STEP in checks.bas; ordinary NEXT lists and resource limits left to existing regressions |
| PROC/FN/LOCAL | 9–13,41–42; by-value arguments, numeric/string results, parameter LOCAL, scalar string/numeric LOCAL restoration and bounded recursion |
| Arrays and DIM | 22–25,31; byte/integer/variant/string and multidimensional arrays; allocation/setup outside timings |
| DATA/READ/RESTORE | 26; scalar integer, variant and string literal fields, numbered RESTORE; array READ remains existing semantic coverage |
| File I/O | 35–36 OPENIN/OPENOUT/BGET/BPUT/EOF/CLOSE; write readback outside timing; OPENUP and string BPUT exercised in checks.bas; no cache-state claim |
| INPUT LINE | Suite configuration and checks.bas typed C011; manual wait excluded |
| Indirection/address-of | 25 ! and binary ?, packed fingerprints use ^ and ?; unary ?/! and five-byte | in checks.bas |
| ON ERROR/ERROR/REPORT/ERR/ERL | Suite failure handler; checks.bas deliberate error/recovery and OFF; LOCAL/no-op/handler-stack quirks remain existing regressions |
| Self-compilation | Existing C006/C010 exact-image evidence; future application benchmark, not run here |
| EVAL, CASE, CALL/USR, assembler and other unsupported features | Explicitly excluded; no interpreter fallback |

Cases14/15/16 perform1/4/16 dependent float multiplications per loop with the
same runtime factor. Cases39/40 perform4/16 dependent integer additions or
subtractions. Cases41/42 perform the same four integer operations through four
small FN calls versus one grouped FN call. These are matched experiments, not
proof of an exact dispatch/numeric percentage.

Cases32–34 visit sixteen fixed points per outer iteration, retaining total
escape iterations and a first-pass histogram. Region names are neutral: the
actual histograms determine which is computation-heavy. No pixels are sent in
these cases. The unchanged full Mandelbrot remains a separate application.

The harness includes a40-test dispatch chain for42 cases in every timed
PROCrun invocation (three Mandelbrot cases share one test).
Case1 measures the FOR loop plus that harness, not a zero-instruction timer
cost. Do not subtract it automatically from unlike workloads. Clock reads use
bounded double sampling; the two engines still incur different BASIC hook
costs. Ten-second batches reduce their relative effect; they do not erase it.

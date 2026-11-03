# Curated testing and benchmark catalogue

The best starting combination is the existing semantic tests, bench64's separate
workloads, and small local control-flow/call/string kernels. Use the compiler
itself and a bounded Game of Life as realistic applications. Numeric and device
tests provide useful controls, but cannot alone explain interpreter overhead.
This is a source-inspected shortlist, not a runnable or performance-qualified
suite. No new benchmark was executed during this search.

## Status and provenance

1. Catalogue date: **2026-11-01**, task [C007](../C007.md). Stable candidate
   names below are catalogue references, not additional TODO tasks. Adaptations
   described here have not been implemented. Programme adoption is separate
   from compiler feature implementation.
2. **Eligibility below is the November 1 search snapshot.** At that checkpoint
   complete performance programs still required missing variables, expressions
   and loops; C001 regression and the separate C002 numeric probe were available.
   C002–C005 have since promoted those facilities for the scopes in the live
   [compatibility matrix](../../../compiler/COMPATIBILITY.md). W01 now has a
   successful native self-source preflight. This is correctness qualification,
   not a paired performance measurement or automatic admission of other sources.
3. Local source links below refer to inspected files at checkpoint `ccd09af`.
   [The inventory](evidence/local-inventory.json) records exact Git objects,
   SHA-256 hashes and origins. Most interpreter tests predate the compiler;
   inventorying them does not assert that they pass on this interpreter.
4. External sources are pinned in [external-sources.json](evidence/external-sources.json).
   BBCSDL and ClockSp were inspected from their actual tokenised files, not
   merely their descriptions. The small [listing aid](tools/inspect_tokenized.py)
   checks record framing and displays unknown tokens/encoded line references;
   it is not a source converter or a BASIC compiler. Downloads and rendered
   listings remain disposable ignored files under `build/`.

## Correctness gates

| Candidate | Inspected source and purpose | Oracle and eligibility |
| --- | --- | --- |
| R01 — native bootstrap | [C001 runner](../../../compiler/tools/test_compiler.py), literal output, labels, GOTO/GOSUB/RETURN, diagnostics and output preservation | Existing golden assembly, expected transcripts/status and deterministic image checks. Previously qualified: 39 cases / 15 native executions. Runnable now; not a timing suite. |
| R02 — numeric ABI | [C002 probe/harness](../C002/README.md), packed integers/floats, conversions, errors, aliasing and calling conventions | Existing byte-level reference comparisons and independent precision anchors: 257 cases previously qualified. At search time this was a separate experiment; consult the live matrix for subsequently promoted expressions/runtime. No new execution claim here. |
| R03 — language regression | [Conformance suite](../../../tests/conformance/README.md), plus [locals](../../../tests/locals.bas), [by-reference](../../../tests/byreftest.bas) and [COUNT/output](../../../tests/counttest.bas) tests | Preserve expected values/error numbers and zero-failure summary for each selected test. Whole suites await their required features; use explicit feature-filtered extracts. No fresh execution claim. |

R03's useful divisions are core/edge syntax, stress, file I/O, float precision,
LOCAL DIM, memory churn and state restoration. Do not mistake all these tests
for the compiler's language specification. EVAL tiers remain **negative compile
tests** for the initial compiler. Other files also contain EVAL (including
memory churn/state-edge tests), compound assignments, ON ERROR LOCAL, by-reference
RETURN parameters or platform facilities. Extract and name conventional subsets
explicitly; do not silently enable extensions or discard failures. Previously
documented platform skips remain skips, never passes.

## Performance shortlist

“Early” means after numeric expressions, variables and relevant flow control;
“later” additionally needs strings, activations, arrays or I/O as stated. These
are feature gates, not promises that a broad task implements every keyword.

| Candidate | What it exposes / likely cost | Required features and selection |
| --- | --- | --- |
| B01 — **bench64** | Separate loop, branch, subroutine, function, string, array and maths cases | Early individual control cases; complete suite later requires DATA/READ, FN, strings, arrays, TIME and transcendental maths. Preferred established broad benchmark. |
| B02 — **ClockSp 2.01** | Integer/real loop pairs, PROC versus GOSUB, strings, transcendental work | Loops and TIME early; calls/strings later. Good BBC-specific complement; use fixed work and raw elapsed ticks. |
| B03 — **BBCSDL timing.bbc** | Interpreter statement dispatch, name lookup, assignments, calls and arithmetic | A source of isolated kernel ideas. Whole program unsuitable unchanged: additional types/dialect, GUI setup, perpetual wait and interpreter-only constructs. |
| B04 — **local loopbench** | Integer increment, variable access, loop/statement overhead | `%`, FOR/NEXT, TIME, numeric PRINT. Smallest useful early arithmetic/dispatch mixture. |
| B05 — **local NSCAN test** | CASE misses and scans to OTHERWISE/ENDCASE | CASE and FOR. Strong control-flow seed, later extend to bounded hit/miss distributions. |
| B06 — **local stress kernels** | Nested FOR, REPEAT/WHILE, GOSUB, recursive FN and PROC calls | Extract separate bounded cases from l3a_stress. Calls must retain proper PROC/FN/LOCAL semantics. |
| B07 — **LOCAL/string churn** | Saving/restoring bindings, short string work, allocation and local arrays | LOCAL, strings, arrays and RETURN parameters where used. Select EVAL-free kernels; use alongside restoration tests. |
| B08 — **local multiplication benchmarks** | Integer width/overflow and floating promotion controls | Numeric expressions/loops/TIME. Preserve original separately; constants make it an optimisation demonstration unless adapted. |
| B09 — **local indexing benchmarks** | Subscripts, index expressions and matrix work | Arrays, FN and maths. Remove timed progress output for compute variant. The named “2D” case uses flattened indexing. |
| B10 — **local file-I/O suite** | Byte API calls, typed record serialization, seeking, reopen/state | File operations, loops, strings, PTR/EXT/EOF. Correctness first; device latency may dominate measured time. |
| B11 — **Matrix Brandy sieve** | Branches, integer loops and array writes with a real result | Arrays/loops, whole-array assignment in original; replace compound assignment only in a documented conventional derivative. Useful mixed integer/control test. |
| B12 — **Matrix Brandy combsort/bubblesort** | Data-dependent branches, accesses and swaps | Arrays, PROC, SWAP, RND, TIME. Useful sorting algorithms; input generator and checker need review before adoption. |
| B13 — **BBCSDL Hanoi** | Recursive PROC activation, parameter binding and small decisions | Procedures/recursion; original also arrays/strings and screen I/O. Keep computational move generation separate from animation. |

### B01–B03: established external timing programs

1. **B01:** [BBC BASIC source](https://github.com/scruss/bench64/blob/fb0d0de4d98aa1bfc49191294b7216df13572b09/bbc_basic/bench64bbc.bas)
   and [author's rules](https://github.com/scruss/bench64/blob/fb0d0de4d98aa1bfc49191294b7216df13572b09/README.md).
   Preserve the official version, including unsuffixed numeric variables and
   standard counts; faster `%` substitutions violate its comparison rules.
   Longer/checksummed runtime variants must be separately named derivatives.
   Oracles: completed loop counts, final FN value, exact string rotation from
   iteration count, final array values and reference 40-bit maths results.
   Checks belong outside timing. Do not publish its historical combined index
   as an explanation of compiler gains; retain individual elapsed times.
   **License: CC BY-SA 4.0**, including attribution/share-alike requirements for
   copied adaptations. No benchmark source is vendored by this task.
2. **B02:** [ClockSp](https://github.com/stardot/MatrixBrandy/blob/737d89583e2faf77bccbf1038ccf12f454518a48/tests/ClockSp).
   This inspected copy is **2.01**; do not identify it as the later 3.00 mentioned
   elsewhere. It calibrates work from TIME, then reports BBC-model-relative
   “MHz”. That is not Agon clock speed. Fix/log counts once per paired comparison;
   do not let each engine select a different workload. Oracle: final loop
   values, call counts and reference string/maths results. Ackermann exists in
   the source but its timed invocation is commented out. Repository COPYING is
   GPL v2; a program-specific grant/ownership chain for this historical program
   was not established. Keep it a linked candidate until provenance is resolved.
3. **B03:** [timing.bbc](https://github.com/rtrussell/BBCSDL/blob/88e012617e27d6ed7ab2cab5d336d1121a044b45/examples/tools/timing.bbc).
   Especially relevant: short/long variable names, named versus implicit NEXT,
   calls, and cheap statements. However, its nanosecond display relies on fixed
   repetition counts and subtracted baselines; retain raw ticks instead. It
   includes `%%`/`#` types, compound assignments and unmatched ENDIF/ENDCASE
   dispatch tests: these are not portable semantic requirements. Remove desktop
   setup/waiting in any derivative. Oracle: observed final values/counters,
   with runtime-input variants to distinguish generated execution from eliminated
   work. Repository zlib-style license; preserve notices and check file-specific
   attribution before copying. No change to our numeric representation follows.

### B04–B10: local programs and adaptations

1. **B04:** [loopbench.bas](../../../tests/loopbench.bas). Existing 10,000
   increments should end at `C%=10000`; the original prints only time. Add a
   checked result and fixed longer batches. A compiler that replaces an entire
   loop has measured a legitimate optimisation, but that result cannot alone
   establish dispatch cost. Keep a runtime-input/state-dependent companion.
2. **B05:** [nscantest.bas](../../../tests/nscantest.bas), supported by
   [nscan.bas](../../../tests/nscan.bas). Existing oracle is `OK` without `BAD`;
   add branch counters to a derivative. Cover always-hit, always-miss, alternating
   paths and nearby/distant targets. Those additional cases are gaps, not
   programs already found. No interaction belongs in the timed region.
3. **B06:** [l3a_stress.bas](../../../tests/conformance/l3a_stress.bas).
   Existing oracles include sum `20100`, nested-loop `3200`, 100 GOSUB increments,
   factorial(10) `3628800`, Fibonacci(12) `144`, and PROC result `10100`.
   Retain checks and extract each kernel with fixed repetitions. Measure leaf
   calls, bounded recursion and lookup separately; do not time all reporting.
   [recurse.bas](../../../tests/recurse.bas) recurses until exhaustion and is
   unsuitable as a throughput benchmark.
4. **B07:** [locals.bas](../../../tests/locals.bas),
   [local DIM suite](../../../tests/conformance/l4c_localdim.bas), and
   [l5e memory churn](../../../tests/conformance/l5e_memchurn.bas).
   Oracles include restored outer sentinels and expected counts (200 string
   cycles, 100 local integer-array cycles, 60 local string-array cycles).
   Extract before the EVAL-containing sections, audit RETURN-parameter needs,
   and repeat within known memory limits. Repeated equal results and bounded
   memory matter as much as throughput. Allocation/copying can remain costly
   after name parsing and statement dispatch disappear.
5. **B08:** [mult_benchmarks.bas](../../../tests/mult_benchmarks.bas).
   Literal operands and repeatedly overwritten results invite constant folding
   and dead-store elimination. Keep that original as an optimisation case;
   a distinct runtime test uses deterministic varying operands and observed
   checksums. Record 8/16/full-32-bit input ranges, signed results, overflow/
   promotion and reference bytes; never time a narrowed 24-bit substitute.
6. **B09:** [index_benchmarks.bas](../../../tests/index_benchmarks.bas).
   Progress printing occurs inside timed outer loops. Separate display and
   compute variants; check array contents/matrix results, not just elapsed time.
   Retain exact index bounds and verify FN control paths before taking a baseline.
7. **B10:** [l3b_fileio.bas](../../../tests/conformance/l3b_fileio.bas).
   Existing binary fixture writes 16 bytes `i*3` for `i=0..15`, expected read sum
   `360`; seeking and typed numeric/string round trips supply further oracles.
   `PRINT#`/`INPUT#` are BBC typed serialization, not a text CSV parser. Scale a
   disposable fixture outside setup timing and compare file bytes/length/EOF.
   Separate per-byte overhead, record processing and end-to-end storage rates.

Local repository license is [zlib-style](../../../license.txt); retain existing
authorship and notices, including attributed demos. Per-file exceptions or
unclear historical imports require checking before copying elsewhere; repository
placement is not proof of every author's grant.

### B11–B13: algorithmic complements

1. **B11:** [sieve](https://github.com/stardot/MatrixBrandy/blob/737d89583e2faf77bccbf1038ccf12f454518a48/examples/sieve).
   The inspected file uses size 10000 and ten repetitions, prints progress while
   timed, and counts odd-prime candidates `2*i+3`. Independently establish the
   count for its exact inclusive bound; do not reuse an unrelated 8191-element
   sieve's expected total. Validate the full flag set for a small fixture.
   Preserve algorithm/bounds in a conventional derivative with silent compute
   timing. Repository GPL v2 text inspected; confirm this example's attribution
   and applicable grant before vendoring.
2. **B12:** [combsort](https://github.com/stardot/MatrixBrandy/blob/737d89583e2faf77bccbf1038ccf12f454518a48/examples/combsort).
   Original setup4 has a zero-length-tail case requiring semantic review;
   inspect it before trusting generated input. Freeze identical ascending,
   descending, duplicate-heavy and mixed input arrays. Check both sortedness
   and preservation of all elements. Original comb gap uses division by 1.3,
   so it is not purely integer work. Keep algorithms as separate results.
   Same repository-license/per-file attribution qualification as B11.
3. **B13:** [Hanoi](https://github.com/rtrussell/BBCSDL/blob/88e012617e27d6ed7ab2cab5d336d1121a044b45/examples/games/hanoi.bbc),
   header credits R. T. Russell, 1982. Replace interactive setup, redraws,
   `*REFRESH` and infinite wait with a fixed disc count and checked move sink
   in a named derivative. Oracle: `2^n-1` legal moves, final ordered destination
   stack, other stacks empty. Retain parameter/local restoration tests; this
   is PROC recursion, not GOSUB. Repository zlib-style terms as B03.

## Realistic mixed applications

| Candidate | Work and adaptation | Oracle / feature gate |
| --- | --- | --- |
| W01 — **our BBC BASIC compiler** | [compiler.bas](../../../compiler/compiler.bas) parsing fixed plain-text programs, string scanning, symbol/address resolution and binary writing. Vary source size, line length and forward-reference density within its current limits; log input/output bytes. | Golden output for fixed compiler version and execution of generated files; separate parse/codegen from file writing where practical. Source 6597a0df now has a byte-identical 324275-byte native self-source preflight; C006 owns the full repeated-generation/physical proof. Controller durations are not benchmark timings. Original project checkpoint: ccd09af; runtime provenance/reuse terms remain in REFERENCE and vendor notices. |
| W02 — **Game of Life** | [local life.bas](../../../tests/demos/life.bas), real two-dimensional arrays, neighbour branches and state updates. Replace random initialisation with a frozen grid and infinite loop with a generation count; compute and rendered variants separate. | Full final grid or checksum plus selected generation snapshots from an independently checked glider/oscillator fixture. Arrays/loops/logic; screen formatting only for the display variant. Local license qualification above. |
| W03 — **CPU Mandelbrot** | [local mandlebrot.bas](../../../tests/demos/mandlebrot.bas), header P. Mainwaring, 1990. Fixed coordinates, iteration bound, deterministic escape-count map; separate pixels from computation and remove final GET. | Reference 40-bit escape counts with selected point checks, then display checksum. Float/arrays/DATA/control flow and optional graphics. Numeric-heavy control, not the main evidence for dispatch gains; local historical attribution must be retained. |

## Gaps and rejected leads

1. **Record/text parsing and variable-table scaling:** no ready, source-inspected
   standalone benchmark meeting our input/oracle requirements was found. W01
   covers realistic parsing. A future authored RAM-resident record scanner and
   small/large variable-name-set kernels would isolate these costs better.
   Include repeated references to already-created variables, not just setup.
2. **Branch distribution and target distance:** bench64's IF is always true
   and its GOTO is adjacent. B05's miss case helps but does not fill this gap.
   A finite state-machine workload with fixed input and checked final state
   remains a proposed addition.
3. **I/O:** existing regressions test semantics more than sustained workloads.
   RAM parsing, MOS byte-call throughput and SD/VDP end-to-end rates need
   distinct fixtures. Human INPUT/GET latency is not interpreter performance.
4. **Dean's pinned Agon examples** (`3901c2de…`, see [REFERENCE](../../../compiler/REFERENCE.md))
   include sort/file/animal programs, but were only inventoried as leads; no
   timing-ready qualification or program-level license audit was completed.
   [BBC Z80 tests](https://github.com/rtrussell/BBCZ80/tree/1e932b5ad88e13edda54c785d0ce26ff6fa42089/tests)
   supply additional regression provenance; no dedicated benchmark was found
   in the inspected test tree. These are not adopted performance cases.
5. **BBCSDL sorttest** calls an external sort library rather than implementing
   the sorting loop in BASIC, and includes 64-bit/variant array types. Prefer
   B12 for measuring compiled BASIC algorithm execution. BBCSDL's
   [official example index](https://bbcbasic.uk/bbcsdl/examples/index.html)
   identifies its Mandelbrot as a GPU-shader example; use W03 for CPU work.
6. **Historical Rugg/Feldman, prime and Whetstone suites:**
   [Gordon Henderson's primary account](https://projects.drogon.net/retro-basic-and-bcpl-benchmarks/)
   and [Roy Longbottom's collection](https://roylongbottom.github.io/royRepository/)
   are useful leads. A BBC-compatible Whetstone listing and redistribution
   provenance were not inspected here; it is not a selected runnable case.
   Historical cross-machine numbers are not compiler speedup evidence.

See [MEASUREMENT.md](MEASUREMENT.md) for the equal-work, correctness and timing
contract. Candidate adoption does not expand the compiler language; unfinished
implementation remains solely in [TODO.md](../../../TODO.md).

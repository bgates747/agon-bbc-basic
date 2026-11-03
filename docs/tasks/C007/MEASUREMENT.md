# Measurement contract for the curated corpus

Measure identical, validated work on the same Agon configuration and retain
results by workload. Cheap statements, lookup and control flow should expose
interpreter overhead; arithmetic routines, allocation and MOS/VDP/SD services
can limit the visible gain. Those are hypotheses to test, not speedup claims.
The original search checkpoint could not run the shortlisted performance
programs. The live matrix now owns eligibility; W01's native self-source
preflight supplies correctness evidence, not a paired timing result.

## Separate the questions

1. **Semantic regression:** does the program produce correct values, errors,
   restored locals, bytes and observable output? A correctness test need not
   be a good benchmark. EVAL must still be rejected. Unsupported-feature cases
   are explicit exclusions/negative tests, never counted as successful execution.
2. **Runtime throughput:** how long does the same BASIC work take interpreted
   and compiled? Keep dispatch/lookup/calls, strings/allocation, arithmetic and
   device-heavy results separate. Loops still do some arithmetic; labels such
   as “control-heavy” describe intent, not a measured time decomposition.
3. **Optimisation benefit:** eliminating constant expressions or empty loops
   is useful, but record it as eliminated work. Pair those cases with runtime
   input and observed state when investigating execution overhead. Do not
   disable legitimate optimisation silently to manufacture an explanation.
4. **Development/application cost:** compilation and executable loading are
   separate from steady execution. Report compile time, file size, complete
   linked runtime size and memory requirements. For short programs, show total
   compile/load/run cost as well as execution-only cost if making practical
   performance claims. Self-compilation is a later, distinct application case.

## Reproducible paired comparisons

1. Freeze exact BASIC source, adapted-source diff/hash, deterministic input
   bytes, expected output, logical operations/counts and candidate version.
   Use the same source and inputs for both engines. Conventional numbered
   source permits interpreter comparisons; named-label/unnumbered extensions
   require an explicitly documented equivalent interpreter fixture.
2. Freeze interpreter source/binary hashes, compiler source/binary hashes,
   linked runtime, tool versions/options and complete emitted image hash.
   The baseline compiler checkpoint for this search is `ccd09af`; use actual
   future measured revisions, never this document's date as a substitute.
3. Record physical Agon model, CPU clock, MOS version, VDP firmware/settings,
   memory limits, SD medium/filesystem and connected peripherals. Keep
   interrupts and normal operating-system services in the same state. Avoid
   background activity and log any unavoidable variation.
4. Numeric storage/semantics must remain four-byte signed integers and
   five-byte BBC floats. Match conversion, overflow/promotion and rounding for
   the covered operations; retain exact expected bytes where specified.
   Do not substitute IEEE32/64, 24-bit integers or another dialect's default
   numeric type to improve timings. External BBCSDL timings are not our
   numerical or performance baseline.
5. Use frozen arrays/records for workload data. A seed alone is insufficient
   across implementations with different RND algorithms. Record checksums,
   byte/record counts, string lengths, branch/call counts and final state.
   Create input files outside the compute region. Keep setup and cleanup
   measurements available separately.
6. Bench64's official source/counts and portability rules must remain intact
   for an official index result. A longer, integer-specialised or checksummed
   derivative gets its own name and result series. ClockSp's relative “MHz”
   is historical calibration, not actual Agon clock frequency.

## Timing procedure

1. First execute correctness checks under the reference interpreter and the
   compiled program. Reject timings on mismatched results, incomplete output,
   errors, skipped work or changed input. Validate arithmetic with reference
   packed bytes where appropriate; an independent small oracle catches defects
   shared by compiler and reference. Python may validate counts/fixtures, not
   replace BBC arithmetic or implement the compiler.
2. Use verified target TIME centiseconds or a documented target timer. Confirm
   its resolution and behavior on the chosen MOS/interpreter combination.
   A 100 Hz clock cannot resolve short native kernels: one tick is 10 ms.
   Batch to roughly 2–10 seconds or longer as appropriate; at two seconds,
   one tick is 0.5% of elapsed time before other uncertainty. Never report
   zero-duration division, sub-tick precision or converted “ns” as direct
   high-resolution observations.
3. Choose the batch count during an untimed calibration and freeze it for
   both engines. If a compiled run is too short, increase the count for both
   and re-run the pair. Bound counts to avoid changed numeric overflow,
   memory exhaustion, recursion depth or time-counter wrap. Changing work
   independently per engine requires a separate rate-based experiment.
4. Time the same region: timer read, fixed workload, timer read. Exclude
   banners, progress printing, prompts, checksumming and cleanup unless they
   are explicitly part of that workload. Preserve semantic work inside the
   kernel; make results observable after timing and inspect generated code
   when eliminated work could explain surprising results.
5. Perform a documented warmup, then at least five measured repetitions per
   engine, alternating/interleaving their order where practical. Reset state
   and input consistently. Retain all raw ticks, median, spread (for example
   interquartile range), counts and failures. Longer runs/further repeats
   should respond to quantisation or variance, not continue until a desired
   answer appears.
6. Publish elapsed time and operations/second per kernel. Speedup is paired
   interpreter time divided by compiled time for equal validated work.
   Baseline subtraction may be a supplementary experiment; never make a
   noisy or negative difference the only result. Do not average unrelated
   historical indices into a general “compiler is X times faster” claim.

## I/O needs three different measurements

| Workload | Hold fixed | Meaning / oracle |
| --- | --- | --- |
| RAM-resident record/text processing | Bytes, delimiters, record count, output and buffer strategy | Parser/branch/string work after preloading; checked parsed records/checksum. This fixture remains a gap. |
| File API overhead | Same file and per-byte/record API calls, sizes and call counts | Dispatch/runtime plus MOS/filesystem overhead; check exact bytes, length, position and EOF. Do not change to bulk calls only for one engine. |
| End-to-end SD or display work | Same device, bytes/pixels, formatting, buffering and completion condition | Useful application throughput including service/device costs; check delivered output. Log flush/close behavior and pending VDP work. |

1. BBC `PRINT#`/`INPUT#` typed records and a textual CSV parser are different
   workloads. Console formatting likewise differs from simply emitting a
   preformatted string. Name the actual work being measured.
2. Report warm-cache and cold-start results separately only when that state
   can be established. Reopening a file alone does not prove a cold cache.
   Otherwise label storage/cache state uncontrolled and retain its variance.
3. Display timing must state whether it ends after enqueueing commands or
   after a verified completion/synchronisation mechanism. A full queue or VDP
   rendering bottleneck can hide CPU savings. Do not invent a completion
   guarantee for a MOS call; verify the actual API and use it consistently.
4. Human reaction time, key waiting and interactive INPUT are excluded from
   CPU benchmarking. Use scripted fixed inputs, retaining interactive demos
   separately for usability checks.

## Interpreting the outcome

1. Shared arithmetic code suggests a smaller gain when its execution dominates,
   but compiled operand access, type selection and expression evaluation may
   still improve it. Integer kernels vary especially with operation choice
   and optimisation. Measure before assigning a percentage to either cost.
2. Strings, memory allocation and dynamic LOCAL restoration also retain runtime
   costs. Test leaf calls, nested calls and LOCAL restoration separately;
   GOSUB timings do not establish PROC/FN semantics or performance.
3. Branch studies need both outcomes, predictable/mixed paths, varied target
   distance and source/name-table sizes. Do not assume a modern branch predictor
   exists on eZ80. Investigate code layout, dispatch and search costs directly.
4. Emulation is useful for correctness and deterministic instruction counts
   where the tool actually supports them. Unlimited CLI wall-clock durations
   are host/tool measurements, not physical Agon execution times. No physical
   performance claim or human emulator validation follows from automated tests.

## Result record

For every measured sample retain: candidate/adaptation ID; source/input/output
hashes; engine and binary hashes; target/firmware configuration; data types;
timer and raw start/end/delta ticks; exact work count; timed-region definition;
warmup/cache state; repetition/order; validation result and checksums; memory,
stack/heap limits where relevant; code/runtime/total image sizes; and notes on
eliminated work or device completion. Preserve failed samples too. There are
no measurement records from C007: it searches and defines the corpus only.

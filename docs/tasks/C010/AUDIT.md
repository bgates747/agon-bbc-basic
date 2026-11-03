# Graphics statements and keyboard input

The candidate adds the four missing constructs used by the unchanged Mandelbrot
program: MODE, GCOL, PLOT and bare numeric GET. It emits native calls and VDU
bytes, using the already qualified BBC numeric conversion routines. It does not
copy interpreter statement dispatch, invent a numerical representation, or
change the Mandelbrot calculation. Qualification remains experimental until
recorded evidence and an explicit live promotion identify exact versions.

## Reference behavior and implementation

1. `src/agon_os.s` owns the actual reference MODE, GCOL and PLOT implementations.
   Their EXPRI/CEXPRI paths evaluate an expression and use SFIX before evaluating
   the following argument. The compiler emits existing numeric selector38 for
   each argument in that same order. It stores the resulting integers in its
   existing expression slots rather than relying on volatile CPU registers.
   Numeric errors therefore precede the following argument's side effects.
2. GCOL accepts one argument (action0) or two (action, colour). The reference
   emits VDU18 followed by the low byte of each converted integer. PLOT accepts
   two arguments (selector69) or three (selector, x, y). Its VDU25 packet contains
   selector low8 and two low16 coordinates in little-endian order. These byte
   truncations follow SFIX; they are not a replacement for its range checks.
3. MODE clears bit4 of MOS `sysvar_vdp_pflags` before evaluating its expression,
   emits VDU22 and the converted integer's low byte, and waits for that flag
   to be set by the VDP response. The candidate obtains IX through MOS selector8
   (`mos_sysvars`), uses the documented flag offset4, and preserves incoming IX
   on the CPU stack. It does not store an interpreter `MOS_SYSVARS` global.
   An argument error must unwind this temporary stack through the existing
   native error machinery. No timeout or alternate mode-selection policy is
   added to the language.
4. Bare GET follows `include/bbc-ez80/EVAL.Z80` GET/GETS and
   `src/agon_os.s` OSRDCH: MOS selector0 waits for a key and returns an unsigned
   byte. Byte27 raises Escape, error17. The candidate preserves IX/IY around the
   MOS call and stores an ordinary five-byte packed integer (four value bytes
   and integer tag0). It does not require interpreter COUNT/FLAGS state.
   GET(port), GET#, GET$ and keyboard configuration remain outside this scope.
5. Output uses the existing native RST.LIS10 path. The reference OSWRCH contains
   interpreter output-redirection/buffering state and cannot be extracted as an
   independent routine. This task does not claim new support for those output
   channels, or for related LINE/DRAW/COLOUR/CLG statements or PLOT BY.
6. The additions are BBC BASIC emitter source in the task's candidate. Existing
   vendored numerical code and its provenance/license remain unchanged. MOS
   selectors come from this repository's `include/mos.inc`; no new interpreter
   globals or statement-handler machine-code copies are linked.

## Test observation and its limits

1. The normal upstream CLI has a text-only fake VDP. It neither acknowledges
   MODE nor consumes GCOL/PLOT packets. Raw text stdout also drops zero bytes.
   This makes it unsuitable as a graphics-command oracle without a bounded
   observation adapter.
2. `prepare_observer.py` copies tracked files from Fab commit
   `c22876d1f7ad903537c308cf65afd6553b37cdb8` into ignored task build storage and
   applies the retained `wire-observer.patch`. Upstream files remain unchanged.
   Its CLI UART send path records each CPU byte before the fake VDP consumes it.
   The peer consumes complete GCOL/PLOT packets and acknowledges MODE with a
   screen-information response. Mode8 is320x240/64 colours; mode1 is640x480/4
   colours, following `agon-docs/docs/vdp/Screen-Modes.md`. Other mode responses
   are a dummy fallback and do not qualify their geometry or validity.
3. The copied emulator retains upstream GPLv3 licensing (`LICENSE`). The patch
   changes the host CLI peer, not eZ80 execution, MOS, the reference interpreter,
   the compiler, or numeric routines. It is a task-local test tool, not part of
   the consumer compiler package. Its exact executable/source hashes belong
   in each new evidence cohort; older CLI qualification is not relabelled.
4. `qualify_wire.py` runs actual pinned reference BASIC and actual generated
   native code. It compares complete bytes between explicit program markers,
   without normalizing coordinate bytes that happen to be CR/LF. Python only
   prepares source fixtures, launches tools, supplies keys and compares bytes.
   No Python implementation of the BASIC arithmetic or Mandelbrot is an oracle.
5. Neither this observer nor a matching command stream renders pixels. The
   Author's reference-only visual confirmation remains distinct from a future
   rendered test of the compiled program. Controller durations are not CPU
   benchmarks or measured interpreter/compiler speedups.

## Initial experiment lineage

1. `source-001` freezes the exact1038-byte Author-validated input. It has46
   numbered source lines, with a gap from390 to430. The planning log's49-line
   description was a counting mistake; source bytes/hash are authoritative.
2. The first interpreted candidate compilation wrote an18329-byte executable,
   then the controller waited for a MOS marker while BASIC remained at its
   prompt. That controller omitted `*BYE`. Preserve its partial record separately
   and obtain a complete fresh run before claiming normal completion.
3. `native-build-001` failed before CPU execution: the root fixture's old CLI
   symlink target under `/tmp` was missing. Its failure record is retained.
   The fixture now selects a project-local observer build through its canonical
   generated wrapper. The missing target's cause is unknown. Historical CLI
   hashes/evidence remain unchanged; the new selected tool is recorded afresh.

## Completed experiment evidence

1. `wire-probes-001`, `wire-bounded-001`, `wire-errors-001` and
   `wire-interactions-001` complete18 fresh reference/native pairs for candidate
   `13c2a488`: graphics packets and conversions, argument/error order, GET and
   Escape, expression temporaries, function/LOCAL recovery and bounded fractal
   work. `admissions-001` completes the unchanged full source compile and12
   output-preserving unsupported-form rejections. `repack-001` checks all ten
   generators and unchanged nine runtime templates. `hosted-baseline-001` passes
   all39 existing cases/15 executions, assembler oracle and repeat; its15 entire
   images and24 diagnostics/preserved outputs match the preceding live source.
2. `full-native-002` executes the unchanged full program, after interrupted
   `full-native-001` (host exit143, origin unknown). It completes328833 GCOL/PLOT
   pairs and2959501 graphics bytes, SHA256
   `2988ce82e7e7e18def677bcaa6f14ac7079b7b9c3a9442133defabb78b5fcc5f`.
   The key is supplied only after the final observed plot. MODE1 acknowledgement
   and actual MOS status0 follow. Its1214.525-second concurrent controller run
   is not a CPU benchmark. `full-reference-001` also completes, with the same
   counts and complete stream bytes. `full-pair-001` verifies both frozen
   manifests and exact equality. The reference's2505.852 concurrent controller
   seconds are likewise not a paired benchmark. Rendered acceptance is separate.
3. `visual-fixture-001` records an actual new-file Oryx copy/fsync/sync followed
   by a receipt-formatting NameError. The corrected helper does not replay that
   write: `visual-fixture-002` independently reads and verifies the full staged
   `mandelbrot-c010.bin`, SHA bad741db. Original source/root compiler/processes
   remain unchanged. Delivery is not a human result.
4. `native-build-002` also exits143 with unknown origin, after writing only
   256674 bytes. Its partial image, source, seed and console are retained;
   that image is incomplete and unqualified. `native-build-003` restarts from
   the same qualified seed and candidate with progress heartbeats and signal
   capture. The native pipeline uses separate owned profiles for self-building
   and serial regressions. Only completed evidence can satisfy promotion gates.

## Actual self-hosting fit blocker and private factoring

1. `native-build-003` completes in2261.251 controller seconds, producing329054
   bytes/SHA a59160c4 from13c2a488. Complete GNU runtime/entry/adapter checks
   pass. This compiler's normal prompts emit the unchanged18329-byte Mandelbrot
   image bad741db. Native baseline39, representative12 and all18 graphics/key
   pairs pass; the representative ten complete images match C006's old images.
2. The image grows4779 bytes and leaves96674 heap bytes. C005 recorded97366
   mandatory/observed self-source bytes before remaining overhead. Actual
   `native-self-001` reports `No room at line19216`, storing a new symbol name.
   MOS aborts autoexec before the controller's completion marker. After verifying
   this failure and the exact owned process arguments, send SIGTERM only to the
   waiting controller so it freezes the failure and closes its idle emulator.
   `self-fit-block-001` records that deliberate post-failure stop. The failed
   native pipeline retains its successful earlier stages without claiming
   self-hosting or promotion. No SD-card fault is inferred from MOS status text.
3. `growth-001` is a failed measurement fixture (missing PROClabel stub), not a
   feature failure. Corrected `growth-002` measures3642 additional native body
   bytes with constant stubs; the actual full329054-byte image owns fit evidence.
4. `make_fit_candidate.py` factors85 assignment-position counter/type resets,
   combines26 adjacent reset pairs and factors17 pure equal-index SFIX calls.
   Conditions are retained; the helper uses existing i% and existing typed
   fields. It changes compiler implementation code, not its runtime modules,
   numeric representation, language features or resource limits. Three reset
   helpers assign standard FALSE, integer0, to `%` fields. User decimal literals
   continue through the reference reader; target emission must remain identical.
5. Initial ac24edae (`fit-refactor-001`) preserves all15 whole baseline images,
   24 diagnostics and all12 unsupported-form outputs, and emits the same full
   Mandelbrot binary. The helper-only typed-zero refinement b8afbfdb is frozen
   separately in the fresh build input. `fit-hosted-baseline-002` and
   `fit-admissions-002` qualify that exact source with the same image/diagnostic
   equalities. `fit-repack-001` preserves its exact source under all ten packers
   and verifies unchanged nine runtime templates. Its native build and new
   self-fit/behavioral qualification remain separate gates.

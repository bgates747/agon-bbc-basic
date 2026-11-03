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

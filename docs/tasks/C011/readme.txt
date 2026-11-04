C011 paired BASIC benchmark fixture, version 1

This is an experimental Console8 fixture. No emulator has been run and the
fixture has not yet been compiled or executed on a target. Begin with the
pilot and supplementary checks. A compiler rejection or wrong state is a
failure to investigate, never a timing sample. No firmware change is needed.

All commands below are relative to the programming package root. Compiler.bin
in that root must be the supplied qualified compiler. Use the included
reference.bin rather than another BASIC version. The fixture is in benchmarks/.

1. Prepare the clock and compile on Console8

   CD benchmarks
   LOAD clock.bin
   RUN .

   Expected: clock.dat written. This helper obtains the MOS sysvars address;
   it does not set the clock. Run it again after reboot/MOS changes. It writes
   only clock.dat in the current directory. Use it only from this directory.

   LOAD ../compiler.bin
   RUN .

   At the filename prompts enter suite.bas, then suite.bin.
   Wait for Wrote and the actual return to MOS. Do not time compilation as
   benchmark execution. Then compile checks.bas into checks.bin the same way.
   Compilation duration has not been measured; these sources are much smaller
   than the compiler itself. Report any diagnostic with its line/column.

2. Supplementary correctness checks, before timing

   LOAD reference.bin
   RUN .

   At BASIC type:
   LOAD "checks.bas"
   RUN

   Expect core checks, deliberate error 123 / ERL130, error recovery, then type
   C011 and Enter and press Space at the next prompt. Expect PASS. Exit with
   *BYE. Run native checks with LOAD checks.bin then RUN . and repeat input.
   These checks create/overwrite checkio.dat in this directory. They check
   errors/input/key behavior without counting human waiting as CPU time.

3. Pilot paired suite

   LOAD reference.bin
   RUN .

   At BASIC type:
   LOAD "suite.bas"
   RUN

   Respond to the suite prompts:
   Result filename: ref001.csv
   Engine tag: ref
   First case: 1
   Last case: 42
   Scale: 1
   Measured repetitions: 1

   After Finished, exit BASIC with *BYE. Then:
   LOAD suite.bin
   RUN .

   Use nat001.csv, native, 1, 42, 1, 1 respectively. These are pilot logs,
   not precise performance samples. Sample zero is a logged warmup.
   Refuse to overwrite an existing result: use a fresh filename each time.
   Case/repetition progress appears between samples, outside their timers.
   Case37 prints inside its timer; case38 draws and restores MODE1 afterward.
   Cases35/36 use input.dat/scratch.dat. scratch.dat is overwritten each sample.
   No existing personal program or result should use the reserved scratch names.

   Run duration is not measured yet; no completion-time promise is available.
   The reference pilot may take minutes. For a shorter first check use cases
   1..4, then 5..13, 14..21, 22..31, 32..36 and 37..42 as separate paired logs.
   If a case stalls, record the case/sample and reset through your usual method;
   do not treat an incomplete log as a result. Escape is not generally polled
   by compiled CPU-only loops. A run does not silently time out.

4. Collect meaningful pairs

   First compare pilot results on Linux using the shipped analyse.py:
   python3 analyse.py ref001.csv nat001.csv

   Send both logs and any diagnostics to the maintainer. The analyser rejects
   incomplete/mismatched states, unequal work, incorrect raw deltas, and some
   independently known integer/string results. It does not decode BBC floats.
   It cannot verify your firmware, source identity or display output itself.

   Choose a narrower case range and increase the SAME scale for BOTH engines
   until even the native sample lasts at least 1000 centiseconds (10 seconds).
   Do not compare different scales as an equal-work pair. Case-specific runs
   avoid making the slowest case enormous. Scale must be 1..1000. If that is
   insufficient, report the case instead of editing only one program.

   Use at least 5 measured repetitions, with a warmup before each group.
   Alternate complete reference/native groups (AB then BA) in fresh files;
   repeat groups to see drift. The suite cannot switch engines by itself.
   Keep CPU/MOS/VDP/SD/mode and external activity unchanged. Record hardware,
   CPU clock, MOS/VDP versions, ordering and any unusual activity separately.

   Log tick start/end/delta fields are hexadecimal, preserving all integer
   bits. Units are MOS centiseconds. CLOCK records the minimum OBSERVED step;
   MOS commonly advances by 2 centiseconds per VBLANK. This is not a
   millisecond-resolution measurement. Long batches resolve average throughput
   better than the individual clock step. Verify clock behavior before claims.
   Startup calibrates eight observed advances, with a bounded polling count.
   A failed clock check invalidates the run. Reads are double-sampled and the
   low 31-bit wrap is handled; runs must be shorter than that wrap interval.

5. Interpretation

   Inspect coverage.md for the case map and exclusions. Cases14/15/16 vary
   dependent float multiplications per iteration; 39/40 vary integer operations;
   41/42 keep four integer operations but vary FN call frequency. Different
   final float results across density cases are expected; compare the SAME case
   between engines. Shared runtime work need not have identical dispatch cost.

   Cases32..34 are sixteen-point RAM-only Mandelbrot regions, reporting escape
   iteration totals and histograms. Determine density from those results; no
   key waiting or plotting is inside these kernels. The unchanged full-size
   Mandelbrot is still a separate end-to-end application test.

   File read/write are API-inclusive, with unknown cache state. Open/close and
   write validation are outside their timed regions. Graphics ends after PLOT
   calls enqueue commands: it does not establish rendered completion. PRINT
   includes formatting and screen service. Manually inspect these outputs;
   timing fingerprints do not verify all emitted characters/pixels.

   The timer hook and dispatch chain have engine-dependent overhead. Report raw
   times; do not automatically subtract case1. A speedup ratio alone cannot
   assign a percentage to interpretation versus numeric code. No emulator wall
   time or cycle profiling is part of this fixture.

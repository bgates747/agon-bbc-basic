# Compiler tests and benchmark sources

Use semantic tests to establish correctness and a varied benchmark corpus to
explain performance. The source-inspected catalogue covers control flow, calls,
variables, strings, arrays, numeric controls, I/O and realistic applications.
It is not yet an adapted executable benchmark suite; no performance comparison
has been measured.

The catalogue's original eligibility assessments describe the November 1 search
checkpoint. Since then C002–C005 have promoted the features in the compatibility
matrix, and workload W01 (the compiler itself) has completed C006 qualification:
four identical324275-byte emulator images, native regression suites and two
physical self-source generations. This is correctness evidence. Recorded test-controller durations
are not paired benchmark results; no physical speedup is claimed.

[C010](../docs/tasks/C010.md) also retains actual CPU execution of the unchanged
Mandelbrot source: reference and emitted native code produce identical2959501
graphics bytes for328833 plots, wait for a key, restore MODE1 and return normally.
The source and output binary are pinned, with complete raw streams and earlier
failed/interrupted attempts retained. The CLI observation peer does not render
pixels. Concurrent controller durations are not a paired performance comparison;
rendered/manual qualification and the current compiler promotion state remain
separate in the task record and compatibility matrix.

1. [Curated catalogue and source assessments](../docs/tasks/C007/CATALOG.md)
   — selected programs, correctness oracles, required features, adaptations,
   licenses and rejected leads.
2. [Measurement contract](../docs/tasks/C007/MEASUREMENT.md)
   — equal work, deterministic inputs, timing resolution, repeats, output
   validation and separation of CPU work from storage/display costs.
3. [C007 task record](../docs/tasks/C007.md)
   — search scope, checkpoint sequencing and retained provenance/evidence.
4. [Existing compiler qualification commands](README.md#automated-qualification)
   and [compatibility matrix](COMPATIBILITY.md) — what actually runs today.

Candidate references such as B01 are catalogue identifiers, not unfinished
tasks. Compiler feature work remains in the single [TODO](../TODO.md). Later
adoption should preserve upstream originals, identify every adaptation and
retain correctness results before timing. Curating a source does not enable
its language features or claim human emulator/hardware validation.

The Author reports successful Console8 compilation and execution of Mandelbrot,
with a qualitative gain in less computationally intense regions and inconclusive
comparison in intense regions. [The retained report](../docs/tasks/C008/evidence/author-mandelbrot-001/report.md)
is human functional evidence, not a measured speedup.
[C011](../docs/tasks/C011.md) proposes broad matched kernels, arithmetic-density
sweeps, service-separated applications and a verified timing harness.

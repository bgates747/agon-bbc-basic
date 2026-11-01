# Compiler tests and benchmark sources

Use semantic tests to establish correctness and a varied benchmark corpus to
explain performance. The source-inspected catalogue covers control flow, calls,
variables, strings, arrays, numeric controls, I/O and realistic applications.
It is not yet an adapted executable benchmark suite; no performance comparison
has been measured.

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

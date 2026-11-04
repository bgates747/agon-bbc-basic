# Development native compiler

This BBC-written compiler runs directly under Agon MOS in eZ80 ADL mode. Its runtime is included; no installed interpreter or assembler is required.

Load `compiler.bin` with MOS LOAD, then use `RUN .` and enter the source and destination filenames. Run the emitted program with MOS LOAD and `RUN .`.

This build adds MODE, GCOL, PLOT and bare numeric GET for the unchanged Mandelbrot program. Automated reference comparisons, baseline/native regressions and a byte-identical native self-build qualify its documented [subset](../COMPATIBILITY.md). Full-program VDU streams match the reference. Rendered/human, physical and performance results for this version remain unclaimed. Earlier physical results describe the older version recorded separately in the manifest.

See [C010](../../docs/tasks/C010.md) for exact qualification and retained failures, [runtime provenance](../runtime/vendor/PROVENANCE.md) and [LICENSE.txt](LICENSE.txt) for original authorship and notices.

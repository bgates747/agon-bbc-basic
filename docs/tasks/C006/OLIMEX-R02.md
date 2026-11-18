# C006 physical repeat c006-r02

This record retains inputs for the completed second hardware generation using
the unchanged compiler actually produced by the first physical self-compilation.
The5400s first observation failure and separately captured late completion remain
distinct historical evidence. This file contains no bench operating sequence.

## Frozen inputs and timing basis

1. Bundle: `docs/tasks/C006/evidence/olimex-repeat-fixture-001/`, manifest SHA256
   `b5d0761fc88e512f32d14217a8ee2de997e05e412edafc3c8236bd2101128e24`.
   Three uploads total436261 bytes:111810-byte source,324275-byte actual
   hardware-produced compiler and176-byte MOS batch. Historical deployment comparisons are retained with the run results.
2. Source SHA6597a0df is unchanged. Executable SHA299a3119 is copied byte for
   byte from olimex-self-a-late-001/output.dat, with its full manifest, hardware
   derivation and clean release checked by prepare_olimex_repeat.py. No compiler,
   runtime, numeric representation or machine-image transformation occurs.
3. The first physical invocation's last captured completion/listener chunk
   follows final filename-emission return by5951.332 host seconds (about99.2
   minutes). Its full-image GET takes251.948 host seconds. These are one retained
   mirrored host/serial/listener observation and transfer, not CPU or benchmark
   measurements, a calibrated maximum or a guarantee of the repeat's duration.

## Bench procedure

Use only the [authoritative Olimex bench guide](../../../../agon-extender/docs/operations/olimex-bench/README.md).
The former local operation/stop/restoration sequences have been removed.
Actual results remain in the C006 task and evidence cohorts.

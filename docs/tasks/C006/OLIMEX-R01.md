# C006 physical qualification run c006-r01

This finite run tests the qualified native BBC-written compiler and its outputs
on the shared Olimex, without changing installed firmware or normal startup.
This document retains historical workload inputs, not operating instructions.

## Inputs and memory

1. Bundle: `docs/tasks/C006/evidence/olimex-fixture-001/`. Its `manifest.json` pins
   every payload, expected result, case specification and command file. The
   preparation tool admits only completed four-generation, baseline39,
   representative12 and error39 evidence with matching source/image identities.
   Manifest SHA256:
   `05149bd76c5f23f8f6bf97c8db7bde3871e858a1e579a55784f05dd3a84d4787`.
   There are40 uploads/441398 total bytes, including111810-byte source and
   the324275-byte compiler. Ten expected program images total102941 bytes.
   Planned generated-image retrieval adds648550 bytes for the two self-compiles,
   two preserved42-byte rejection outputs and the5-byte file fixture.
2. Source SHA256:
   `6597a0df3f99b4f43c42bff1cdbc59f5fdf730c57837f3d4112a598fbfbe5fb8`.
   Standalone compiler:324275 bytes, SHA256
   `299a31190c380541a73ed9eb144a303fa37abccc4f3c3e0ad47f99f1538122c0`.
3. The full static image (including emitted runtime, initialized control frames,
   scalar storage, expression pools and string workspaces) occupies
   &40000..&8F2B2. Private heap is&8F2B3..&A7EFF (101453 bytes), activation
   arena&A7F00..&AFEFF (32768 bytes), guard&AFF00..&AFFFF (256 bytes).
   There is no additional application BSS above this bound or in MOSlet memory.
   Self-source output is streamed to a file rather than buffered in RAM.
4. Entry preserves/restores the inherited MOS ADL stack/registers; the runtime
   does not install a private CPU stack or change interrupts/MBASE. Actual
   generation equality proves this workload on the pinned CLI, not installed
   EMOS stack high-water or arbitrary recursion safety. No worst-case CPU stack
   usage has been measured.

## Bench procedure

Use only the [authoritative Olimex bench guide](../../../../agon-extender/docs/operations/olimex-bench/README.md).
The former local operation/stop/restoration sequences have been removed.
Actual results remain in the C006 task and evidence cohorts.

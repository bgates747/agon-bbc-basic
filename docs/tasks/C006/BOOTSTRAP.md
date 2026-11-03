# Native self-compilation contract

The bootstrap experiment must execute the actual BBC compiler on Agon memory,
first under pinned BASIC and then as its own native executable. Host Python may
copy inputs, type filenames, collect logs and compare bytes. It must not compile
BASIC, patch generated code or replace numeric values. C005 resource/language
closure remains a prerequisite; preparing this workflow is not a successful run.

## Generation and evidence boundary

1. Copy one exact promoted compiler source to the isolated CLI SD fixture as
   `self-source.bas`. Use its unmodified normal main program and prompts.
2. G0: the pinned reference BASIC loads/runs that source, receives filenames
   through actual MOS line editing and writes `self-g0.bin`. Exit BASIC through
   its ordinary BYE command after the compiler's success message.
3. G1: MOS loads/runs `self-g0.bin` as a standalone program, supplying the same
   source and `self-g1.bin` through its prompts. Require MOS status0 and success.
4. G2: run `self-g1.bin` on the same source to `self-g2.bin`, then repeat that
   invocation to `self-repeat.bin`. Require all four complete images to match,
   including generated headers, code, relocations, DATA and zeroed workspaces.
5. Retain exact source, three generation/repeat images as `.dat`, commands,
   keyboard/console logs, durations, input/runtime/CLI/MOS hashes and result.
   Record interruption/failure as such; do not infer later stages from G0.
6. Native generations must run representative retained compiler regressions,
   including output preservation on rejected source. The regression driver may
   type one compiler invocation at a time, never substitute a Python compiler.
7. The CLI runs sequentially through the existing generated wrapper. Oryx is
   unavailable. Automated timing is controller time, not physical performance.
8. Physical qualification requires a separate exact fixture and operator/device
   evidence. Preserve the established card location if one exists, include the
   hardware-readable runbook and required firmware identities, synchronise and
   leave a transferred card mounted. No firmware flash or hardware result is
   implied by software generation or by the Author's approval-stage waiver.

## Prepared regression drivers

`regressions.py` drives representative numeric, control, FN/LOCAL, array,
indirection, DATA, file and rejection fixtures through the normal native UI.
`native_errors.py` reuses C005's39 exact numbered reference programs, compiling
and executing each through an actual native compiler, then checking its complete
runtime links and a deterministic repeat. Both retain per-program console logs
and supplied source/native hashes. These are prepared workflows, with no executed
native-generation or regression result yet. Supplied file identities do not by
themselves prove derivation; the generation chain owns that evidence.

The interpreted G0 driver now aborts on an unexpected BASIC prompt before either
filename prompt as well as after both filenames. A PROCinit failure must be
reported promptly rather than waiting for the full generation timeout. This is
prepared failure handling; no native generation is implied. Native early exits
are already detected when the MOS completion marker arrives before pending input.

Read-only Pi5 deployment inventory at2026-11-02T23:51-05:00 found the development
SSD, Pi boot/root card and swap only; no mounted Agon FAT card or established
project hardware fixture was present. No transfer, flash or hardware execution
occurred. This observation does not block automated C005/C006 qualification and
does not constitute a physical test result.

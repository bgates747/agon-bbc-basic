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

The prepared bootstrap controller saves input identities and attempted-stage
state before invoking each compiler. It emits a host-only liveness message every
30 seconds and records SIGTERM when possible; this does not indicate eZ80
progress or performance. The BBC source and normal main remain unmodified.
This records host-controller preparation, not an executed generation result.

The optional --resource-preflight C005_EVIDENCE_DIRECTORY mode verifies a completed
resource run's exact source/image identities and executes one native self-source
compile through the normal native UI. It compares that result with the resource
seed and records that unmodified interpreted main was not executed. This is an
early native RAM/functionality check, not a replacement for the full default
G0/G1/G2/repeat chain. The mode cannot accept an interrupted resource run as seed.

`native_baseline.py` additionally drives all39 standard baseline source files
through the generated native compiler's normal UI. A fresh frozen reference
baseline supplies15 complete expected images and24 exact diagnostics; old
output must survive every rejection. Image equality carries that reference
cohort's independent assembly/runtime execution evidence without claiming a
second native-program execution in this comparison. This supplements the12
representative native-execution cases and39 fresh source-error programs. The
new comparator and full-source baseline freezer are prepared, syntax checked,
and await their first fresh live-baseline inputs.

For the full chain, `--expected-image` can pin the independently checked resource
image. The controller retains that exact file and stops on any differing complete
generation before executing a successor. This adds a byte-identity gate without
changing the BBC main, source or generation stages. The first full-chain run will
use the qualified resource seed; this new controller path is prepared only.

The representative file case removes its own old scratch file before execution,
verifies all five bytes (255 followed by text), and retains the actual output
for physical comparison. This is prepared orchestration; its first native run
is still pending the generation chain.

C006 packed-native-preflight-001 completes native self-source compilation through
normal prompts in1983.653 controller seconds, MOS status0. Its entire324275-byte
G1 equals the interpreted resource seed SHA299a31190c380541a73ed9eb144a303fa37abccc4f3c3e0ad47f99f1538122c0.
Exact6597a0df source and source/seed/output/console/controller identities are
retained. Actual native initialization, source metadata/storage and all output
passes fit; the lower-bound estimate is no longer the sole resource evidence.
This preflight did not run unmodified interpreted main and does not replace the
full default four-image chain, native regressions or physical qualification.
No hardware or performance benchmark result is claimed.

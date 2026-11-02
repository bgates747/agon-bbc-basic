# Compiler development — 2026-11-02

The scalar/string task is complete for its initial scope. Exact slice-assignment
promotion passes live checks; structured control flow is next under C004.

## C003 accepted and removed from TODO

Live checks pass baseline39/15 (31.456s), slice-write example (31.166s), ABI
(1.016s), 11-string/three-integer raw memory (41.772s), strings (25.561s),
search/repeat (38.786s), slices (38.289s), limits (49.105s), core/slice ABI
(1.032s/1.077s) and conversions (64.815s). Full prototype27/19 native/eight
rejected remains separately frozen. Exact compiler SHA928a46a060fa8b72dbbbc40484561c67b6736ba5cf69eaa7ced932e5409a8617
and 623-byte/two-relocation runtime are promoted; numeric vendor/adapter unchanged.

C003 is accepted for its initial scalar/string scope, with ownership, bounds,
no-allocation slice writes, deterministic output and prior regressions qualified.
Removed C003 from the sole TODO. Arrays/I/O remain C005 and LOCAL C004.
The Author authorized checkpointing and continuing without prior approval stops.
No Oryx contact, human/hardware validation or benchmark is claimed.

## C004 conditionals started

C003 checkpoint020546f is committed/pushed. Reference-only IF probes establish
SFIX truth and first-ELSE association through nested inline IFs. The BBC prototype
emits native jumps, with bounded multiline/inline parser state and unchanged
numeric/string runtime. Initial mixed smoke passes (22.894s). A full compile
caught an inserted source line numbered after its containing ENDPROC, causing
ELSE-line targets to be rejected. Corrected its number/order, added a loader-safe
source check to the harness and retained the failed attempt separately. Full
qualification repeats; this is not yet a live promotion or C004 completion.

## Conditionals qualified and promoted

All26 programs pass (17 native/nine rejected) in152.941s, with15 actual-BASIC
reference cases. Baseline39/15 passes at prototype33.146s and live33.142s; exact
source SHA21c91592682d25b3516ded16230432942b54085efa61d403989ac929ad4b25e7
is promoted. Live conditional smoke21.758s and slice-write regression33.114s pass.
Frozen evidence retains both scopes and the earlier loader-order correction.
Unchanged numeric/string runtimes and original golden protect earlier behavior.
C004 remains active; the next prototype introduces typed loop/GOSUB records.

## Typed loops qualified; live rechecks running

The loop prototype passes32 programs (20 native/12 rejected,14 same-source),
20 independent controller links and entry/numeric bridge checks in313.131s.
Six supplemental cases pass in117.440s, baseline39/15 in46.754s and ABI in1.016s.
Six numbered reference probes confirm GOSUB/loop marker error expectations.
Frozen SHA2890c6be59a6b9015c69809ad9cb47efedfabacb543d025da3745718dee5b370
and the8657-byte/30-relocation controller are promoted exactly. Three DATA
packers reproduce source; string packaging preserves the new40000 section.
Live baseline/loop/ABI/conditional/string checks run before checkpointing.

Preparatory PROC/FN/LOCAL oracles establish staged arguments, prior formal
snapshot, unsuffixed string results, LOCAL creation/restoration and exact marker
errors/declaration fall-through. Their audit and fixtures are in C004/activations;
no activation implementation is claimed.

## Typed loops accepted for development

Selected live checks pass baseline39/15 (44.552s), loop smoke49.677s, ABI1.015s,
conditional smoke31.064s and slice-write smoke43.676s. Independent links/bridge/
entry reset pass. Exact promotion and three packers reproduce1245 loader-safe
BBC lines; numeric/string/vendor/license remain unchanged. Full and selected
scopes remain separate. Checkpoint this tranche, then continue PROC/LOCAL/FN
under C004 without an approval stop; C005/C006 remain in the sole TODO.

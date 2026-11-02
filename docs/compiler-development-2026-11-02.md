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

## Scalar PROC/LOCAL prototype started

Checkpoint786909e is committed/pushed. Preparatory actual-BASIC probes guide a
502-byte/27-relocation standalone helper with explicit PROC/LOCAL markers and a
bounded32768-byte private arena after emitted code/string workspace. Native ABI
passes in1.015s: staged binding, nested restoration, new bindings remaining
created, full strings, exact arena bound and IX/IY/SP. The BBC prototype prescans
forward signatures/scopes and compiles argument staging/LOCAL/ENDPROC. A swapped-
argument smoke matches BASIC in125.828s. Full tests run next; no promotion yet.

The first smoke fixture incorrectly crossed a procedure label boundary and was
corrected; its rejected attempt is retained. The reference harness now permits
separate fixture main/declarations so native END does not terminate the complete
reference batch. Statements and declarations are unchanged, only reference
fixture packaging differs. Old baseline LOCAL/DEF rejection fixtures are replaced
with still-unsupported CALL/SYS; dedicated positive/error PROC/LOCAL cases now own
those features. FN remains unsupported in this initial activation tranche.

## Scalar PROC/LOCAL accepted for development

Full28 programs pass in442.674s, supplemental8 in154.299s, baseline39/15 in55.857s
and native ABI in1.015s. All15 full native controller/procedure images match GNU
links and bridge/entry/arena checks. Promoted exact SHA7d6d6abcede0e294c5ea0017cd49fbc59674e51c992b53b42c47d520ba169c96
and502-byte/27-relocation helper. Four DATA packers reproduce source. Live passes
baseline55.860s, PROC109.848s, ABI1.015s, loops60.113s, conditionals37.000s and
slice-write52.537s. Exact evidence remains distinct from full prototype scope.
Checkpoint qualified work, then continue FN under C004. FN783-byte prefix-save
runtime experiments have direct ABI results but no compiler promotion yet.

## FN result/caller-prefix tranche started

Qualified PROC/LOCAL checkpoint520e05e is committed/pushed. The FN prototype
infers actual result kinds (including unsuffixed string functions) and stages
recursive/nested calls while saving live five-byte numeric and256-byte string
prefixes in its arena. The extended helper is783 bytes/58 relocations. Direct
prefix ABI passes in1.016s (poisoned upper BC, zero/null pools, nested prefixes,
LOCAL restoration, marker distinctions and capacity); the prior PROC ABI also
passes against it in1.016s after correcting relative-path report packaging.
Initial numeric/string/pending-expression smoke matches BASIC in88.631s.

The full25-case attempt was interrupted after compilation, before its final
repeat/native phase. Confirmed no remaining fixture process, preserved partial
inputs/logs and resumed using a fresh BBC repeat plus all15 native outputs.
Fourteen matched; the string case exposed a real reference discrepancy at
ASC RIGHT$(FNnul). This run is failed evidence, not full qualification.

## FN accumulator-carrier finding and scope refinement

Actual pinned-BASIC probes show RIGHT$(FN returning "ABC") selects the original
first byte, while explicit count1 selects the last. STRING$(2,FNa) can expose
prior accumulator bytes: "ABC456" after a prior "123456" assignment, and "ABCXYZ"
after "UVWXYZ". Concatenation with an empty string re-establishes ordinary results.
Source inference identifies consumers relying on DE's complete accumulator
pointer, which FNEND does not explicitly restore. Exact stray-write addresses
are not claimed. Retained probes and compiler/INTERPRETER-FINDINGS.md separate
possible upstream corrections from compiler compatibility policy.

The compiler now tracks unqualified direct FN string carriers through parentheses
and omitted LEFT$. Omitted RIGHT$ and STRING$ reject those carriers clearly;
assignment/reload, concatenation and explicit slices remain admitted. The original
mismatching source is retained as an explicit rejection case, with independent
positive explicit-count coverage. No reference oracle was changed and no FN code
has been promoted. A revised full28-case qualification is running. The live
compiler remains the qualified scalar PROC/LOCAL checkpoint.

## C004 accepted and removed from TODO

Revised FN28-case scope passes in610.517s (15 native/13 rejected,14 reference);
five supplemental cases in220.521s; both ABI probes in1.016s; baseline39/15 in
62.201s. Exact source SHA6feb0b21b09ac4353347876df89043caf8800727b5a8c4f985588c3e6741c8f4
and783-byte/58-relocation helper are promoted, with four packers reproducing
source. Live baseline62.234s, FN91.636s, carrier4-case84.796s, ABI1.027s,
PROC125.245s and loops67.055s pass. Three further string-consumer/slice-RHS
programs pass in224.858s, including target reallocation and pre-RHS existence.

C004's selected structured flow/scalar PROC/FN/LOCAL scope is complete. Preserve
explicit static-kind and carrier exclusions, failed/interrupted evidence and
unchanged earlier runtimes. Remove C004 from TODO. Continue C005's source inventory
and bootstrap closure under the Author's authorization; no Oryx/hardware/benchmark
claim is made. Preliminary source inventory counts140 definitions against the
current128-definition cap, plus arrays, memory access, DATA, I/O and error facilities.

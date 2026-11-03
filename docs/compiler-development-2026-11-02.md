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

## C005 inventory and first bootstrap gap

Checkpoint37a5a0a (completed C004 initial scope) is pushed. Static source inventory
counts140 routines (109 PROC/31 FN). An actual interpreted compiler-on-source
probe rejects physical line1073 at the128-definition cap in295.201s, preserving
existing output. The C005 brief/PLAN define capacity, arrays/indirection, DATA,
MOS I/O, error recovery and measured memory closure before implementation.
First raise signature capacity to256 and identify the next actual gap.


## C005 initial resource checkpoint qualified and promoted

The capacity-only self-source probe reaches Unsupported statement ON in780.740s;
this is not self-hosting. The bounded633-byte string helper passes native ABI
1.068s, FN smoke92.787s, three string-consumer programs230.767s and baseline62.095s.
The256-routine batch produces two complete images and expected rejections before
its900s guard during a fresh repeat; retain as partial, not passed.

A BBC sorted integer symbol index preserves insertion/address order. Revised
five-case qualification passes in611.470s with256 routines, empty/max/NUL FN
results,257/DATA rejections, native execution, repeat and independent links.
Both complete images match the linear-lookup outputs byte for byte. Baseline
39/15/GNU golden passes66.030s. Exact1564-line SHA0f0884ca is promoted with
633-byte/two-relocation strings; four runtime packers reproduce it. Live passes
baseline65.921s, resource smoke102.772s and carrier4-case74.472s. No other
runtime/vendor/interpreter source changes; no hardware or benchmark gain claim.

## C005 array helpers and corrected reference audit

An experimental734-byte/83-relocation allocator/array helper independently links
and passes native ABI1.016s, including65537-byte zeroing, exact bounds/overflow,
widths/strides,16 dimensions, early checks, failure atomicity and IX/IY/SP.
No array/DIM/indirection syntax is promoted. Initial reference21 cases expose
wrong assumptions: repeated DIM evaluates subscripts and can give Syntax16 after
mutating an element; raw DIM seeds the target with its address's low16 bits, not
zero. Clean30-case follow-up confirms that relation, variant marker0 and survival
of a RHS-mutated high byte after the low24 pointer store.

The first extended reference run stalls at nested DIM and reaches its180s guard;
retain the29 complete observations as partial evidence, not a passed batch. The
clean follow-up omits that case and passes. ARRAY contract and unintegrated BBC
frontend must preserve these quirks and explicitly reject unqualified FN/address
expressions in array DIM bounds. Interpreter findings are separate upstream ideas.
C005/C006 remain the only unfinished TODO entries. Continue implementation under
the Author's authorization; Oryx is not contacted and no human gate is invented.

## C005 arrays/memory qualification and promotion

The corrected BBC frontend and734-byte/83-relocation standalone runtime preserve
raw DIM's address seed, low24 final store, repeated-DIM side effects/errors and
per-index evaluation checks. Full53-case differential scope passes40 native/13
rejections. Binding stress exposes2048-fixup exhaustion before256 bindings;
measured host headroom supports raising only four tables to4096. Exact final
1777-line SHAd0368b1e passes the full53 again, binding5 scope1289.261s,
baseline71.307s and FN83.489s. Five packers reproduce it. Exact live baseline,
memory and loops pass71.907/145.424/70.781s controller times. MEMORY.md and
curated manifests retain evidence; no human/hardware/self-hosting/benchmark claim.

MOS I/O preparation independently passes native file ABI1.016s and keyboard-driven
line input10.377s; actual13-case BBC file reference passes1.607s. Direct FN
filenames expose a full-DE pointer dependency and require explicit qualification
or rejection. IO.md/DATA.md own the bounded contracts. No I/O language promotion
is claimed yet. Continue C005 and C006 under the Author's authorization.

## C005 file/input qualification and next bootstrap contracts

Exact1849-line SHA483e1730 passes29 sources (23 native/6 rejected) in706.307s,
deterministic repeat and all numeric/string/I/O GNU links. Actual MOS keyboard
INPUT LINE matches reference ordinary/empty/255/default prompt67.855s; existing
39/15 baseline/golden76.161s. Same-session END/fall-through/uncaught-error cleanup
returns all eight handles59.299s. Exact source and788-byte/7-relocation I/O module
are promoted with their packer; selected live checks are recorded separately.

First full reference batch stalls at a255-character path. The variable follow-up
also stalls; direct native helper and aligned MOS probes return. Retain failed
bounded observations, exclude from passing scope, and record the boundary rather
than invent equivalent results or change interpreter code. The first smoke's
language suite passed, but its link lookup asserted on a relocated prefix; fixed
lookup proves full module equality. Full corrected controller passes.

DATA18 reference cases1.606s and native helper ABI1.016s establish empty fields,
raw text, deferred errors and captured-cursor commit. A BBC frontend is prepared
but unqualified. Error9+8 reference cases1.105/11.436s establish discarded LOCAL
values, retained earlier locals, handler persistence, LOCAL ERROR no-op, fatal
zero/OFF and REPORT/ERL behavior. No source-handler runtime is implemented yet.
STREAMING.md records measured-host versus native resource distinctions and the
static1958-numbered-line/symbol cap gap. C005/C006 remain the only TODO entries.

Selected exact live I/O smoke passes123.702s; `io-promotion-001` retains two
native images, repeated output, reference logs and complete GNU helper links.
All six packers reproduce the promoted source (`io-repack-001`).

## C005 DATA smoke and interrupted full qualification

Prototype SHA55643c54 (1962 lines,120-byte position-independent DATA helper) passes
smoke2 in170.554s. Reference fixture corrections preserve actual CLEAR/DATPTR and
signed-min READ behavior; conservative mixed-field admission remains explicit.
Full32-source compilation yields22 images/10 intended rejections, then the host
controller ends143 before reporting its final phases. Native PID1/systemd owned
process inspection finds no surviving CLI; cause is unknown. The retained partial
and exact driver/source checks precede resume_data.py's fresh repeat and all native
outputs/GNU links. No full pass is claimed before those finish.

A1511-byte/116-relocation standalone error adapter independently links. Its native
ABI probe is prepared but not executed yet; source handlers remain unimplemented.
Conventional ERL uses BASIC line numbers; the proposed unnumbered dialect returns0,
while compile diagnostics retain physical positions. Default uncaught formatting
must preserve the observed leading CRLF/message/optional line/trailing CRLF.

## C005 DATA qualified and promoted; error adapter ABI

Source SHA55643c54 completes32-case scope (22 native/10 rejected) after verified
resume. The shared EOF fixture's wrong expectation is corrected using3 isolated
reference programs (1.016s), without compiler/numeric changes. Fresh repeat and
all outputs/links/bridges/DATA entry resets/arena checks pass. Final3.477s is only
resume validation/execution/link time, not full compilation. Baseline80.355s and
exact live smoke170.183s pass; seven packers reproduce it. DATA.md records exact
120-byte PIC promotion and all partial/failed fixture evidence.

Error adapter1511 bytes/116 relocs passes native ABI1.020s, including current lost
max/empty/repeated string ownership, root/loop install, nested transfer, normal
retained-local restoration, handler persistence and fatal/NUL/line formatting.
Its BBC frontend is prepared; source-handler language is still unimplemented.
Continue C005 errors/resources and C006 under the Author's authorization.

## C005 source-handler integration and first cohorts

An experimental BBC frontend wires ON ERROR/LOCAL/OFF, LOCAL ERROR no-op, ERROR,
REPORT, ERR/ERL, source marks and normal caller-location restoration to the native
adapter. Initial2 smoke163.859s and6 programs374.876s pass, but a fresh initial
REPORT probe exposes a missed startup quirk: the pinned copyright notice and two
line endings, with ERR/ERL0. Retain it, including2025. Revised1559-byte/118-relocation
helper ABI passes with actual notice printing. A fast prescan filter retains the
same token checks. Source SHA5a8cc4f6 passes the first6-program cohort357.251s and
full GNU/runtime/entry/bridge validation. Further cohorts remain unqualified;
live compiler stays at the accepted DATA checkpoint053fd83.

## C005 REPORT token-output dependency identified

The full MAIN.Z80 TEXT/OUT audit exposes token expansion in REPORT, beyond NUL
termination. Actual7-case probes1.016s confirm keyword/error-fragment expansion,
LF exception and NUL behavior. The raw-byte reporter missed this dependency.
A private858-byte KEYWDS table is byte-verified against the reference image and
retains notices/license. Corrected2481-byte/126-relocation standalone helper and
ABI1.017s preserve initial notice, token output, fatal line formatting and earlier
ownership/stack checks. Source SHA8bb1dd9a remains experimental. Prior1559-byte
cohort6..11 passed302.222s after repairing a fixture's compile-time-excluded direct
FN message with concatenation; no numeric/compiler behavior changed for that fix.
Final cohorts rerun the corrected reporter before any live promotion.

## C005 final error cohorts and isolated resource preparation

Exact source SHA8bb1dd9a passes final0..5 (374.981s),6..11 (319.755s) and12..17
cohorts, each with fresh per-program BASIC oracles, deterministic repeats and
complete independent runtime/entry/bridge checks. The current checker additionally
links optional DATA/I/O modules when present. Later cohorts remain running; no
error-language live promotion is claimed yet. Real Escape/file-cleanup and a
128-byte REPORT-token sweep are prepared as additional qualification.

An isolated pure-BBC streaming candidate in C005/streaming replaces the code/
fixup buffers with layout, validation and direct-output passes. Static reference
bitsets and explicit final aliases/entry chaining remove unused numeric-label
pressure. It retains256 bindings,4096 symbols and204 definitions; static248 private
names are an inventory, not a self-compilation or RAM result. Prepared resource
fixtures include >65536 output,2048 labels and4097-label rejection. No runtime or
live compiler changes accompany this unqualified candidate.

C006's BOOTSTRAP.md and bootstrap.py now prepare exact unmodified-main interpreted,
native G1/G2/repeat execution through actual line-input prompts, complete image
comparison and retained failed/interrupted stages. C005 closure remains pending;
no C006 generation or physical result has occurred. A backwards-compatible optional
keyboard abort check distinguishes a failed BASIC return from waiting for a success
message; it is not a new emulator configuration or hardware deployment.

## Actual WHILE error-line quirk and correction

Final cohort30..33 compiles and repeats but fails its last native comparison:
reference direct WHILE re-evaluation error is18:60:1, native18:40:1. Preserve the
failed four images/oracles/logs. Five additional actual probes1.069s and ENDWH1 /
CURLIN audit show that a direct condition failure belongs to ENDWHILE, but a
normally returning FN in that condition resets attribution to WHILE. Same-line
WHILE/REPEAT/FOR body failures name that body line. Do not replace these oracles
with an idealised source location.

Source SHA44533e0d changes only11220 to skip the extra entry mark for WHILE.
Existing FN-return and ordinary body marks are retained. The runtime stays2481
bytes/126 relocations; earlier non-WHILE cohorts remain scoped to SHA8bb1dd9a.
Corrected30..38 cohorts are running, including a128-high-byte REPORT sweep and
four supplemental loop attribution cases. Source handlers are not promoted yet.

## Corrected error source and unchanged-image checks

Exact SHA44533e0d passes corrected30..35 in344.702s and36..38 in196.539s, each with
fresh numbered oracles, repeat and complete runtime links. This includes all128
high-byte REPORT values, direct ENDWHILE attribution, FN-return attribution and
same-line WHILE/REPEAT/FOR bodies. Recompiled24/25 complete images equal their
retained SHA8bb1dd9a images. Source-diff proof is exactly the11220 WHILE conditional;
all earlier0..29 sources contain no WHILE, so that emission path is unchanged.
The old and new exact-source scopes remain explicit in evidence, not relabelled
as a wholesale rerun. Nine exclusions/output preservation and quoted-word compact
output pass98.501s. Modern unnumbered/named-label ERL0 programs also pass; actual
Escape/file recovery, baseline and self-source-gap checks remain in progress.

## Held Escape dependency and bounded native polling

Real keyboard Escape first yields reference17:30:old versus native17:40:old.
Retain failure and trace OSLINE/LTRAP1, keyboard state and XEQ/TRAP: a held key
can retrigger at the handler's CURLIN. A direct MOS probe returns1B:1B:01 after
editline. Add a49-byte sysvar polling helper and mandatory handler entry mark,
without importing interpreter FLAGS/state or changing the old2481-byte module
prefix. Independent rebuild proves that prefix identical. New2530-byte/128-reloc
ABI passes1.068s; exact BBC source SHA7cac4bba remains experimental.

The I/O cohort's native Escape now matches reference; an old literal40 assertion
then fails despite equality. Verified resume and corrected relocation-safe IO
signature complete actual keyboard, retained-handle BGET and eight-handle exit
checks8.127s (resume/UI/link time only, excluding compilation). CORE6 and baseline
follow; general asynchronous Escape outside line input/handler entry remains
unqualified. Earlier39-case scopes retain their exact older source/runtime hashes.

## C005 source handlers promoted; source-capacity probe running

Exact2111-line source7cac4bba passes current CORE6 in386.004s, modern ERL0 cases
136.623s and the39-case/15-native baseline/golden86.851s. It promotes verbatim with
2530-byte/128-reloc errors.s, the licensed keyword include, runtime packer and
assembly-data generator. Eight packers plus the generator reproduce exact source.
Prior39 conventional observations keep8bb1dd9a/44533e0d scope; no wholesale rerun
on7cac4bba is invented. ERRORS.md records targeted held-key evidence and original
module prefix proof. C004's excluded LOCAL ERROR fixture changes to LOCAL DATA
because the former is now supported as its actual no-op.

The actual self-source capacity probe is running separately with unchanged7cac4bba.
Streaming candidate d2ba9abb (2149 lines,205 definitions,248 static private names)
remains unqualified and isolated; no self-compilation is claimed. C006 generation
and native-regression drivers are prepared only. Continue resource closure and
self-generation under the Author's standing authorization; no Oryx, human emulator,
hardware or performance result has been claimed.

## Development checkpoint and measured fixup failure

Error-handler checkpoint f486d09 is committed/pushed to codex/native-bbc-compiler;
main is unchanged. The exact7cac4bba self-source probe returns its actual first
failure at physical line108,column26: Too many address fixups. Old output remains
unchanged. Controller duration1459.137s; no native compiler is generated. The
original probe inputs were committed while it was running; result/log/manifest
are appended without changing those inputs. This is a resource failure, not a
self-hosting result or performance benchmark.

The isolated streaming candidate fc67e57c counts/validates/writes separately,
merges template operands through raw spans and advances ordered definition scopes.
It remains unexecuted. Old/new smoke images and resource/scope failures are its
next qualification; no inferred native RAM fit or source closure is asserted.

## Streaming smoke byte identity

Promoted-buffer emitter comparison passes five-source scope98.736s. Candidate
fc67e57c then passes the same four executions/one rejection206.272s, including
fresh conventional branch/scope/DATA oracles, deterministic repeat, linked numeric /
string templates and existing-output preservation. All four complete old/new
executables are byte-identical (including14845-byte control/activation and DATA
entry/workspace cases). The larger resource cohort is running with an unrolled
650-store output-size case and2048/4097 label boundaries; no result is claimed yet.
The candidate remains isolated. A prepared progress host driver records exact
source input separately from debug PRINT instrumentation and C006 generation proof.

## Streaming batching and source-reader baseline

Candidate8eeea648 batches fixed opcode/data counts and passes the four-native /
one-rejection smoke180.807s. f11b3e22 then uses binary semicolon string BPUT for
words/literals and passes180.881s. All four complete old images remain identical.
The earlier fc67 large cohort was deliberately interrupted during its large case;
its partial inputs/log/images are retained without a pass claim.

Candidate1b3e4b33 inlines unchanged source-character checks. Baseline39/15 passes
196.992s with deterministic repeat and GNU golden equality. The full resource
cohort is running. A proposed private text-packing change was based on a mistaken
reading of array storage: actual native arrays use five-byte string descriptors
with separately allocated contents, as already recorded in MEMORY.md. The1MB
claim is withdrawn. The preparation was not executed or promoted, and its files
are removed. Actual native heap/code/arena fit still needs measurement. No
source-generation, hardware or benchmark result follows from these tests.

The resource cohort has generated its70076-byte650-store image successfully;
native execution awaits the rest of that batch. MAIN.Z80 LOCATE/LOC1/LOC2
confirms first-character chains for host dynamic variables. Candidate690fd519
therefore prepares a private-identifier-only revision, removing redundant leading
c prefixes while preserving quoted text, DATA, REM and PROC/FN names. It remains
unexecuted; no timing or behavior claim follows from that preparation.

## Complete streaming resource qualification

Candidate1b3e4b33 passes12 sources (six native/six rejected) in3613.441s. The
70076-byte650-store program runs and prints650;2048 labels compile/run and4097
reject at4097:8 with old output intact. Deterministic repeat and independent
numeric/string links pass; all four smaller whole images match promoted7cac4bba.
Four actual separately numbered reference oracles are retained alongside the
shared harness's results. `stream-resource-002` freezes this scope.

The private-name-only690fd519 smoke is running next. Its reverse rename exactly
reconstructs1b3e4b33. No source compilation, hardware validation or performance
benchmark has been claimed; live source remains7cac4bba.

The690fd519 smoke passes54.687s with all four complete images identical, actual
reference probes, repeat/rejection preservation and GNU links. The39-case
baseline is running. Earlier f11b3e22's comparable smoke180.881s includes the
intervening source-reader difference; no pure first-letter cost profile, Agon
performance benchmark or self-source result is claimed.

## Private-name baseline and actual source probe

The full690fd519 baseline39/15 passes86.029s, GNU golden and repeat included.
The same baseline on prefixed1b3e4b33 was196.992s; this is bootstrap controller
time, not a calibrated Agon benchmark. The exact690fd519 self-source experiment
stream-source-001 is active with host-only progress PRINTs, recorded input hashes,
phase/line counters and unchanged target source. No generated compiler or actual
native-memory fit is yet claimed.

## Self-source prescan catches helper-name collision

stream-source-001 rejects690fd519 at1655:20 Duplicate definition count in371.199s,
with no emitted code/symbols,204 signatures/35 bindings and old output intact.
The batched emitter helper reused the existing bare slice-count parser name.
Rename only the new parameterised helper to PROCcodecount and enforce unique
PROC/FN family names in source preparation. New prefixed d5144921 / name-spread
508a74f2 contain208 unique definitions. Four complete old images remain identical
in57.312s smoke. Six targeted old count-consumer fixtures are running next.
No source layout, native fit or self-hosting result is inferred from the failed
prescan; earlier cohort results retain their exact source identities.

Fixed508a74f2 count-consumer6 passes97.969s with actual BBC oracles, six native
executions, repeat and independent links; includes explicit/omitted slice counts,
INSTR/STRING$, slice assignment/self-aliasing and SFIX overflow order. The full
baseline is running before stream-source-002. Compatibility/specification now
state the existing unique-name-per-PROC/FN-family admission explicitly.

The corrected508a74f2 baseline39/15 also passes86.013s with GNU golden/repeat.
Freeze stream-names-baseline-002 and checkpoint the distinct-helper fix, six
count consumers and full baseline before the next exact self-source attempt.
The live compiler remains7cac4bba while resource closure is unresolved.

## Actual source reaches executable RAM limit

stream-source-002 on508a74f2 completes prescan208 definitions/74 returns and
source-body layout390190 bytes. Final runtime/DATA emission reaches458752 and
rejects at2182:67, with1972 symbols/248 bindings and old output preserved,
1322.639s. No executable is emitted. COMPACTION.md refines private byte-table
ranges (19968 element-byte saving) and native call-adapter boundaries, retaining
reference arithmetic/conversion and BBC public values. Actual fit remains open.

## Byte-table qualification and native call adapters

Private metadata-only558c39a9 saves19968 native element bytes by using existing
BBC byte arrays for eight bounded fields. Four whole old images remain identical
in54.599s smoke. Boundary5 passes340.239s (four native/one rejection), including
formal index255,256 definitions/return owner255 and staged slot31; the initial
over-nested fixture is retained as a failed compile-only attempt. Mixed types,
LOCAL/recursive calls and string-FN consumers pass86.522s. Full baseline follows.

The isolated394-byte/29-relocation adapter module independently links and passes
21 native stages: real NUM/SFIX, widths, max slots, guards, stack/index preservation,
errors and optional zero bridges. MEM/ACT use observation stubs here. Initial
fixture selector0 was AND rather than intended ADD11; a misencoded2.75 packet
used exponent82. Actual pinned BBC gives0000003081 and000000b081, with integer
assignments2/-2. Only the fixtures change; runtime source177c90e6 remains fixed.
Failures, an unchanged rerun, actual reference packets and ABI17/21 are retained.
This is not frontend integration, native fit or physical validation.

Byte-table558c39a9 baseline39/15 passes86.246s, GNU golden and repeat included.
Adapter21-stage ABI passes with the same394-byte module; a prepared host-only
BBC label-map observer will support independent emitted-template/bridge checks
after integration. That observer has not executed yet.

## BBC frontend uses compact native calls

Prepared f8d46de6 (2244 lines/213 unique definitions/254 static private names)
connects the394-byte adapters. DIM retains its original HL context call; FOR/DIM
explicit register uses and err_line remain unchanged. Typed scalar/array2 smoke
passes54.011s with actual reference output, native execution, repeat, GNU NUM/STR
and complete adapter PIC/bridge equality through actual BBC-emitted symbol maps.
No Python source compiler/address calculation is involved. Nine-source scope is
running; actual source size and native fit remain unproved.

## Integration heap-overlap failure and correction

The f8d46de6 broader batch compiles9 but native mixed PROC values become255 and
restoration fails. Independent module/bridge bytes still match; actual maps show
compact base equals scalar string heap&4427B. The virtual heap reserves through
aliases rather than advancing cpc. Move compact code before STR runtime and its
workspace; independently reject module/heap/arena overlap in map checks.
Corrected2f81c6fb nine-source/native cohort passes122.399s against fresh BBC,
repeat, NUM/STR links and full adapter PIC/bridge equality. The failed images /
source/maps remain frozen. No arithmetic behavior or numeric oracle changes.
Full baseline and source-error checks precede another size/fit claim.

## Compact frontend qualification checkpoint

Exact isolated2f81c6fb passes baseline39/15 in87.971s, including deterministic
repeat and GNU golden. Source-error CORE6 passes143.390s and remaining33 pass
549.218s: all39 fresh reference outputs and ERR/ERL match, repeat and independent
runtime/entry links pass. Evidence compact-baseline-001, compact-errors-core-001
and compact-errors-tail-001 preserves exact compiler/source/runtime identities.
Two identical consumer inputs shrink complete executables by98 and325 bytes,
including the394-byte shared adapter; these are size comparisons, not speed
benchmarks. Actual self-source fit is still unproved and live7cac4bba is unchanged.

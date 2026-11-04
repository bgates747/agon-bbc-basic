# Compiler development — 2026-11-03

The compact compiler now completes source layout inside executable RAM, but its
mandatory initialization storage cannot fit beside that executable. Retain the
measured layout and reduce private storage/code further; no native compiler or
self-hosting result exists yet. Pi5 automated CLI work is authorized; Oryx stays
offline and no physical test is implied.

## Actual compact-source layout and allocation bound

Exact2f81c6fb completes layout339291 bytes, body265236 (prior body390190), with
2078 symbols/213 definitions/254 bindings. Private heap limitA7F00 leaves86437
bytes. Handwritten inventory of its exact typed DIM shapes and pinned assembled
templates gives112761 mandatory payload bytes before array headers, owned string
contents and allocation overhead: a26324-byte minimum deficit. It cannot initialize.
After phase2 begins, deliberately stop only the owned CLI rather than spend two
further passes writing that unusable image. Controller1366.536s is a partial-run
measurement, not successful compile time. Original output remains unchanged.
compact-source-001 retains raw failure/log/source/provenance and an explicit
layout/disposition/bound record. No output pass, native initialization or native
compiler generation is claimed.

## Private zero-tail qualification

Prepared14e56cee stores465 initialized control bytes and streams the unchanged
8192-byte zero tail. Template storage saves8192 and source text19104 bytes;
actual native fit is not inferred. Start nine actual-reference/native cases,
requiring complete output identity with2f81c6fb. All runtime capacity, public
numeric/string semantics and original control-image bytes remain unchanged.

Zero-tail14e56cee passes nine native programs118.267s against actual BBC outputs,
repeat/GNU and all nine complete2f81c6fb images. Freeze zero-tail-frontend-001.
Refine bounded private symbol packing (three-byte addresses/two-byte sorted
indices) and sparse reusable numbered-target pages in COMPACTION.md before
implementation. Accepted source-program numbers/types and capacities do not change.

## Packed private tables and sparse target pages

Prepared6597a0df has2067 lines/219 distinct definitions. It keeps4096 symbols,
storing addresses in exact three-byte cells and sorted indices in two-byte cells
(12288 payload bytes saved). A64-pointer table owns reusable256-byte target
pages, preserving separate branch/DATA domains through65279. Pages allocate and
zero on first write and clear/reuse on subsequent compilations; maximum page
payload16384 bytes, pointer payload256. Static zero-page mandatory payload is
76153 bytes before headers/string contents and future page allocations.

The first nine-source attempt produces all nine images identical to2f81c6fb,
but the host-only BBC map observer accesses the removed saddr% array and fails
at540. Freeze packed-map-observer-failure-001, excluding stale native/results.
Change the observer to call the actual BBC getter for packed candidates; it
still never computes source addresses in Python. Unchanged6597a0df then passes
nine actual-reference/native programs123.659s, repeat, GNU standard/complete
compact links and all nine complete-image comparisons (packed-frontend-002).
A prepared actual-reference/native fixture uses the exact six private BBC helper
routines, all4096 cells with guards, all64 target pages,2047/2048 and65279 bits,
branch/DATA separation and repeated clears/reuse. This helper test is active;
no helper-capacity, actual fit or native compiler result is claimed yet.

packed-helpers-001 passes262.754s: actual BBC and actual native execution of the
exact six new helpers plus FNlineref exercise all4096 address/index cells with
four canaries, all64 pages,2047/2048/65279, domain separation, clear/rewrite and
pointer reuse. Deterministic output and GNU NUM/STR/complete compact module pass;
complete control/ACT/MEM/ERR runtimes, bridges, entry, arena and heap context also
independently match. This is native helper behavior, not a native compiler image.

Numbered-target first oracle used line0, which the pinned text loader executes
immediately during loading (OSEDIT/LNZERO selects XEQ), before later targets
exist. Retain the failed reference-only attempt; no compiler/native phase ran.
Clarify this existing compiler-label syntax boundary in SPEC/COMPAT/findings.
Positive conventional targets2047/2048/65279 and combined branch/DATA labels now
match two fresh BASIC oracles; separate compiler-zero-label fixture prints2.
Two undefined top-line targets reject before output. packed-targets-002 passes
five cases/three native58.636s, repeat and GNU numeric links. Full packed
baseline39/15 also passes56.360s including GNU golden and repeat. These are
controller durations, not Agon speed benchmarks. C005 source errors/capacity and
actual native fit remain open; the next source probe adds BBC-only observations
of allocated target pages and private string lengths after layout, preserving
its exact target source and keeping host instrumentation separate.

## Isolated promotion packaging rehearsal

Push packed checkpoint4575516 and start exact packed-source-001 with BBC-only
page/string observations. Separately stage the future source/runtime/tool tree
under C005/build; live source stays7cac4bba. Add a private control-prefix package
while retaining the full independently linked image, preserve following64000
DATA when repacking errors, and prepare the394-byte adapter at its future live
paths. All nine packages rebuild identical complete runtime bytes, combined
regeneration exactly reproduces6597a0df, and each individual repacker preserves
that full source. Extended rehearsal also preserves the old7cac4bba compiler
through the modified control/error packers. promotion-preparation-002 retains
both rehearsal identities, exact staged changes, source and module data. No live
promotion, emulator change or actual native fit is implied by packaging success.

Packed exact-source phase1 completes324275 bytes/body268243,2094 symbols/
219 routines/254 bindings. BBC observations report7 target pages,13948 symbol
string bytes and5473 other metadata-string bytes. Mandatory payload76153 plus
1792 pages plus19421 observed string bytes totals97366, against101453 private
bytes available:4087 remain before headers/scalars/allocation overhead. This is
a lower-bound comparison, not fit proof. Continue actual validation/output;
no native compiler exists at this point. Exact target source is unchanged.

## Machine-image validator preparation

Before native compiler execution, check_compiler_image.py reuses independent
complete standard runtime/entry/arena checks and identifies the unique full
394-byte compact module by GNU PIC equality. Seven external entries anchor to
independent NUM/MEM/ACT exports; two pool ranges/initial zeros, four error-wrapper
ranges and compact/STR adjacency receive explicit checks. The wrapper ranges
are not a semantic proof; native differential regressions remain required.
image-validator-001 passes the existing native helper image and rejects separate
one-byte internal-PIC, numeric-entry and zero-pool corruptions for the intended
assertions. Corruptions are never executed. This uses no BASIC parsing/address
calculation on the host. Packed-source-001 validation continues independently;
no actual compiler image or native fit result is yet claimed.

## Controller termination during validation

packed-source-001 controller exits143/SIGTERM before a normal result is written;
its last logged state is validation phase2 after physical2000. No BBC diagnostic,
completed validation or output pass is reported. Origin of termination is not
established. Preserve raw console, exact source/driver/script, measured layout
bound and explicit interrupted disposition; previous output remains unchanged.
Do not count this as a successful compiler, memory failure or native fit result.

The resource controller now mirrors actual SOURCE progress onto stdout, records
SIGTERM promptly and retains normal failure metadata when it can unwind. Start
packed-source-002 through a live tee and poll the tool session itself regularly.
Target6597a0df and the entire BBC driver are byte-identical to the interrupted
run; only host orchestration changes. The new signal path is prepared, not a
claimed tested interruption recovery. Native compiler generation remains open.

Apply early input/stage persistence, host-only liveness messages and SIGTERM
recording to the prepared C006 bootstrap controller too. Syntax checks pass;
normal and interrupted generation paths are not yet exercised. These changes
never edit the BBC target/source/main or substitute a source compiler.

Prepare one native self-source/RAM preflight mode in C006 bootstrap.py, accepting
only a completed source/image-matched C005 resource run. It uses the normal
native UI and exact byte comparison, explicitly records that no unmodified
interpreted main stage ran, and does not replace the full default generation
chain. Syntax checks pass; actual native execution is still pending image output.

## First complete compiler image and Olimex coordination

packed-source-002 completes all three BBC passes in3911.701 controller seconds,
same exact6597a0df source/5f365395 driver and324275-byte layout. Image SHA
299a31190c380541a73ed9eb144a303fa37abccc4f3c3e0ad47f99f1538122c0 passes
independent full runtime/entry/heap/arena and compact PIC/bridge/pool/placement
checks. Retain image, logs and storage lower bound. Start C006
packed-native-preflight-001 through normal native filename prompts; no native
self-compilation result is yet claimed. This does not replace the default full
generation chain.

The Author directs consultation with Extender for Olimex time, file transfers
and remote CLI access. Send the request to Extender2026-10-13Sol and record
canonical mailbox2026-11-03_02-31-54_bbc-basic_bbc-olimex-access-request-one.
Read the shared physical-bench lease protocol and staged-transfer decision.
No lease, target access, reset, flash, deployment or physical result yet exists.

The initial direct-written mailbox used generic YAML rather than the helper's
JSON-valued metadata/routing format and blocked its global parser. Extender
owns the repair: preserve exact original in quarantine, republish unchanged
request body through agentcoms.py as
2026-11-03_02-34-30_bbc-basic_bbc-olimex-access-request-one, verify parser restored.
Use the maintained helper for all future mail. A separate proposed shared-index
append was rejected by automatic review (published Markdown restriction); leave
that index unchanged. Local physical plan C006/OLIMEX.md records the bounded
scope, preserved components, lease, transfer, remote command and evidence rules.

Extender sends canonical guidance2026-11-03_02-36-44_linux-extender_bbc-olimex-access-guidance-one.
Acknowledge and reply using maintained helper as02-37-29_bbc-basic_bbc-access-guidance-received-two,
with immediate chat alert. Confirm remote MOS keyboard/CLI, pinned P4-staged
file transport and joined-control passive Legacy printer-mirror capture.
Use Extender-owned diagnostic/results paths; retain all installed components,
startup, wiring and display mode. Finish emulator qualification and prepare an
exact finite fixture before reserving. Empty logical registry is not readiness;
no target operation or lease occurs. Current native preflight remains active.

Prepare C006/prepare_olimex.py as an offline byte-copy/batch packaging tool.
It requires the completed normal-main four-image chain plus all12 native
regressions and verifies manifests/source/image identity before creating a new
bundle. Exact compiler heap-start/limit fields are checked. Generated batches
use LOAD/RUN ., explicit entry/return markers and post-return listener start;
filename inputs and rejection sentinels remain explicit coordinator steps.
No network/device connection, compiler implementation or image patch is present.
Python syntax checks pass; real-input packaging awaits completed prerequisites.

Extender scheduling inquiry02-59-16 asks whether BBC is ready before a prepared
6502 finite tranche. Reply03-01-26_bbc-basic_bbc-priority-not-ready-r02 through
helper plus immediate chat: still independently qualifying, no reservation or
reliable hardware-ready ETA; do not idle the bench for us. No BBC lease, target
operation or authority over the other project's tests is asserted. Native
preflight has started output; only partial-prefix equality is observed so far.

C006 packed-native-preflight-001 completes native self-source compilation through
normal prompts in1983.653 controller seconds, MOS status0. Its entire324275-byte
G1 equals the interpreted resource seed SHA299a31190c380541a73ed9eb144a303fa37abccc4f3c3e0ad47f99f1538122c0.
Exact6597a0df source and source/seed/output/console/controller identities are
retained. Actual native initialization, source metadata/storage and all output
passes fit; the lower-bound estimate is no longer the sole resource evidence.
This preflight did not run unmodified interpreted main and does not replace the
full default four-image chain, native regressions or physical qualification.
No hardware or performance benchmark result is claimed.

Prepare compact/promote.py as a guarded development promotion operation. It
verifies retained manifests for native source preflight, packed baseline/helper/
integration, all39 error cases and large-output/symbol capacity before copying
exact6597a0df plus the rehearsed compact runtime and three packers. It then runs
REPORT/nine module generators and requires unchanged source after each and all
complete module hashes equal the rehearsal. No emulator, Git or hardware action
is inside it. Syntax checks pass; actual promotion awaits pending cohorts.

Packed source-error CORE6 passes149.768s and remaining33 passes585.087s:
all39 fresh reference outputs/ERR/ERL match, deterministic repeat and complete
standard-runtime/entry links pass. packed-errors-core-001/tail-001 retain exact
6597a0df inputs/results. compare_errors.py verifies retained manifests and
identical source/oracle plus every complete emitted image against the earlier
2f81c6fb cohorts; packed-error-equivalence-001 passes all39. These are controller
durations and retained-byte comparisons, not hardware/performance measurements.
Large-output/symbol-capacity qualification is active; live7cac4bba is unchanged.

Prepare a full-source baseline freezer and C006/native_baseline.py. They retain
all39 actual standard inputs and compare actual native-compiler output against
15 complete fresh baseline images and24 exact diagnostics, preserving old
output on rejection. That comparison supplements representative12-case native
execution and fresh39-case error tests, without claiming another program
execution merely from byte equality. Syntax checks pass; live baseline inputs
and actual native comparison are still pending.

Prepare bootstrap.py --expected-image to retain the already qualified resource
seed and compare each complete normal-main/native generation before successor
execution. The BBC source and full four-stage contract are unchanged. Syntax
checks pass; the new guard awaits the full-chain run.

C006/OLIMEX.md now records exact compiler image/heap/arena/user guard boundaries
and the additional MOS-provided ADL stack. Read-only EMOS exec24/defines/startup
inspection is distinct from installed firmware evidence; retain an actual MEM
report after future checkout before running compiler fixtures. No hardware
access, reset, flash, mode change or memory-policy change occurs here.

packed-capacity-001 passes3 programs/two native executions/one rejection in
1717.759 controller seconds. Actual large executable73821 bytes runs1800
increments; repeat is byte-identical. The2048-label program runs, and4097 labels
reject at the expected guard before output. Fresh evidence retains source,
programs/images/repeat, console and independent numeric links. This is capacity
qualification, not a speed benchmark. Packed6597a0df now has native source fit,
all39 errors, baseline/helper/integration and public capacity qualification.
Proceed with guarded development promotion, then fresh live checks.

## C005 completed and promoted

Guarded packed-live-promotion-001 promotes exact6597a0df to compiler/compiler.bas,
compact.s and its new packer plus rehearsed control/error packer changes.
REPORT/all nine packers preserve the full source and every complete runtime hash.
Fresh live baseline39/15 passes49.956s (GNU golden/repeat); live compact frontend9
passes142.153s with fresh references, full adapter maps/PIC/bridges and repeat.
promoted-inventory-001 records2067 lines/177 PROC/42 FN definitions and current
construct searches; initial inventory remains unchanged. The successful native
self-source fit supplies actual execution evidence beyond those searches.

C005 acceptance is complete for its documented initial scope. Remove its sole
unfinished TODO entry; update live specification, matrix, runbooks and concise
handoff. The Author waived previous approval stops and authorized development
checkpoints; no graphical/human/hardware validation or performance result is
claimed. Main remains untouched. C006 full normal-main G0/G1/G2/repeat, native
baseline/representative/error qualification and Olimex execution remain.

## C006 full-chain run started

After pushing development checkpoint89b8f41, start live-bootstrap-001 using
unmodified live6597a0df normal main, pinned BASIC/CLI/MOS and --expected-image
C005/packed-source-002/native-compiler.dat. Both actual filename prompts are
answered; G0 is compiling. The sequential host pipeline stops on any failure;
only successful full four-image equality proceeds to live-native-baseline-001,
live-regressions-001 and live-native-errors-001. None of those later results is
claimed yet. No second CLI may use this SD while the pipeline is active.

During G0, prepare C006/olimex_step.py for one explicit physical operation at a
time through maintained Extender tools. It verifies fixture payloads and owner
before each operation, journals requested actions before submission, uses new
staged files and fresh major2 metadata/EXIT, and delegates passive capture to
the maintained joined-control opener. Relative paths are normalized before
changing child cwd. Local machine/lease details remain in ignored records.
No reservation or live board operation occurs. Host-only mocked qualification
progresses4 checks001,5 checks002,6 checks003; final tests include no target
submission after failed lease/wrong protocol, path boundaries and separate
owner assertions. These do not qualify hardware or the P4 protocol.

Tighten offline Olimex packaging to require all four qualification records:
normal-main bootstrap, native baseline39/15+24, representative12 and fresh
native errors39. All source/native hashes and completed case ranges must agree;
copy the four result records into the host bundle. Syntax passes; actual bundle
creation still awaits the active full chain and native suites. No target action.

Maintain C007-derived documentation after C005 promotion: Git history confirms
completed search publication227b620, so correct its stale uncommitted status.
Mark original catalogue eligibility as the November1 snapshot and record W01's
actual native self-source preflight. The live compatibility matrix owns current
features. No benchmark adaptation, new source search or timing measurement is
performed; no speedup is inferred from controller durations.

Extender source review04-24-44 confirms maintained client argument ordering but
corrects EXIT acknowledgement versus actual handback. Implement separate ACK
record plus bounded owner-checked online=false AND pending=false observation;
uncertainty stops without another EXIT/session. Host004 passes8 mocked checks;
005 strengthens offline-but-pending and per-poll ownership assertions, also8.
Document exact retained journals for status/resume; capture ready is port-open,
not Legacy sentinel proof, and retrieved SHA still needs expected-byte equality.

Further review04-31-02 verifies installed/current MOS EXEC aborts on nonzero RUN.
All planned physical program cases expect0; packaging now verifies actual retained
compiler-status0 logs, including rejected source, and rejects any planned nonzero
application status. RUN is line4 in each finite batch. Unexpected aborted EXEC
requires its exact fresh file/line error and actual CLI; no assumed end marker,
listener restart or RUN/SAVE replay. Reply04-33-38_bbc-basic_bbc-exit-exec-boundaries-received-four
acknowledges both corrections through maintained mail plus immediate chat. G0
continues; no physical reservation/access or new approval gate is introduced.

Prepare exact physical upload mapping, including rejection sentinels placed at
old-output destinations rather than ordinary source locations. Extend the still
unexecuted representative native file case to remove its own scratch file,
verify255+text (five bytes) and retain actual output for physical comparison;
packaging requires that proof and copies its bytes. Syntax checks pass. These
host-only changes affect future native qualification, not active G0 source,
BASIC main or compiler image. No file-I/O result is claimed before execution.

## Full unmodified-main G0 completed

live-bootstrap-001 G0 completes3951.738 controller seconds through the actual
normal Source/Output prompts and ordinary *BYE. Its full324275 bytes equal the
independently qualified resource seed SHA299a3119; only then does G1 start.
freeze_generation.py retains completed immutable inputs/G0 image/console/commands
in live-main-g0-001 without freezing or claiming the active cohort's later
status. This is actual unmodified interpreted-main proof, not the earlier
instrumented resource driver. G1/G2/repeat and native suites remain active or
pending. No hardware/performance result follows from these controller times.

## Full-chain G1 completed

G1 completes1983.142 controller seconds/status0 with324275 bytes equal to G0
and expected seed299a3119. G2 starts only after that comparison. Retain immutable
live-native-g1-001 snapshot using freeze_generation.py; leave original cohort
status active/unfrozen. This now demonstrates normal interpreted main followed
by actual native self-source generation. G2/repeat and native suites still
require execution; no full-chain, hardware or benchmark result is inferred.

## G2 completed; shared tmpfs pressure resolved locally

G2 completes1997.471 controller seconds/status0,324275 bytes identical to G0/G1
and expected299a3119. Retain live-native-g2-001; repeat starts normally.
A separate sandbox command then fails to create its synthetic .agents mount
with ENOSPC. Read-only df shows /tmp tmpfs4GiB full, /Agon about720GiB free;
most temporary usage is other Extender-owned source/build trees. Do not modify
those. Reversibly move only our inactive Cargo release/.fingerprint,build,deps
to C006/build/relocated-cli-cache-001, retaining active executable and logs in
place. Before/after CLI SHA remainsbf5f29b2; dynamic-section check shows no
runtime dependency on that cache path. Recover66846720 free bytes and normal
sandbox commands. Repeat/controller continue. cli-cache-relocation-001 retains
actual receipt/dynamic-section and explicit disposition; no compiler input,
firmware/profile or hardware change. Notify Extender via06-14-44_bbc-basic_bbc-shared-tmpfs-full-one
and immediate chat so it can inspect its own inactive trees. No file deletion
or takeover of another owner's work occurs.

Extender durable result06-22-22_linux-extender_extender-bbc-tmpfs-recovered-r01
reports relocating its eight historical temp source trees to ignored SSD storage,
preserving old paths through symlinks and verifying complete metadata/content
manifests plus Git status. Current df independently shows /tmp332MiB used,
3.7GiB available. Our files/runtime remain untouched; repeat continues. Ack the
mail, with no reply/bench action requested. Treat Extender's receipt as its
owned recovery evidence, not a new compiler or hardware qualification.

## Host interruption of final repeat; explicit resumption

The long shell pipeline reports exit143 during repeat, without normal controller
unwind or recorded compiler diagnostic. Read-only process audit finds no owned
CLI/bootstrap process left. Parent metadata contains completed G0/G1/G2 and
attempted repeat only; no repeat image exists. Origin remains unknown. Preserve
original metadata, copied partial repeat console, controller stream and observed
interruption in live-bootstrap-001, then finalize its manifest. Later native
suites never ran. Do not reclassify this as a BASIC rejection or successful repeat.

Add a narrow --resume-repeat path: require exactly the three completed stages,
interruption record, verified full manifest, same source/runtime inputs and all
three bytestrings equal the checked seed. Carry their actual immutable evidence
and original interruption/controller records, explicitly mark inherited stages,
then execute only a fresh normal native repeat from verified G1. Syntax and
actual input guards pass; live-bootstrap-resume-001 starts repeat. The compiler
source/main/image is unchanged. This avoids redoing qualified work while retaining
actual execution requirements and truthful interrupted lineage. Run each later
native suite separately after the resumed repeat completes.

## Actual repeat completed; all four images identical

Resumed repeat completes1996.877 controller seconds/status0. Its full324275 bytes
match original actual G0/G1/G2 and expected seed299a3119. Final resumed report
lists inherited and newly executed stages and preserves original interruption,
controller and normal-main records. Freeze complete live-bootstrap-resume-001
with final controller stream/manifest. All four actual stages are now qualified
with explicit resumption; no uninterrupted-run or hardware/performance claim.
Start live-native-baseline-001 against the fresh frozen39-input live baseline;
only completed outputs/diagnostics will count. Run remaining suites as separate
host commands after the interrupted long shell pipeline.

## Native baseline complete

live-native-baseline-001 passes all39 inputs in245.15 controller seconds.
All15 complete native outputs match live-baseline-streaming-001; all24 exact
diagnostics match with old output preserved. Every compiler invocation returns0,
confirming the normal main's caught-diagnostic contract for the planned MOS EXEC
files. Retain the final controller stream and refreshed manifest before freezing.
This suite compares compiler output; the reference cohort owns program execution.
Start the separate live-regressions-001 run next. No physical result is claimed.

live-regressions-001 passes all12 cases in131.049 controller seconds. Actual
generated programs match their retained expectations/fresh BASIC references;
native-test.dat contains exactly FF74657874. Both rejected inputs preserve their
old output, and all12 compiler returns are0. Retain final controller/manifest.
Start live-native-errors-001 as its own host command for the final39 fresh
reference ERR/ERL/native-output/linkage checks before offline physical packaging.

## Native error suite and physical fixture ready

live-native-errors-001 passes all39 fresh pinned BASIC ERR/ERL programs and actual
native outputs in612.766 controller seconds. Complete39-image runtime/entry
checks and deterministic repeat pass. Freeze final controller/manifest; all
emulator prerequisites now pass with unchanged6597a0df source/299a3119 image.

Run prepare_olimex.py against those real four completed manifests. It passes and
creates40 payloads/441398 bytes, including111810-byte source and324275-byte
compiler. Preserve the exact offline bundle as olimex-fixture-001, manifest
SHA05149bd76c5f23f8f6bf97c8db7bde3871e858a1e579a55784f05dd3a84d4787.
Ten expected generated images total102941 bytes. OLIMEX-R01.md pins the finite
12-source/10-program/two-self-source scope and memory/restoration/stop protocol.
This is ready preparation, not a physical deployment or result.

Extender guidance07-20-19 answers the timing/MEM/CLI enquiry: no comparable
physical compiler timing or current stack high-water exists. Preserve the map,
observe fresh installed MEM only after grant, separate mirrored host elapsed
intervals from CPU/performance claims, and revise from actual first hardware
results. No reset/flash/startup/mode changes are planned. Request a finite lease
only after this frozen qualified fixture exists.

Canonical reservation ee0ad664f72a is submitted for c006-r01. Durable mailbox
07-29-35_bbc-basic_bbc-c006-r01-reservation-ready and immediate steering deliver
the exact scope/manifest/plan to Extender. No lease or target access is inferred.
Correct the plan's sentinel-size transcription to42 bytes, matching actual
frozen payloads; no payload or manifest changes.

Extender07-31-52 explicit grant assigns generation7, after fresh canonical
listener/staged startup+utility reads/EXIT and neutral idle resources. Save the
immutable grant/config locally, assert current token for every operation, and
independently verify input/listener/worker. Maintained joined-control capture,
VDU2 and fresh BBC_C006_ENTRY_R01 sentinel prove actual Legacy CLI. Fresh MEM:
USER:LO040000..0BBFFF, MOSdata0BC000..0BD05C, heap0BD05D..0BF7FF,
stack24 at0BF800..0BFFFF/2048B, compatible with the compiler's below0B0000
allocations. This does not measure stack high-water. Preserve actual incoming
directory/mode and components. Explicitly start canonical major2 listener,
create only fresh BBC roots, begin sequential40-file upload/readback verification
through deploy_olimex.py and maintained one-operation helper. No workload yet.

All40 independent readbacks pass in242.466 deployment seconds. Fresh listener
EXIT/offline returns actual CLI (with the documented SD service stopped line).
One overly strict host string assertion omitted that known line; actual raw
console positively shows the current CLI. Preserve it and use the complete
observed framing in subsequent guards; no target failure or replay occurred.
Invoke compile0 exactly once through normal source/output prompts; retrieve its
251-byte output and compare every byte equal. Invoke run0 exactly once; actual
native compiler text and normal batch/listener return match. Freeze entry/MEM,
all40 readbacks and these two partial results in olimex-deployment-001.

The one-stage observer is checked against both retained actual case0 windows,
then compile1 passes with its complete6447-byte output equal. Its exact known
mode records are removed only for text comparison, while raw capture is retained.
The bounded small coordinator starts remaining compile2..11/run1..9, requiring
each child's actual passed result before proceeding. No self-source or retry/
cleanup is included. Physical qualification is not yet complete.

All remaining19 small stages finish506.254 coordinator seconds: total physical
12 source compiles/10 actual native programs pass. Exact ten image comparisons,
two42-byte prior-output sentinels, visible output and native-test.dat FF74657874
match. Freeze complete raw small capture/per-stage windows, outputs, observation
times and report in olimex-small-001. No optical or performance pass follows.
Exit the final listener, observe actual CLI, disable VDU2 and close its owned
reader normally. Open fresh maintained7200s self-a capture, enable/qualify it
with new BBC_C006_SELF_A_CAPTURE_R01 sentinel and observed CLI, then start the
canonical listener for the one-stage driver. Invoke self-a exactly once through
its observed normal prompts. It is active; self-b is not invoked yet.

Refresh BOOTSTRAP.md and public README/matrix references that still described
the now-completed native suites as merely prepared. Keep physical small-suite
success distinct from the still-active first self-source pass. No compiler,
runtime, frozen fixture or device input changes accompany this documentation.

At approximately one hour after self-a's final filename emission, no completion
or diagnostic is observed; raw console remains1070 bytes. Preserve an immutable
actual-prompt-only snapshot olimex-self-a-prompts-001, explicitly withholding
completion and liveness claims. Source main prints no intermediate progress.
The5400s observer remains active and no target operations are sent alongside it.
Durable08-55-23_bbc-basic_bbc-c006-small-pass-self-a-observation-one and steering
give Extender the completed small-suite results and this scheduling status;
no repair, retry, parallel access or new grant is requested. Self-b is unstarted.

## First physical self-source observation bound expired

At epoch1793715922.4746075 the5400s completion observer raises TimeoutError and
its host process exits1. Raw capture remains1070 bytes, ending at the exact
output-filename echo, without Wrote, BBC_END_SELF_A, diagnostic or actual CLI.
This is an observation failure/unknown foreground, not compiler status1, a hang
diagnosis or an Extender defect. No target dispatch followed filename submission.
Freeze unchanged original stage report/source/window and full capture snapshot
in olimex-self-a-bound-001; no incomplete stage is counted as successful.

Retain generation7 custody and existing maintained passive capture (7200s total,
approximately28 minutes remaining at09:26EST). No retry/reset/self-b or further
target queries/keys/transfer occur. Durable09-26-09_bbc-basic_bbc-c006-self-a-observation-bound-one
and immediate steering request Extender's admitted reconciliation/continued
bounded observation guidance, explicitly without parallel target access or new
workload. Any actual later completion will receive separate evidence rather
than rewriting the original timeout. All completed native/small hardware results
remain qualified; C006 self-source/clean handback are unfinished.

Extender09-27-55 reconciles the passive remainder: keep only the already-admitted
reader to its original7200s limit. Exact correlated late BBC_END_SELF_A without
error/reset permits only original-result listener/status/get/whole-byte checks
and normal cleanup/release; no self-b. If the reader expires without completion,
let it close and report, retaining custody with no reopen/keys/query/reset or
inferred CLI. No new hardware operation is selected. Acknowledge receipt only.

Offline frozen-source inspection SELF-SOURCE-WORK.md and self-source-work-001
find signature1/compiler3/DATA3 complete traversals (782670 byte visits), per-byte
EOF/BGET/string construction, logical prefix-length sums and packed symbol-index
insertion shifts.2094 symbols yield a pessimistic4382742 byte-assignment bound,
not measured actual moves. Binary symbol search and full219-routine/254-binding
scans are distinguished. No retained executed instruction/cycle counts were
found in complete self-source reports/controller streams. These facts cannot
prove physical progress, predict completion or diagnose a hang. Return them to
Extender through bbc-c006-offline-self-source-work-one and immediate steering.
Live source, runtime, fixture and bench state remain unchanged.

## Actual late physical self-source matches; clean release

The original reader captures exact late Wrote/BBC_END_SELF_A/canonical listener
sequence with no intervening error/reset. Strict normalized body comparison
checks both prompt/filename echoes and all completion/listener lines. Under
Extender's admitted known-return path, fresh status proves major2 listener online,
worker idle and neutral input. Retrieve only the original result into a new
path; a permitted progress observation shows304128/324275 bytes, no errors.
GET completes251.948 host seconds; all324275 bytes equal SHA299a3119. Preserve
olimex-self-a-late-001 with the old TimeoutError report unchanged alongside
new late-observation/result and complete raw capture. No EXEC/RUN/SAVE repeats.
Last capture append before retrieval is5951.332s after final filename emission;
this is host/serial/listener observation, not CPU time or a performance benchmark.

Fresh pinned complete-file GETs prove startup108B9e97/listener22968B04e7 unchanged.
Fresh EXIT/offline returns actual CLI; restore exact incoming FSIM directory,
observe native0 prompt after text/visible/flashingcursor controls, VDU3 mirroroff
and close the owned reader normally. Fresh neutral input/worker0/offline-no-pending,
P4mode0 and ownerless bothUSB pass. Retain per-field unchanged verified firmware
provenance, not fresh flash-read claims. Canonical generation7 clean release is
14:48:42.976464Z, next_request=null; complete Extender handback09-50-32 delivered
through mailbox and steering. No lease or target action remains. No self-b,
reset, firmware/startup/mode/wiring change or optical pass occurred. Prepare
the outstanding physical repeat separately using the actual first observation;
retain original finite scope/timeout and late-success lineage truthfully.

## Prepare separately bounded physical repeat

After checkpoint2384df9, prepare_olimex_repeat.py verifies both prior complete
manifests, actual hardware output/seed equality and actual clean release. It
copies the hardware-produced compiler unchanged, the exact source and one
176-byte MOS batch into olimex-repeat-fixture-001:3 payloads436261 bytes,
manifestb5d0761fc88e512f32d14217a8ee2de997e05e412edafc3c8236bd2101128e24.
OLIMEX-R02.md defines one outstanding hardware generation only,6600s completion
observation from the actual first5951.332s captured interval, fresh7200s reader
after deployment, exact comparisons and unchanged preservation/stop boundaries.
This is offline copying/hashing, not compilation or an execution result.

The deployment experiment now accepts explicit expected file counts3 or40,
default40 preserving the original scope. The one-stage observer accepts the
actual incoming directory for its pre-EXEC CLI guard and an explicit self-timeout
5400/6600 (default5400), preserving its old invocation. Syntax checks and actual
manifest/byte/command-file preparation pass; no extra emulator/hardware experiment
is run. New reservation/fresh Extender grant are still required.

Canonical new reservation9339623b747d is submitted14:57:47.823211Z, after actual
release. Durable bbc-c006-r02-ready-reservation-one and immediate steering provide
the exact frozen input provenance, scope and timing/stop/cleanup plan to Extender.
No new lease or target operation is inferred from preparation/reservation.

Extender09-59-45 explicitly grants generation8 for the single outstanding repeat,
after fresh canonical readiness/preservation checks, then stops all target access.
Save the new grant/config locally; old generation7 token remains invalid. Actual
new neutral/offline/worker0 checks, joined-control setup capture, VDU2/sentinel,
CLI and fresh MEM pass with identical user/stack map. Start only canonical
major2 listener, sequential fresh directory metadata and three-file deployment/
independent readbacks. No repeat invocation is claimed before they pass.

All3 complete readbacks pass137.291 host seconds and are frozen with actual
fresh CLI/MEM/setup capture as olimex-repeat-deployment-001. Fresh setup EXIT
returns actual original-directory CLI; VDU3/owned reader close normally. Open
fresh7200s execution capture, VDU2 and BBC_C006_SELF_B_CAPTURE_R02 sentinel prove
the new channel/CLI, then start canonical listener for the stage driver's
explicit entry/EXIT. Invoke self-b.txt once with --self-timeout6600 and actual
incoming-directory guard. Both real prompts are observed; final filename return
is epoch1793718539.6227434. Repeat is active, with no completion inferred.

release_olimex_repeat.py records the previously executed R01 cleanup/release
procedure as a guarded repeat helper: require actual passed stage/full image,
preservation readbacks, restored CLI/text/cursor/mirror receipts and both closed
readers before fresh neutral/offline/idle/display/ownerlessUSB checks and central
release. Syntax checks pass; it has not yet run and may execute only after the
repeat's known complete success and explicit cleanup.

Review the existing exact root/vendor notice and provenance for eventual native
artifact distribution; both retain the zlib-style notice, original authorship
and marked adaptations. Prepare promote_native.py as a copy-only guarded step
for C006's live build/run workflow. It requires all completed manifests/native
suites, actual four-generation equality, both physical images and clean release
before copying the actual repeat to compiler/bin/compiler.bin with unchanged
notice and provenance metadata. Syntax checks only; no live native artifact is
created while repeat remains pending. Main is outside this development promotion.
Correct two stale REFERENCE.md statements that still treated completed C003/C004
LOCAL/runtime work as unfinished; no source/runtime behavior changes.

At approximately one hour, the repeat's original capture still contains1047
bytes through the final filename echo, without a diagnostic or completion.
Freeze actual-prompt-only olimex-self-b-prompts-001 with no completion/liveness
claim. Durable11-08-53_bbc-basic_bbc-c006-r02-observation-status-one and steering
give Extender scheduling status only; existing6600s observer/7200s reader remain
active, no parallel access/extra workload or acknowledgement requested.

## Physical repeat succeeds; C006 completes and native executable is promoted

The sole generation8 self-source invocation returns exact clean Wrote/end/
canonical-listener sequence at epoch1793724490.4255953,5950.803 host seconds
after final filename emission return. This is within its admitted6600s bound.
The original-result GET completes245.017s; all324275 bytes equal both the actual
first hardware-produced input and normal-main bootstrap G0, SHA256
299a31190c380541a73ed9eb144a303fa37abccc4f3c3e0ad47f99f1538122c0.
Freeze actual stage/full-cleanup console, full comparison, output, preservation
and release summaries in olimex-repeat-001. No RUN replay or reset occurs.
The original first-run timeout/late result and emulator interruption/resumed
lineage remain unchanged and explicit. These intervals include host/serial/
listener timing and are not CPU times or paired performance benchmarks.

Fresh complete startup108B9e97/listener22968B04e7 readbacks remain exact. EXIT
returns actual CLI; restore the exact incoming directory, observe native0 and
returned text/visible/flashing-cursor controls, VDU3 mirroroff and both capture
closures. The actual release_olimex_repeat.py run checks completed stage/full
image, preservation, CLI/input/display/reader receipts and fresh neutral/offline/
idle/ownerlessUSB state. Central generation8 clean release is
2026-11-03T16:54:23.807673Z, next_request=null. Immediate durable handback
2026-11-03_11-55-11_bbc-basic_bbc-c006-r02-clean-release-one and steering inform
Extender. No BBC custody, workload, transfer or observer remains. Firmware
identities retain verified provenance, without claiming fresh flash reads;
no firmware/startup/mode/wiring change, optical pass or SD unmount/eject occurs.

Run promote_native.py against the completed repeat after all prerequisite
manifest/source/license/release gates. It copies that actual second hardware
output unchanged to compiler/bin/compiler.bin, exact root/vendor notice to
compiler/bin/LICENSE.txt, and writes usage/provenance metadata. It neither
compiles BASIC nor patches instructions. The live source remains SHA256
6597a0df3f99b4f43c42bff1cdbc59f5fdf730c57837f3d4112a598fbfbe5fb8;
runtime sources remain unchanged. verify_native_promotion.py passes, retaining
native-promotion-001 with all six completed image comparisons, seven verified
prerequisite manifests, exact notices and promoted file hashes. No additional
compiler/emulator/hardware run is required for this file copy.

The final Git evidence audit finds34 physical payload/capture `.bin` files
(688109 bytes) referenced by existing C006 manifests but hidden by the global
binary ignore. Verify every byte against its frozen hash and include them with
a narrow C006 evidence ignore exception, without editing old manifests. This
corrects repository completeness; it does not create a new execution result.
Mark these raw `.bin` files as binary in .gitattributes to preserve their exact
control bytes/CRLF and prevent text line-ending normalization on checkout.

Accept C006's initial scope as complete under the Author's explicit authorization
to finish the TODO and skip prior approval stops: actual normal-main/four-image
emulator equality, native39/12/39 suites, physical12 compiles/10 generated programs,
two physical self-source generations and clean releases all pass. Update the
task record, README, specification, compatibility status and handoff; remove
C006 from the sole TODO. C000–C007 initial scopes are closed. Keep the qualified
development branch separate from main, which is not merged or promoted. Full
BBC language coverage, human optical validation and formal speedup benchmarks
are not asserted by this milestone.

## C008 — Stage the Author's manual programming and qualification directory

The Author selects Oryx path /run/media/smith/AGONC8/mystuff/basic-compiled,
with programming essentials at its root and individual tests in subdirectories.
Promote C008 to TODO before implementation. Read canonical deployment/network
instructions; the new explicit destination authorizes bounded file deployment
despite the earlier Oryx maintenance restriction, without scheduling an emulator.
Actual Oryx inspection finds the exact rw vfat mount and empty target.

The card's existing /mos/nano.bin equals the6560-byte upstream artifact SHA051f
from clean agon-utilities56d44853. Retain its MIT notice and inspected controls.
MOS Run permits explicit address plus arguments; editor is a&B0000 moslet,
compiler/generated images run at&40000. The root guide supplies exact separate
edit/save, compile/prompt and load/run commands. No interpreter or assembler is
required. Copy exact qualified compiler/source/notices, compatibility and starter.
Twelve subdirectories reuse C006's exact qualified sources/oracles, ten successful
programs and two preserved-output rejections; no manual pass or new run is inferred.

prepare.py emits manual-002,50 files/477595 bytes, package manifest SHA256
16d0d6e3954e0ca2be7e53eb077252d278aa73bf353cea352bc427ffb526ec9a.
The earlier disposable package was superseded before deployment by a readme
wording correction. deploy_sd.py validates exact host/mount/rw-vfat/resolved empty
target and local payload hashes, streams regular files with keep-old-files, then
syncs the filesystem. Actual transfer succeeds at14:46:22.767816EST, return0,
50 files and the card still mounted. No deletions, unrelated writes, firmware/
startup changes, program execution or redundant post-copy readback occur.

manual-deployment-001 freezes the actual receipt, package manifest, scripts,
root runbook, exact cases/oracles, compatibility, compiler provenance and editor
bytes/license. Root stays stable for user programs and later tests; the initial
deployment helper deliberately refuses this now-nonempty directory. Future
updates must preserve user programs/results. C008 is staged and remains on TODO
pending the Author's actual manual results; main and compiler/runtime sources
remain unchanged. No emulator/bench reservation or new CPU-heavy work is selected.

Extender's14:49:11 retained-bench policy notice is read after staging: it records
generation9/BENCH-013 custody retained until the Author and Extender select another
project's slot. Existing FIFO requests remain possible, but finishing a subtask
does not automatically release the bench or grant access. Record the restriction
in the handoff; do not create a second queue or request/access hardware. Console8
manual qualification remains separately under the Author's coordination. No
acknowledgement-only reply is sent and no test or implementation change follows.

The Author corrects Markdown file naming. Audit the deployed .txt documents:
only compatibility.txt contains Markdown headings/tables/links. Correct the
package generator to compatibility.md and the root readme reference. A bounded
C008 fix checks original compatibility/readme/manifest hashes, renames only that
document, updates the two references and syncs the mounted card. Other .txt files
remain plain text. markdown-extension-001 retains the successful receipt and new
package manifestababb88b; previous evidence is unchanged. No program, firmware,
test result or manual-acceptance status changes.

Extender14:55:28 reports BENCH-013 listener adoption in8aa3245d: canonical
/emos/sdserve.bin is now24753B/SHA0566e17f, exact tested November3 sequential
reader, with unchanged major2/client ABI. Original22968B/04e7 remains rollback
and historical C006 evidence. Record the new notice in the handoff/physical
runbook; future plans must read Extender's current component selection and fresh
grant. Do not modify frozen evidence, old helper pins or the Console8 package.
Extender retains generation9; no bench request/access or reply-only message occurs.

The Author identifies development paths in the consumer readme and requires all
package paths to be installation-independent. Audit the full50-file payload,
including binary/source bytes and JSON metadata. The deployed scan identifies17
affected documents. Remove fixed install/host paths from root/test instructions,
editor notes and manifest; keep a public compiler provenance record with only
bundled filenames/hashes/qualification counts. Replace the copied compatibility
document's repository-only links with a self-contained matrix preserving every
feature admission. Maintainer lineage stays in repository evidence.

prepare.py emits portable manifestv2/package_root=".", rejects known maintainer
paths/names across every payload file and checks local Markdown links. Each test
guide starts at the package root, LOADs compiler.bin, CDs to tests/name and uses
relative input/output names; CD ../.. returns. Compiler/editor binaries, BASIC
sources, licenses and expected outputs are byte-identical to the prior package.
manual-004 has50 files/474769 bytes; manifest7fe79c81.

The bounded update_sd.py checks old/new local package hashes and all18 changed
targets against their previous hashes before replacement, preserving unrelated
user files/results. Actual update completes15:00:51.689056EST, syncs and leaves
the card mounted. portable-package-001 freezes exact before/after documents,
manifests/scripts and successful receipt. Post-correction full deployed scan
finds no maintainer paths/names; local general text-path and all12 relative
command-sequence checks pass. No program, emulator, firmware or acceptance
result changes. C008 remains awaiting manual results.

At the Author's request, record C009 as a low-priority possible anonymous-label
extension in TODO and its immutable task brief. Nearest forward/backward target
resolution is an idea only; illustrative@@:/@B/@F syntax is not adopted and must
not silently reserve existing named identifiers. Label scopes, conventional
numbered targets and LOCAL variable semantics remain separate questions. No
implementation, tests, deployment or resource reservation is selected.

The Author confirms Mandelbrot runs correctly under the pinned reference BASIC
on Oryx and requests compiler support, an official task and logical commit/push
groups before proceeding. Read the actual49-line source at emulator-relative
basic-compiled/tests/12-mandelbrot/mandelbrot.bas; SHA1eb897c8. MODE8 is the first
reported rejection. Inspection also identifies GCOL0,C%, PLOT69,K%,J% and numeric
GET followed by MODE1, alongside already supported numeric/array/DATA/control
constructs. Promote C010 as current task with unchanged-source and differential
compatibility acceptance; do not substitute a rewritten numerical algorithm.
The working tree was clean. Record a planning checkpoint before implementation;
reference visual acceptance does not qualify a new compiled image.

C010 experiment checkpoint: freeze the Author's exact1038-byte source in
source-001. It contains46 numbered lines (390 is followed by430); the earlier
49-line description was a counting mistake, not a source change. Audit actual
MODE/GCOL/PLOT, EXPRI/SFIX, OSRDCH/GET and MOS flag/key interfaces. The candidate
13c2a488 adds BBC-written native emission only; live source6597a0df and qualified
binary299a3119 remain unchanged. Bare GET and numeric graphics variants are the
selected scope; unrelated graphics statements/GET variants remain unsupported.
The Author confirms retaining @ on both label definitions and references.

The stock CLI cannot acknowledge MODE or consume graphics packets. Prepare an
isolated task-local host protocol peer/raw CPU-UART observer from Fab c22876d1,
without editing upstream or changing the CPU/MOS/numeric implementations.
Record its exact GPL source/patch and executable63d22f6 in observer-tool-001.
The original root fixture's CLI target in /tmp is missing; native-build-001
retains the failed pre-launch attempt. Select the project-local observer through
the canonical generated wrapper and record that distinct identity. The cause
of the missing old target is unknown; old qualification remains unchanged.

compile-001 preserves an actual18329-byte Mandelbrot output and original log,
but its controller omitted *BYE and did not verify a normal MOS return. It is
partial evidence, not a completed run. Fresh wire-probes-001 completes all five
reference/native pairs: MODE/GCOL/PLOT bytes, byte/word/fraction conversions,
argument side-effect order, GET consumption and GET inside expressions match
exactly. wire-bounded-001 also completes exact stream parity for an explicitly
reduced Mandelbrot fixture (ITERS8/SCALE64, with a key-input marker). This is
not acceptance of the unchanged full source. Native rebuilding, error probes
and unchanged full-program runs remain active. No rendered/human validation,
paired performance measurement, live promotion or main merge is claimed.

C010 second experiment checkpoint: wire-errors-001 completes nine fresh
reference/native pairs. SFIX overflow in each argument position prevents later
side effects; MODE division/overflow and GET Escape preserve ERR/ERL/message
bytes. wire-interactions-001 adds three matching pairs for MODE's temporary CPU
stack across LOCAL error recovery, GET within a scalar FN with LOCAL restoration,
and a handler issuing another MODE after a failed MODE conversion.

admissions-001 compiles the exact unchanged Mandelbrot source and returns
normally through a BBC batch driver. Its18329-byte image SHA bad741db equals the
first partial compile in full. All12 intentionally unsupported graphics/input
forms reject and preserve their old destination bytes. repack-001 rebuilds all
ten REPORT/runtime packers in isolated storage, preserves exact candidate13c2a488
at each step, and verifies all nine runtime templates unchanged.

Add an optional bounded --profile argument to the existing baseline harness so
its CLI run does not disturb the separately occupied self-build fixture. The
fresh hosted-baseline-001 completes39 cases/15 native executions, assembler
oracle and repeat; all15 full images and24 rejection diagnostics/old outputs
match the frozen earlier6597a0df baseline exactly. These are compatibility
checks, not performance measurements.

full-native-001's host controller exits143 with no known cause after a partial
UART capture. Retain that incomplete attempt without inferring final GET/MODE
or normal return. Fresh full-native-002 and independent full-reference-001 use
separate profiles and remain active, as does native-build-002. Live source and
native distribution remain unchanged pending their results.

C010 full-native-002 completes the unchanged full source:328833 GCOL/PLOT pairs,
2959501 graphics bytes/SHA2988ce82, supplied key only after the final observed
plot, MODE1 acknowledgement and actual MOS status0. Host controller1214.525s
was concurrent with other jobs and is not a CPU/performance benchmark. The
separate full reference run remains active; no full-pair/rendered pass is yet
claimed. Preserve full-native-001's earlier unknown-origin143 interruption.

Stage the exact18329-byte/bad741db program under a new mandelbrot-c010.bin name
in the Author's existing Oryx emulator SD directory, after checking the original
source hash. No emulator process, source file or root compiler is changed. The
copy/fsync/sync succeeds, but visual-fixture-001 records a final receipt-formatting
NameError (missing remote json import). Do not replay that write. Correct the
helper and perform a separate read-only full-file verification: visual-fixture-002
confirms exact image bad741db, without new writes. The Author receives MOS LOAD/
RUN instructions; no human result is implied by staging.

The first old-native rebuild attempt native-build-002 later returns host exit143,
with unknown termination origin and only256674 emitted bytes. Freeze its actual
partial image/console/source/seed, without treating it as executable or proof.
Restart unchanged source under native-build-003, with30-second controller
heartbeats and explicit signal/failure capture (as in the established C006
controller). Live source/native image remain6597a0df/299a3119. Prepared C010
promotion and package helpers require completed matching evidence before live
replacement; package updates check old managed hashes and preserve other files.

C010 full-reference-001 completes actual pinned interpreter execution of the
unchanged source. Both full CPU runs produce328833 GCOL/PLOT pairs and the
same2959501-byte graphics stream, SHA2988ce82. compare_full.py verifies both
frozen manifests and complete stream bytes, then freezes full-pair-001. Both
supply a key only after the final plot, restore MODE1 and return normally. The
reference controller2505.852s and native1214.525s were concurrent workload
observations with a protocol-only peer, not a paired performance benchmark.
Neither renders pixels; the Author's newly staged native visual result remains
pending. Root compiler/source are still the older qualified version while the
fresh native build and its automatically sequenced native qualification proceed.

C010 native-build-003 completes2261.251 controller seconds:329054 bytes,
SHA a59160c44784dfb37e0606145e5cbcdb35c390651377e6162cffab03ded592ba.
Complete GNU runtime/entry/compact checks pass. Native normal-prompt Mandelbrot
compilation yields the exact18329-byte/bad741db image. Native baseline39,
representative12 and18 fresh reference/native graphics/key pairs pass; all ten
representative full images also equal their C006 counterparts. These successes
remain bound to source13c2a488 and do not establish native self-source fit.

Actual native-self-001 reports No room at source line19216, the symbol-name
store, then returns to MOS with autoexec aborted before its final echo. The
329054-byte image's96674-byte heap is already below C005's97366 mandatory/
observed lower bound before new metadata and allocator overhead. The controller
is waiting after the program has failed; verify its exact owned argv and the
actual No room log, then send it SIGTERM to freeze evidence and close its idle
CLI. self-fit-block-001 records this intentional post-failure action. The native
pipeline correctly remains failed, with eight successful stages and no self
success. The live6597a0df/299a3119 source/image remain unchanged.

A size-only fixture growth-001 initially lacks a PROClabel stub and rejects;
preserve that fixture failure. Corrected growth-002 measures3642 body-code bytes
with constant stubs, while the actual complete image increase is4779. The full
image and actual failed self-source own the resource decision.

Scope C010's necessary compiler-private fit work explicitly. make_fit_candidate.py
mechanically factors85 assignment-position zero resets (not comparisons),26
adjacent depth-reset pairs and17 pure equal-index SFIX calls. It reuses existing
variable names and preserves all resource capacities, runtime modules, language
and numeric representations. Initial ac24edae is retained in fit-refactor-001;
its hosted39 and12 rejection checks pass and it emits the same Mandelbrot image.
The selected b8afbfdb revision spells the three typed counter resets as standard
FALSE/integer0; ordinary source decimal readers are unchanged. Its fresh hosted
39 cases/15 executions, GNU oracle, repeat and all24 diagnostics preserve exact
earlier images/outputs (fit-hosted-baseline-002,45.012s). fit-admissions-002 also
emits exact bad741db and preserves all12 rejected outputs (84.114s). The initial
ac24 timings107.190s/150.399s are separate observations, not benchmark evidence.

fit-repack-001 reproduces exact b8afbfdb after all ten packers and verifies all
nine unchanged runtime templates. Its old-native build and fit pipeline use
separate canonical c010-fit-build/c010-fit profiles. The fit self controller
also detects fatal/aborted-autoexec output, avoiding a wait for an impossible
marker. Native fit is still an actual-execution gate; the source refactor alone
is not a successful self-build. No live promotion, package replacement, rendered
result or new physical operation has occurred.

The selected b8afbfdb source completes all18 fresh reference/native graphics/key
pairs in fit-wire-basic-001, fit-wire-bounded-001, fit-wire-errors-001 and
fit-wire-interactions-001. These preserve the initial prototype's complete
program images/streams and all local/error/input behavior; rendered acceptance
remains separate. Its native seed build continues with frozen exact source in
fit-native-build-001; fit-native-pipeline-001 waits for that completed image.
The native image/self-source fit remains unclaimed until actual execution.

The first fit build's tool session later returns143 despite progress heartbeats;
fit-native-pipeline-001's waiting session also returns143. A filtered native
host process check confirms their controllers and emulator are gone. Neither
produced a complete image/qualification record; retain both incomplete cohorts
with unknown termination origin. The separate error waiter is still alive but
its prerequisite can no longer complete. Verify its exact argv/CWD and stop only
that owned waiter; controller-migration-001 records the intentional dependency
recovery. No language/compiler error was observed in that interrupted fit run.

Run the identical frozen b8afbfdb source through fresh fit-native-build-002 under
a finite transient user service, with two dependent finite qualification services
for native/self/regressions and error39. durable-launch-001 records their exact
scripts/arguments, invocation IDs, project-local log paths and runtime limits.
No unit is installed/enabled for login/startup; they collect on exit. The build
limit is7500s (controller guard7200), dependent service limits16000s. Actual
user-manager verification shows all three active/running and normal filename
prompts in the new build log. Launch success is not a test pass. The reason for
the earlier tool-session terminations remains unknown; service lifetime is now
independent of those sessions. No hardware/Oryx emulator control is involved.

The fit error controller reuses the unmodified C00639-case native harness in the
now-idle root automated profile, while self-building and serial regressions use
their separate fit profiles. It additionally requires whole-image equality to
all39 older C006 error images. This checks the private bookkeeping refactor's
existing error/string/control paths without changing numerical/runtime sources.
Prepared fit promotion gates require those exact completed results, along with
fresh self-image equality and the other retained evidence. Live admissions remain
unchanged. Reference/test catalogue documentation now records the actual MODE/
GCOL/PLOT/GET audit and full unchanged Mandelbrot parity with rendering/timing
limits explicit. The conditional documentation updater runs only after promotion.

The durable fit-native-build-002 completes normally in2031.521 controller
seconds, producing327290 bytes, SHA
3c761c16c420a79ed04d00e3803ab00b3af54764ea66c93bb0b9a88c78f1b348.
This saves1764 bytes against the first graphics prototype without changing any
runtime module or resource capacity. Complete GNU image checks pass; its native
Mandelbrot compilation produces the same bad741db image. Native baseline39 and
representative12 pass, with all ten representative images identical to C006.
Fresh native error39 matches pinned reference output/ERR/ERL, deterministic
repeat and all39 earlier complete images (fit-native-errors-001,
fit-error-controller-002; harness622.971 controller seconds). The self-build
remains active and unqualified; live source/image and package are unchanged.
All18 fresh native graphics/key pairs also pass in the four
fit-native-wire-*-001 cohorts. Verify each completed cohort's retained manifest
before checkpointing; leave the active self/pipeline directories unstaged.

Actual fit-native-self-001 also reports No room at19216 after716.502s, now
detected promptly by the controller. No output is opened and the CLI closes.
fit-native-pipeline-002 is failed with its eight other successful stages
preserved. No live promotion occurs. All old fit services have completed.

metadata-source-001 records a narrower storage refinement from exact b8afbfdb:
private prefixes $if/$var/$bind/$proc become $/$V/$B/$P. All replacements are
exact quoted strings, consistently at definitions and references. Symbol names
are compared as complete strings, never decoded by their prefixes. Decimal
flow names, capital variable/binding/routine names, lower-case runtime exports
and public @/# targets occupy distinct namespaces; scoped targets retain $p.
The address/sort algorithms, emitted instruction/data sequences, all capacity
limits and runtime templates are unchanged. Current source is70d3c5c6, retained
separately as candidate-meta.bas; the earlier candidate-fit.bas is not edited.

Fresh finite metadata services are launched under distinct names and receipts.
The previous qualified native compiler builds the exact new source. A separate
hosted job repeats baseline39, full-source/admissions, all ten repackers and18
wire pairs. Dependent native/self and error39 jobs wait for completed manifests;
profiles remain separate. A one-pass interpreted layout observer uses the idle
c010-wire profile to count actual symbol/other string bytes and prefix savings,
with host-only PRINTs and exact unchanged target source. It neither writes an
image nor claims native fit. metadata-launch-*-001 records finite limits and
script hashes; no startup configuration or hardware/Oryx operation is involved.

meta-hosted-pipeline-001 completes all eight stages in545.649 controller
seconds: fresh baseline39/15 (45.166s, GNU golden/repeat,15 earlier whole images
and24 diagnostics/preserved outputs identical), full unchanged Mandelbrot plus
12 output-preserving rejections, ten exact source repackers/nine unchanged
runtime modules, and18 fresh reference/native graphics/key pairs. All manifests
are verified before retaining this checkpoint. The native build and interpreted
layout observation remain active; no self-fit or live promotion is claimed.

meta-symbol-layout-001 completes1339.496 controller seconds. Actual BBC layout
counts327205 output bytes,2128 symbols/229 routines/254 bindings and seven
target pages. Symbol contents occupy9764 bytes, saving4433 versus the equivalent
long-prefix names; other metadata strings occupy5550. The output sentinel is
unchanged because this observer performs only layout. metadata-bounds-001
verifies identical explicit DIM declarations and the unchanged runtime catalogs
against C005's77945-byte fixed lower bound. Mandatory/observed total93259 against
98523 available leaves5264 before omitted peak/header/allocator costs, versus
4087 for the older qualified source. Actual native self-build remains required.
The old-native build is writing its output normally; no promotion occurs yet.

meta-native-build-001 completes normally in2031.510 controller seconds:
327205 bytes, SHA40e4ae06730b6735696f5f07962efd10e6c9cfbdc44a81b65dd6e9ce1c82355a.
It matches the independently observed layout byte count. Complete GNU runtime,
entry, heap/arena/guard and compact PIC/bridge checks pass in
meta-image-checks-001. Its normal-prompt Mandelbrot compilation again produces
the exact bad741db full image (meta-native-mandelbrot-001). Native/self and
error39 services start their actual fresh jobs; live source/image remain old
until all gates, including complete actual self-image equality, succeed.

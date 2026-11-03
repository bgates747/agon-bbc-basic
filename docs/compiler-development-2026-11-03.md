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

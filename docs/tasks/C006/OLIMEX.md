# C006 physical Olimex qualification

The Author selects the shared Olimex bench and authorizes consultation with
Extender on scheduling, file transfer and remote CLI access. This is a prepared
scope; no physical lease, deployment or result exists yet. Exact target access
and current firmware identities remain in Extender's machine-local records.

## Scope and custody

1. Use the canonical `agon-dev-env/cross-agent/olimex-bench` reservation/grant
   protocol. Prepare source, images and expected results before requesting the
   finite run. Assert ownership immediately before every target operation.
2. Retain installed EMOS, mainboard VDP, P4 firmware, listener, startup and wiring.
   No flash, reset, display-mode change, startup edit or production installation
   is part of this compiler qualification. If readiness is uncertain, stop and
   coordinate with Extender rather than replaying commands or recovering blindly.
3. Use `/extender/diagnostics/bbc-basic/RUN-ID` for fixtures and
   `/agents/extender/results/bbc-basic/RUN-ID` for outputs. Never
   overwrite unrelated files. Upload with the currently pinned staged client,
   explicitly start/exit the foreground listener, and verify transferred bytes
   by independent retrieval before executing them.
4. Use admitted remote keyboard/MOS CLI commands. Keyboard delivery is not
   command completion. Obtain actual correlated console/result evidence using
   the supported observation channel advised by Extender. Dependent long-running
   commands belong in one verified finite MOS EXEC file where possible; filename
   prompts require observed readiness before each input.

## Intended finite run

1. Qualify the exact source/image in the emulator first. Pin every deployed
   source, executable, fixture and expected result in a manifest. No compiler
   source transformation or machine-image patch is permitted during deployment.
2. Run representative native compiler fixtures, covering numeric output,
   branching/loops, FN/LOCAL restoration, arrays/indirection, DATA, files and a
   compile-time rejection with preserved previous output. Record actual results
   and MOS return status, distinguishing fixture output from completion markers.
3. Run the native compiler on its own source through its normal prompts; retrieve
   the emitted image and compare every byte with the qualified emulator seed.
   Run the hardware-produced compiler on the same source again and require exact
   equality. Keep the full default interpreted/native generation chain evidence
   separate from these physical runs.
4. Record preparation, transfer, execution and retrieval durations separately.
   A duration observation is not a performance benchmark or a timeout estimate.
   No optical/audio or human acceptance result follows from remote CLI success.
5. Exit owned work/listener, release owned input/observers/jobs and leave normal
   CLI with text output and visible flashing cursor. Preserve startup and all
   installed components. Retain a fresh physical clean-state observation and
   release the lease before offline analysis; notify Extender immediately.

## Compiler memory evidence

For source6597a0df, the checked324275-byte seed occupies&40000..&8F2B2.
Its explicit private heap is&8F2B3..&A7EFF (101453 bytes), activation arena
&A7F00..&AFEFF (32768 bytes), and guarded user-memory end&B0000 retains the
256-byte gap at&AFF00. Control records, scalar payloads and expression pools
already occur inside the static image. Private DIM/string contents use the
explicit heap; LOCAL snapshots use the arena. Native self-source execution
has passed on the pinned CLI, not yet on this hardware.

Native calls additionally use the MOS-provided ADL stack and preserve/restore
entry SP. Read-only EMOS source inspection finds exec24 calling the ADL entry
without installing a separate program stack; defines.h reserves2048 stack bytes,
and the startup source initializes SP from the linked stack symbol. These source
observations do not establish installed firmware memory or maximum stack usage.
During entry qualification retain the actual installed MEM report through the
verified console channel, and record stack/component boundaries before invoking
the compiler. Do not allocate compiler memory above&B0000 or change MOS/EMOS.

## Coordination evidence

1. Initial direct request: Extender2026-10-13Sol, task
   `01a13443-f921-72d1-9d3e-d05652c7a750`; canonical mailbox message
   `2026-11-03_02-34-30_bbc-basic_bbc-olimex-access-request-one`.
2. Read the central lease protocol, Extender bench constraints, staged-transfer
   pin/operating guide, keyboard sequencing and test-appliance lifecycle.
   Extender guidance message2026-11-03_02-36-44_linux-extender_bbc-olimex-access-guidance-one
   confirms an empty logical registry, not fresh physical readiness. Reserve only
   after emulator qualification and exact fixture preparation; Extender performs
   fresh entry reconciliation before granting. Legacy console evidence uses the
   maintained joined-DTR/RTS mainboard passive capture plus VDU2 printer mirror
   and a verified sentinel; VDU3 disables it. P4 screen text is not a Legacy
   console observer. Do not open ordinary pyserial or touch reset lines.
4. Operational references: Extender docs/mainboard-sd.md, remote-keyboard.md,
   serial-monitor.md, sd-layout.md and procedures/test-execution.md. Use the
   pinned staged client SHAf7aa43bd, fresh persistent metadata/keyboard/job states,
   and a fresh metadata connection for listener EXIT after staged jobs. Follow
   current machine-local records for addresses/devices; keep them untracked.
   File payloads never use the old per-record transport. No live readiness or
   component identity is inferred from a historical receipt.
3. A proposed append to the shared mailbox index was rejected by automatic
   approval review citing published Markdown restrictions. The immutable request
   and direct chat were delivered; the shared index was left unchanged.

## Offline packaging

`prepare_olimex.py` requires a completed normal-main four-image bootstrap,
completed12-case native regressions,39-case native baseline equivalence and39
fresh native source-error programs. It verifies their retained manifests,
source and complete image equality, and creates a new host-only bundle. It
copies qualified source/images, fresh per-stage MOS command files, filename
inputs, exact upload destinations and retained expected outputs. Rejection
sentinels map to the intended existing result files, and the actual native
file-I/O fixture supplies the expected native-test.dat bytes. It neither compiles nor accesses hardware.
The caller must deploy rejection sentinels under the corresponding output names
before those cases, assert its actual lease and verify all payload readbacks.
The generated command files use LOAD/RUN ., mark entry/return and start the
foreground listener only after application return. The caller observes prompts
and markers before providing inputs or transferring files. Syntax checks pass;
real-input packaging now passes against all completed prerequisite cohorts.
Frozen olimex-fixture-001 and [the finite run plan](OLIMEX-R01.md) identify40
payloads/441398 bytes and the exact comparisons. No physical result follows.

## Explicit operation journal

`olimex_step.py` delegates one selected operation to maintained Extender clients.
It requires an existing lease, verifies the offline bundle manifest, asserts
current ownership immediately before every delegated operation, and uses fresh
local journals for new operations. File writes stay under the bundle's declared fixture/results
roots; payload uploads must match its manifest. File payloads use the pinned new
staged client. Metadata/transfer actions first observe an online major2 listener;
EXIT uses a fresh metadata state after worker sessions, then observes both
online=false and pending=false before recording completed handback. Keyboard completion
means event emission, with actual MOS/application completion observed separately.

The ignored local config supplies `extender_url` and, for capture,
`mainboard_serial` from the canonical machine records. Operation receipts contain
local details and stay under C006/build outside the exported fixture. The helper
invokes Extender's own Python environment and maintained serial monitor; it
does not implement a new transport, reserve/grant, reset, flash, retry uncertain
work or dispatch another operation. Capture uses new ready/stop/output files.

`olimex-step-host-003` retains six device-free checks with every subprocess
mocked: lease failure prevents target dispatch, every status query checks its
owner, relative paths become absolute for delegated tools, upload/traversal
guards reject wrong paths and wrong protocol prevents transfer submission.
Earlier001/002 cohorts retain their narrower checks. No network/serial access
or hardware result follows from these tests. Actual operation remains pending
the full compiler qualification, exact prepared plan and Extender grant.

Extender's source-only review
2026-11-03_04-24-44_linux-extender_extender-bbc-operation-helper-review-r01
confirms the current argument order and client interfaces. Its EXIT observation
correction is implemented: acknowledgement is recorded separately, with bounded
lease-checked online/pending observation before successful handback. Host005
retains eight mocked tests, including offline-but-pending delay and uncertain
EXIT stopping without a new session or retry. These are consumer host tests.

Never rerun an uncertain operation using a fresh record directory. Retain its
original staged-state.json or metadata-state.json, assert the current lease and
use the maintained client's status/resume against that same state to observe or
resolve the existing request. Do not submit a new POST, discard a spool, delete
journals or reset as automatic recovery. Capture ready proves port open only;
VDU2 plus a newly observed printable sentinel still qualifies the Legacy text
channel. Download completion/SHA records arrival; independent expected-byte
comparison remains required before execution. The900-second transfer timeout
is an observation/request bound, not a compiler estimate or cleanup deadline.

## MOS batch error boundary

Extender source qualification
2026-11-03_04-31-02_linux-extender_extender-bbc-exec-error-boundary-r01
confirms that a nonzero RUN aborts EXEC before later end-marker/listener lines.
The compiler's normal main catches compile diagnostics with REPORT/CLOSE/END;
the prepared native suites require actual compiler status0, including rejection
cases. Packaging checks those retained compile-status logs and excludes any
planned generated-program status other than0. This is an expected return
contract, not permission to treat a missing marker as success.

Every generated batch puts RUN on line4. If an unexpected nonzero result aborts
it, record the exact fresh launchfile/line error and actual returned CLI; do not
wait for a supposedly guaranteed end marker or assume the listener restarted.
Application entry, output/result validity and CLI return are separate evidence.
Do not repeat RUN or an uncertain SAVE. Ambiguous foreground state stops further
dispatch and is coordinated with Extender; no automatic recovery/reset occurs.

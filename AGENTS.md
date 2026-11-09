# BBC BASIC native compiler project handoff

Read `/Agon/mystuff/agon-dev-env/codex/AGENTS.md` first. It owns shared
environment, ownership, assembly, emulator, hardware and coordination rules.

## Project contract

1. This repository contains the reference BASIC V ADL interpreter and the live
   BBC BASIC compiler at `compiler/compiler.bas`, with assembly runtime under
   `compiler/runtime/`. Keep interpreter changes separate. Python may prepare
   source, package assembly and orchestrate tests; it must not implement a BASIC
   compiler or substitute a numeric representation.
2. Work on `codex/native-bbc-compiler`, origin
   `https://github.com/bgates747/agon-bbc-basic.git`. Keep development here;
   promote to main only after testing is accepted. Main remains2998edd4.
   Do not create a redundant compiled branch.
3. For supported conventional programs, speed is the only intended observable
   behavioral difference. Preserve reference quirks,32-bit integers,float40,
   conversion/rounding/output and LOCAL behavior. EVAL remains excluded. Agreed
   line-number/label syntax and explicit unsupported admissions retain scope.
   Interpreter improvement ideas belong in `compiler/INTERPRETER-FINDINGS.md`;
   the superseded exact-decimal experiment does not authorize divergence.
4. Before changing behavior, read compiler/README.md, SPECIFICATION.md,
   COMPATIBILITY.md, REFERENCE.md and the latest dated development log,
   currently `docs/compiler-development-2026-11-08.md`.
5. TODO.md is the only unfinished-work list. Immutable IDs map to
   docs/tasks/ID.md; experiments/scripts live under docs/tasks/ID/. Read
   docs/tasks/README.md and retrospective C000/C001. Task briefs own scope and
   acceptance; dated logs own chronological evidence. Preserve frozen committed
   evidence; use new cohort names. Promotion records identify exact source,
   qualification and destination. Automated passes are not human validation.

## Current qualified compiler

C010's implementation and automated qualification are promoted. Live source
compiler/compiler.bas is SHA
70d3c5c6f4da44cf865c36c3f4edef143b9e37c662097067a5e6ceac414c300e:
113293 bytes/2104 lines,187 PROC and42 FN definitions. Actual source layout uses
2128 symbols/229 routines/254 bindings and seven target pages. Live native
compiler/bin/compiler.bin is327205 bytes, SHA
40e4ae06730b6735696f5f07962efd10e6c9cfbdc44a81b65dd6e9ce1c82355a.

C010 adds MODE, GCOL, PLOT and bare numeric GET for exact unchanged Mandelbrot.
Native baseline39, representative12, error39/ERR/ERL/repeat and18 graphics/key
pairs pass; hosted checks, all ten repackers/nine unchanged runtimes and36
complete graphics image comparisons pass. Exact Mandelbrot source1eb897c8
emits18329-byte bad741db; full actual reference/native CPU runs match2959501
graphics bytes/328833 plots, final key wait, MODE1 and return. These observations
do not render pixels or measure a paired performance benchmark.

meta-native-build-001 uses the older qualified native seed299a3119 and completes
2031.510 controller seconds. Its actual new native self-build completes1964.124s
and matches every byte of40e4ae06 (meta-native-self-001). All nine pipeline stages
complete in meta-native-pipeline-001. live-promotion-001 gates/copies that actual
self-output unchanged. No new interpreted four-stage or hardware result is claimed.
The earlier failed prototypes/interrupted controllers remain frozen, including
both No room failures. C010/AUDIT.md owns details and private symbol namespace
proof. Private resets/SFIX factoring and shorter symbol text retain self-fit;
4096 symbols, all language/resource limits, runtime modules, numerical behavior,
&A7F00 heap endpoint,32768 activation bytes and &AFF00 guard remain unchanged.
The lower-bound storage observation leaves5264 before omitted costs; actual
self-compilation, rather than that estimate, establishes this source's fit.

All finite C010 services/jobs have completed. service-completion-001 verifies
an empty owned service/controller/emulator list at01:33:54UTC November4
(20:33:54EST November3). No hardware custody or Oryx emulator session was selected.
C008 manual results remain pending, and C009 is a possible low-priority feature
only. The53-file portable refresh (501472 bytes, manifest1a9e5b2c) is frozen in
C010/evidence/manual-package-001 and delivered to the existing Oryx emulator SD
by emulator-update-001 with sync and no process control. C010 is complete.
The returned Console8 card is now updated/synced by card-update-002 and remains
mounted. Failed001 stays immutable. C008 retains only manual results. Preserve
user files and older frozen evidence; both destinations have the current package.

## Earlier C005/C006 basis

1. C001–C005 and C007 have completed their initial scopes. C005's language,
   streaming/resource and compact-runtime work is promoted. Earlier qualified source SHA:
   `6597a0df3f99b4f43c42bff1cdbc59f5fdf730c57837f3d4112a598fbfbe5fb8`.
   It has2067 lines,177 PROC/42 FN definitions. Actual self-source uses2094
   symbols/219 routines/254 bindings and emits324275 bytes.
2. The first native self-source preflight succeeds through normal prompts with
   status0 and exact full-image equality to the interpreted resource seed:
   `299a31190c380541a73ed9eb144a303fa37abccc4f3c3e0ad47f99f1538122c0`.
   Evidence: C005/packed-source-002 and C006/packed-native-preflight-001.
   Controller durations3911.701s/1983.653s are not hardware benchmarks.
3. C005 all39 fresh source-error oracles/repeats/runtime links pass, with all39
   complete images identical to earlier2f81c6fb. The73821-byte program and2048
   labels execute;4097 labels reject; large repeat matches. Fresh promoted live
   baseline39/15 passes49.956s and nine integrations142.153s. Promotion and
   REPORT/all nine packer identity are retained in packed-live-promotion-001.
4. Read C005/COMPACTION.md, STREAMING.md and compact/ABI.md before resource
   changes. The compiler scans signatures, then lays out, validates and streams
   BPUT output without fixed output/fixup buffers. Keep4096 symbols, exact
   private u24/u16 cells and reusable branch/DATA pages. These private choices
   do not narrow BASIC program values. Code plus heap respects&B0000; the
   compiler heap ends&A7F00, with32768 activation bytes and the&AFF00 guard.
5. The394-byte/29-relocation adapter uses fixed native CALL operands, not a
   bytecode/source execution loop. It calls unchanged NUM/MEM/ACT routines.
   Keep its code before STR pools/heaps. Control remains8657 emitted bytes;
   the private loader stores465 initialized bytes and streams8192 zero frames.
   Error repacking must preserve following DATA64000. All ten generators
   (REPORT plus nine module packers) reproduce the exact source.
6. Numeric baseline and calling conventions: C002/LITERALS.md, OUTPUT.md,
   EXPRESSIONS.md, ABI.md and runtime/vendor/PROVENANCE.md. C003 owns scalars,
   strings, slices/conversions/search/repetition/slice-store. C004 owns typed
   control, scalar PROC/FN/LOCAL and return kinds. C005/MEMORY.md, IO.md,
   DATA.md and ERRORS.md preserve actual platform quirks and partial admissions.
   The compatibility matrix remains authoritative; no full BBC implementation
   or unsupported feature admission follows from self-compilation.

## Completed qualification and authorization

1. C006 completes the initial self-hosting/physical scope; C008 now owns the
   staged manual qualification awaiting Author results. Read C006.md,
   C006/BOOTSTRAP.md, C006/OLIMEX.md and C008.md for their distinct evidence.
   Actual normal-main G0, native G1/G2 and repeat produce identical324275-byte
   images299a3119. live-bootstrap-001 was interrupted during unfinished repeat
   (host exit143/unknown origin). live-bootstrap-resume-001 verifies/carries the
   actual three complete stages and executes a fresh repeat, explicitly retaining
   that lineage. Native baseline39, representative12 and fresh ERR/ERL39 suites
   all pass. Preserve complete frozen manifests and original failure records.
2. Physical Olimex evidence: olimex-small-001 passes12 compiler invocations and
   ten generated programs, including exact full images, file bytes FF74657874
   and two preserved-output rejections. Actual first hardware self-source matches
   all324275 bytes; olimex-self-a-late-001 records the late completion separately
   from immutable olimex-self-a-bound-001. No replay/reset occurred. Generation7
   was cleanly released2026-11-03T14:48:42.976464Z.
3. Separately granted R02 uses that actual first hardware output unchanged and
   the same source. Fresh entry/MEM and3 readbacks pass. Its sole self-source
   invocation completes within6600s; original result is byte-identical to both
   the hardware input and bootstrap. Evidence: olimex-repeat-deployment-001 and
   olimex-repeat-001. Host observed interval5950.803s and GET245.017s are not
   CPU/benchmark times. Generation8 was cleanly released2026-11-03T16:54:23.807673Z,
   next_request=null. Both generations restore incoming directory/native0/text/
   cursor/mirror, preserve complete startup/listener bytes and close readers;
   fresh neutral/offline/idle/ownerlessUSB checks pass. Verified firmware
   provenance is retained without claiming fresh flash reads.
4. No hardware custody, owned workload or observer remains. All old lease tokens
   are invalid. Private receipts remain ignored under C006/build/physical-c006-r01
   and physical-c006-r02; no target operation follows from historical records.
   Any future physical run needs a new finite scope/reservation/fresh grant.
5. C006 promoted the earlier299a3119 executable unchanged from its second
   actual hardware output; native-promotion-001 retains that exact evidence.
   C010 now promotes40e4ae06 from its actual fresh Pi native self-build. The
   current compiler/bin/manifest.json separates the two versions and retains
   earlier physical provenance; the exact root/vendor notice is alongside it.
   MOS LOAD then RUN . starts normal filename prompts. Its runtime is included;
   no installed interpreter or assembler is required. No main merge occurs.
6. Use .venv/bin/python explicitly; compiler/README.md owns commands. Ignored
   .emulator/ is automated CLI only, launched through its generated profile-local
   ./fab-agon-emulator wrapper. Freeze owned results before subsequent work.
   No graphical/human optical validation has occurred. The Author's new C008
   card path authorizes bounded Oryx file deployment; it does not select a new
   Oryx emulator session. Pi5 automated emulator work remains authorized.
7. The Author authorized completing the remaining TODO and skipping earlier
   approval stops, qualifying/checkpointing this development branch without
   asking again. Commit/push authority persists for the configured origin.
   This does not grant main promotion or establish human/performance evidence.
8. C007's completed source search and measurement contract are compiler/TESTING.md.
   No paired performance benchmark or speedup has been measured. Feature limits
   remain explicit in the compatibility matrix despite self-hosting completion.
9. The Author authorizes consultation with Extender for Olimex scheduling,
   transfer and CLI. Our mailbox is bbc-basic. Use Extender's maintained
   scripts/agentcoms.py and structured JSON stdin; never handwrite mailbox files.
   Canonical physical custody is agon-dev-env/cross-agent/olimex-bench. Both clean
   handbacks were delivered through durable mail and immediate steering; latest
   is2026-11-03_11-55-11_bbc-basic_bbc-c006-r02-clean-release-one.

Extender's2026-11-03_14-49-11 retained-bench notice records a later generation9
checkout for BENCH-013. Extender retains custody until the Author and Extender
select another project's slot; completion of an Extender subtask is not automatic
release. Future requests still use the canonical FIFO and finite ready plan,
followed by an explicit grant before any target access. Re-read current central
instructions and the notice before requesting hardware; do not infer availability
from an empty queue or an old completed run. Console8 remains separately
coordinated by the Author. This project has no new reservation or bench operation.

Extender's14:55:28 adoption notice reports canonical /emos/sdserve.bin updated
to24753 bytes, SHA2560566e17f18747c2e625d2450ce5324a2b1097bce323a5e4d70fad6dcb41cdff2
(sdserve-v0.3.0-b2026-11-03-08-07-19Z, Extender8aa3245d). The22968-byte04e7
listener remains historical C006 evidence/rollback, not a current selection.
Before any future finite plan/grant, read Extender's current
docs/mainboard-sd-tools.json and mainboard-sd.md; do not infer current listener
identity from historical FAST-TRANSFER-PIN.json. Major2/client ABI is reported
unchanged. No existing cohort, helper pin, card package or hardware is changed
by receipt of this notice; retained custody still requires an explicit new grant.

## Manual Console8 package

C008's selected Oryx card path remains
`/run/media/smith/AGONC8/mystuff/basic-compiled/`, Agon path
`/mystuff/basic-compiled/`. Keep that root stable. Current managed card release
has53 files,40e4ae06 compiler/70d3c5c6 source and13 supplied test directories.
The earlier50-file299a3119/6597a0df package included the same MIT nano editor,
notices and twelve earlier tests. Its initial deployment completed14:46:22EST November3,
with sync and the card left mounted; receipt C008/evidence/manual-deployment-001.
No user result is implied. Do not delete or overwrite later user programs/results.
deploy_sd.py refuses a nonempty target: future updates need explicit preservation.
Editor is a&B0000 moslet; compiler/generated programs run at&40000. No firmware
or startup change, emulator reservation or hardware test is part of deployment.
Markdown documents must use .md, not .txt. The manual package's compatibility
document is compatibility.md; readme.txt and the remaining .txt files are plain
text. C008/evidence/markdown-extension-001 records the card correction and updated
manifest; preserve the earlier deployment evidence unchanged.
Consumer packages must be installation-independent. Keep maintainer hostnames,
mountpoints, repository paths and task-evidence paths out of every payload file,
including JSON metadata and test instructions. Use package-relative paths and
links to files actually shipped. C008's portable manual-004 package and
portable-package-001 receipt supersede the original development-specific payload;
development provenance and deployment coordinates remain repository-only.

C010's current53-file/501472-byte portable package is frozen in
C010/evidence/manual-package-001/payload and prepared in C010/build/manual-001,
manifest1a9e5b2c1d4300ff25ec766f63487bc0c577aeeb80b1a96378dac364dfacee9f.
It includes current40e4ae06 compiler/70d3c5c6 source and13 tests; all twelve
earlier test directories are unchanged. It is delivered to Oryx's existing
/home/smith/Agon/flexe-emulator/sdcard/basic-compiled by emulator-update-001,
with only eight checked replacements and exact existing Mandelbrot additions
preserved. No emulator was launched/controlled. Rendering/manual acceptance
remains pending. The provided Mandelbrot native image is18329-byte bad741db.

Earlier card-update-001 failed before writes while the card was absent; keep
that receipt immutable. After the Author reports its return, card-update-002
completes20:45:52EST November3 with ten guarded managed writes and sync. The
card remains mounted. Its manifest is now1a9e5b2c; do not replay the old7fe79c81
transition. Future updates require the current baseline and fresh receipt names,
preserving all user programs/results. No firmware/startup or target run occurs.

The canonical default-flexe guide and fresh PATH launcher read confirm the
default profile is /home/smith/Agon/flexe-emulator. C008/default-emulator-package-001
stops at an edited hello.bas; survey002 checks all53 supplied names, confirming
the other52 match exactly and syncing. The user's hello.bas (6241fbdb) remains
unchanged. C008/default-starter-preserved-001 supplies the exact packaged starter
53fb3b33 as hello-package.bas using exclusive creation and sync. It is an extra
file outside the unchanged package manifest. No emulator is launched/controlled,
and no human result, hardware custody or reservation follows from deployment.

Shared /tmp tmpfs filled during G2 handoff; only our inactive Cargo build cache
was moved to C006/build/relocated-cli-cache-001, preserving the active CLI at its
original /tmp path and exact hash. Evidence cli-cache-relocation-001; Extender
has since safely relocated its historical trees; /tmp has3.7GiB free.
Do not touch other owners' files.

Default emulator SD `/bin/compiler.bin` is also current327205-byte40e4ae06,
with exact notice `compiler-license.txt`; C008/evidence/default-bin-001 records
replacement of the known299a3119 executable and sync at20:53:40EST November3.
No emulator process was selected or controlled.

The Author now reports Mandelbrot compiles and runs on Console8, with a visible
qualitative gain in less computationally intense regions and inconclusive
comparison in intense regions. C008/evidence/author-mandelbrot-001 retains the
report; other manual cases remain open. No paired speedup is measured. C011 is
the broad benchmark/timing task. Its first42-case source and297-byte clock
helper are prepared with static checks only; no target compilation or timing
is claimed. C011/preparation-002 pins console8-004, manifestb0b44d96. Its archive
is staged on Oryx as /home/smith/Agon/mystuff/c011-console8-002.tar; card-stage-001
records the earlier absent-card failure. The Author returned the card;
card-stage-002 initially saw it absent, then fresh mounted-volume checks and
card-stage-003 deployed all eleven files to /mystuff/basic-compiled/benchmarks/
at23:02:14EST November3, synced and left the card mounted. Existing user files
are preserved. C011 awaits the Author-run pilot; earlier failures remain frozen. The Author will run Console8; no emulator runs or
virtual SD changes are permitted for this tranche.


Pi5 manager's November3 notice establishes the canonical heavy-work checkout
at agon-dev-env/cross-agent/pi5-workloads/README.md. Substantial Pi builds/tests
and native emulator runs need a finite reservation and explicit token/generation
grant, asserted before launch and released after teardown. Light preparation
remains compatible; no checkout was requested for C011 source preparation,
297-byte helper assembly or small synthetic/static checks. Time authority does
not override the Author's explicit no-emulator instruction or hardware custody.


## November8 pinned firmware audit

C012 brief frozen/pushed9255326; inspection audit complete in C012/REPORT.md and
C012/evidence/audit-001. VDPlet0.1.2-alpha official firmware is1100304 bytes,
SHA256b004570b607b45bbd6e87a3c704b65b23d3221981db3aac6cf2578aa22d766e3,
verified against release SHA256SUMS. All Alexe/Olimex/Console8 VDP tests/deployments
use it. Alexe/Console8 use release Eirene3.1.0_uart0_rc_3 ZIP mos-rc3.bin,
100879 bytes, d7a51147f3381cd68d56f3fbe4605434a897dfae1b049269afeba09ec2b7eb50.
Olimex uses Extender's current approved integrated EMOS; reconsult its selector,
not bare RC3. Required exceptions must be justified in scheduling requests.
No mandatory CBAS exception found by source/API inspection; no new runtime pass,
installed-state proof or flashing occurred. C008/C011 retain actual qualification.
Old text-only CLI tooling does not qualify the new firmware pair. Compiler
FIRMWARE.md owns policy; current C011 readme template is updated, but frozen
console8-004 and delivered card files remain unchanged. Existing no-emulator
restriction, test/component gates and hardware permissions persist.

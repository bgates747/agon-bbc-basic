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
   currently `docs/compiler-development-2026-11-03.md`.
5. TODO.md is the only unfinished-work list. Immutable IDs map to
   docs/tasks/ID.md; experiments/scripts live under docs/tasks/ID/. Read
   docs/tasks/README.md and retrospective C000/C001. Task briefs own scope and
   acceptance; dated logs own chronological evidence. Preserve frozen committed
   evidence; use new cohort names. Promotion records identify exact source,
   qualification and destination. Automated passes are not human validation.

## Current qualified compiler

C010 is the active implementation task: support the Author-validated unchanged
Mandelbrot source (MODE, GCOL, PLOT and numeric GET initially missing). Read its
brief before changing behavior. The Author requests logical commit/push groups
and continuing implementation. C008 manual results remain pending; C009 is a
low-priority possible feature only. Prior qualification below remains tied to
its exact older source/image until new evidence is recorded.

1. C001–C005 and C007 have completed their initial scopes. C005's language,
   streaming/resource and compact-runtime work is promoted. Live source SHA:
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
5. The qualified development executable is compiler/bin/compiler.bin, copied
   unchanged from actual second hardware output by promote_native.py after full
   evidence/source/license/release gates. compiler/bin/manifest.json and
   C006/evidence/native-promotion-001 retain provenance; the exact root/vendor
   notice is alongside it. MOS LOAD then RUN . starts normal filename prompts.
   It includes its runtime; no installed interpreter or assembler is required.
   Source and numeric/runtime behavior remain unchanged. No main merge occurs.
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

C008 is staged at the Author-selected Oryx path
`/run/media/smith/AGONC8/mystuff/basic-compiled/`, Agon path
`/mystuff/basic-compiled/`. Keep that root stable. Its50 files include the exact
compiler/source, MIT nano editor, notices, starter, compatibility/runbook and12
manual test subdirectories. Actual deployment completed14:46:22EST November3,
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

Shared /tmp tmpfs filled during G2 handoff; only our inactive Cargo build cache
was moved to C006/build/relocated-cli-cache-001, preserving the active CLI at its
original /tmp path and exact hash. Evidence cli-cache-relocation-001; Extender
has since safely relocated its historical trees; /tmp has3.7GiB free.
Do not touch other owners' files.

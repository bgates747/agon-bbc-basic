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

## Active qualification and authorization

1. Only C006 remains unfinished: physical Olimex qualification.
   Read C006.md, C006/BOOTSTRAP.md and C006/OLIMEX.md. Full normal-main G0,
   native G1/G2 and actual repeat now produce all four identical324275-byte
   images299a3119. Durations3951.738/1983.142/1997.471/1996.877 seconds are
   controller observations, not physical benchmarks. Original live-bootstrap-001
   was interrupted during unfinished repeat (host exit143/unknown origin).
   live-bootstrap-resume-001 verifies/carries the real completed three stages
   and executes a fresh repeat, explicitly recording that lineage; all four
   bytestrings match. The cohort is complete. live-native-baseline-001 passes
   all39 cases (15 full images/24 diagnostics) in245.15 controller seconds.
   live-regressions-001 passes all12 cases, including exact file bytes, in131.049s.
   live-native-errors-001 passes all39 fresh ERR/ERL/native programs, complete
   runtime/entry links and deterministic repeat in612.766s. All native suites
   are finished and frozen. No physical compiler result exists yet.
2. C006 native_baseline.py compares39 actual standard sources against15 complete
   baseline images/24 diagnostics. regressions.py runs12 representative cases;
   native_errors.py runs39 fresh reference ERR/ERL programs. Prepared workflows
   are now retained results; preserve exact input/runtime hashes and interrupted state.
3. Use `.venv/bin/python` explicitly. compiler/README.md owns commands. The
   ignored `.emulator/` is automated CLI only; launch through its generated
   `./fab-agon-emulator` wrapper from the profile directory. One active run owns
   that SD; freeze output before the next run. No project graphical/human or
   physical compiler validation has occurred. Never contact Oryx until the
   Author says it is available; Pi5 automated emulator work is authorized.
4. The Author explicitly authorized continuing through the remaining TODO and
   skipping previous approval stops, qualifying and checkpointing this branch
   without asking again. Commit/push authority persists for the configured
   origin. A waiver is not a test result; report real limitations truthfully.
5. C007's completed source search/measurement contract is compiler/TESTING.md.
   No new benchmark performance is measured by the controller durations above.
6. The Author specifically authorizes coordination with Extender for Olimex
   time, file transfer and remote CLI. Our mailbox is bbc-basic; use Extender's
   maintained scripts/agentcoms.py with structured JSON stdin, never handwritten
   mailbox files. It owns routing/quoted metadata/idempotency. The initial
   malformed request was preserved/repaired; C006/OLIMEX.md owns the record.
7. Physical custody is solely agon-dev-env/cross-agent/olimex-bench. Prepare an
   exact finite fixture, reserve, receive Extender's grant and assert its token
   before target operations. Physical bundle olimex-fixture-001 and finite plan
   C006/OLIMEX-R01.md are prepared. Reservation ee0ad664f72a is submitted;
   Extender granted generation7. Exact lease/config/receipts are local under
   C006/build/physical-c006-r01/{grant,config}.json; assert current ownership
   before every target operation. Maintained passive capture-small is active
   (session80842). All40 deployment readbacks pass (242.466s); retained as
   olimex-deployment-001 with actual entry/MEM and manual compile/run0 proof.
   Actual sentinel/CLI/MEM pass: userLO040000..0BBFFF, stack0BF800..0BFFFF.
   Physical compile/run0 and compile1/2 pass. Remaining small cohort is active
   in session54827 (run_olimex_small.py); no new target operations alongside it.
   It runs compile2..11 then run1..9, never repeats completed case0/compile1.
   Read its local small-cohort/results.json for exact current progress.
   Extender has stopped all target access.
   Keep custody through restoration/release; consult actual local receipts.
   Use pinned new staged
   transfers, admitted keyboard/CLI and maintained passive serial/printer mirror
   per Extender. Preserve installed firmware/startup/wiring; no unmount/eject.
   Do not treat old hardware headers or an empty queue as current readiness.

Shared /tmp tmpfs filled during G2 handoff; only our inactive Cargo build cache
was moved to C006/build/relocated-cli-cache-001, preserving the active CLI at its
original /tmp path and exact hash. Evidence cli-cache-relocation-001; Extender
has since safely relocated its historical trees; /tmp has3.7GiB free.
Do not touch other owners' files.

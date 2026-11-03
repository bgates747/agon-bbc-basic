# BBC BASIC native compiler project handoff

Read `/Agon/mystuff/agon-dev-env/codex/AGENTS.md` first. That directory owns
shared environment, ownership, assembly and emulator instructions.

This working repository contains the reference BASIC V ADL interpreter and a
promoted compiler at `compiler/compiler.bas` and numeric runtime under
`compiler/runtime/`. C002 retains qualification harnesses and historical evidence.
Keep interpreter changes separate from compiler work. The active compiler
branch is `codex/native-bbc-compiler`.

Read `compiler/README.md`, `compiler/SPECIFICATION.md`,
`compiler/COMPATIBILITY.md`, `compiler/REFERENCE.md`, and the latest
`docs/compiler-development-*.md` log before changing compiler behavior. The
compiler is BBC BASIC; Python may orchestrate tests but must not implement the
compiler or substitute another numeric representation.

`TODO.md` is the only unfinished-work list. Each immutable ID maps to
`docs/tasks/<ID>.md`; experimental scripts and code belong in
`docs/tasks/<ID>/`. Read `docs/tasks/README.md` for the accepted lifecycle and
`docs/tasks/C000.md` / `docs/tasks/C001.md` for the retrospective records.
Task briefs own scope and acceptance criteria; dated logs own chronological
evidence. Passing experiments can be promoted to live source with the evidence
and destination recorded in the task document. Do not treat placement or an
automated test pass as human emulator validation or commit approval.

C001 and C002's corrected numeric baseline are promoted on the development
branch. The Author approved committing/pushing that baseline on 2026-11-01.
For supported conventional programs, execution speed is the only intended
observable behavioral difference. Preserve reference quirks, numeric conversions,
rounding and output; do not fix BBC BASIC as part of this compiler. Agreed
line-number/label syntax and clearly rejected unsupported features retain their
documented scope. Interpreter improvement ideas belong in
`compiler/INTERPRETER-FINDINGS.md`; they do not authorize compiler divergences.
The earlier exact-decimal experiment and its altered test oracles are superseded.
Read `docs/tasks/C002/LITERALS.md`, `docs/tasks/C002/OUTPUT.md`, `docs/tasks/C002/EXPRESSIONS.md`,
`docs/tasks/C002/ABI.md` and its task record for scope/results. C003 scalar
numeric bindings are promoted and the Author approved their development
checkpoint on 2026-11-01 (`4577673`, build-ignore cleanup `c9f0b5f`, complete
binary evidence `58feb04`, all pushed). The Author accepted the qualified
mutable string core checkpoint `be0f299`, also pushed. Expression slicing and
string comparisons and VAL/STR$/ASC were accepted in checkpoint `c55c951`,
committed/pushed at the Author's request. INSTR/STRING$ are now promoted for
development; selected live checks and earlier regressions pass.
Slice assignment is qualified and promoted; C003 initial scalar/string scope is complete. Read
`docs/tasks/C003/SCALARS.md`, `docs/tasks/C003/STRINGS.md`,
`docs/tasks/C003/SLICES.md`, `docs/tasks/C003/CONVERSIONS.md`,
`docs/tasks/C003/SEARCH-REPEAT.md`, `docs/tasks/C003/SLICE-STORE.md` and the task record. C004's selected conditionals, loops and scalar PROC/FN/LOCAL are complete and
promoted. FN28 programs plus five supplements, both ABI probes, baseline and
selected live/string integration pass. Source SHA6feb0b21b09ac4353347876df89043caf8800727b5a8c4f985588c3e6741c8f4; activation module783 bytes/58 relocations.
Mixed/unresolved FN kinds and interpreter-dependent direct FN carriers in omitted
RIGHT$/STRING$ are clearly rejected; see compiler/INTERPRETER-FINDINGS.md.
Read docs/tasks/C004.md, conditionals/AUDIT.md, loops/CONTROL.md,
activations/PROCEDURES.md and functions/RETURN-KINDS.md. C005 is active. Its256-definition/resource checkpoint is promoted at SHA0f0884ca, with633-byte strings and a sorted BBC symbol index. Read docs/tasks/C005.md, C005/PLAN.md, C005/RESOURCES.md and C005/ARRAYS.md. Global arrays, raw DIM and indirection are qualified/promoted at SHAd0368b1e
(1777 lines,256 shared bindings,4096 fixups). Read C005/MEMORY.md; retain the
actual DIM quirks. Full53-case scope, binding capacity5, baseline/FN and selected
live checks pass. File/input language is qualified/promoted at SHA483e1730
(1849 lines,788-byte/7-relocation I/O helper). Full29 sources, actual keyboard
INPUT LINE, same-session exit cleanup and baseline pass; read C005/IO.md for
unqualified FN carriers and255-character path boundary. DATA/READ/RESTORE is now qualified/promoted at SHA55643c54
(1962 lines,120-byte PIC helper). Full32 sources (22 native/10 rejection), verified
fresh repeat/resumed output/GNU+entry checks, baseline80.355s and live smoke170.183s
pass; seven packers reproduce it. Read C005/DATA.md for fixture corrections,
separate exhaustion oracles and explicit literal-only admissions. Resource closure remains open. Source handlers are now promoted at SHA7cac4bba
(2111 BBC lines), with2530-byte/128-relocation error runtime and licensed REPORT
table. Its original2481-byte module prefix independently rebuilds identically;
held-key polling uses MOS sysvars at handler entry. Current CORE6, modern ERL0,
actual Escape/open-file/exit checks, baseline/golden and nine regeneration tools
pass. Earlier39-case scopes retain their8bb1dd9a/44533e0d identities, including
WHILE/FN-return ERL quirks; no full39-case rerun on7cac4bba is claimed. Read
C005/ERRORS.md. The promoted7cac4bba source reaches4096-fixup exhaustion at
physical108 in1459.137s, preserving output. C005/streaming replaces the output /
fixup buffers with BBC layout, validation and direct BPUT passes. Earlier1b3e4b33
passes39/15 baseline196.992s and resource12 (six native/six rejected)3613.441s,
including70076-byte output,2048 labels and4097-label rejection. All four complete
old images remain identical. Private-name revision690fd519 passes smoke54.687s
and baseline86.029s but its actual source probe rejects Duplicate definition
count at1655:20 in371.199s, before layout. Retain those exact scopes.

Current isolated candidates are prefixed d5144921 and name-spread508a74f2
(2188 lines,208 unique definitions,248 static private names). Rename only the
new emitter helper to PROCcodecount, preserving the old slice parser PROCcount;
source preparation checks unique names per PROC/FN family. Fixed508a74f2 passes
four-image smoke57.312s, targeted count consumers6 in97.969s and baseline39/15
86.013s, with repeat/GNU/old-image equality. Its exact source probe stream-source-002 reaches458752-byte code exhaustion
at2182:67 in1322.639s (1972 symbols/208 definitions/248 bindings), preserving
output. Source body alone is390190 bytes. No executable is emitted. Read
C005/COMPACTION.md before resource reductions; actual native fit remains open. String arrays already use five-byte descriptors: a proposed
1MB fixed-slot inventory was wrong and withdrawn. Read C005/STREAMING.md.
C006 has refined generation/native-regression workflows only; no generation or
physical result exists yet. Assembly is runtime code; the compiler stays BBC BASIC.

Use `.venv/bin/python` explicitly. `compiler/README.md` contains build/test
commands. `.emulator/` is an ignored automated CLI fixture, not a graphical
human review instance. No graphical emulator or hardware has been deployed.
The Author explicitly requested pre-tranche checkpoints on 2026-11-01:
`a45a15f`, `ccd09af` before C007, `227b620` before expression integration,
`b1b708c` before numeric functions/output, and `7f45af9` before decimal literals.
All are pushed to the Author's origin. Keep this development branch and promote
to `main` only after testing is accepted; do not create a redundant `compiled`
branch. Oryx remains unavailable: never contact it until the Author says otherwise.
The Author reauthorized Pi5 automated CLI emulator work and explicitly authorized
continuing through the entire remaining TODO, skipping previous approval stops.
Complete qualification and checkpoint qualified work on this development branch
without asking again. Actual hardware/human evidence must still be reported
truthfully; an approval waiver is not a test result.
C007's completed source search and measurement contract are indexed by
`compiler/TESTING.md`; no new benchmark performance was measured. The Author's latest authorization waives earlier approval stops for remaining
work. Commit authorization is not a claim of human validation.

C005 compaction now has metadata-only compact/compiler.bas558c39a9: eight private
arrays use bounded existing byte types (19968 native element bytes saved). Smoke
54.599s retains four old images; boundary5/4-native340.239s and mixed/string
consumers2 in86.522s and baseline39/15 in86.246s pass. compact/runtime.s is a separate394-byte/29-relocation native CALL
adapter, with21-stage ABI and GNU-link proof, not yet integrated. Read compact/ABI.md
and COMPACTION.md. No native compiler image exists yet.

Compact frontend2f81c6fb is now integrated in the isolated candidate. Nine native
programs pass122.399s with fresh BBC output, repeat and independent full adapter
PIC/bridge/map checks; the first failed heap-overlap integration is frozen.
Module code must precede STR virtual heaps; map checks guard heap/arena overlap.
Baseline39/15 passes87.971s; all39 source-error cases pass in CORE6/remaining33
cohorts143.390s/549.218s with fresh ERR/ERL/output, repeat and runtime/entry links.
No self-source fit on2f81c6fb is yet measured; live compiler remains7cac4bba.

Actual2f81c6fb self-source layout completes339291 bytes/body265236,2078 symbols/
213 routines/254 bindings. Mandatory private payload112761 exceeds available86437
by26324 before string/header overhead. Deliberately stopped after layout; old
output survives and no native image exists. compact-source-001 retains disposition
and raw interrupted evidence (1366.536s). zero_tail.bas14e56cee passes nine actual
reference/native cases118.267s and all complete2f images remain identical. It
saves8192 private template bytes; actual native fit remains open. COMPACTION.md
refines private symbol widths and sparse reusable numbered-target pages next.
Latest log is docs/compiler-development-2026-11-03.md.

Current packed.bas6597a0df has2067 lines/219 unique routines, same4096-symbol and
numbered-target limits. Exact three-byte symbol addresses/two-byte sort cells
save12288 private payload bytes;64 reusable target-page pointers replace eager
bitmaps. Native exact-helper4096-cell/64-page/guard/reuse test passes262.754s,
complete standard/adapter GNU links and entry/arena checks included. Nine native
integration cases pass123.659s with all complete2f images identical; observer-only
failure is frozen. Five target cases/three native58.636s and baseline39/15
56.360s pass. The pinned text loader treats line0 as immediate mode; ordinary
reference fixtures use positive lines, compiler-zero-label syntax is separate.
New exact-source probe can report actual BBC page/string-length counts with
--private-storage; no packed-source size/fit or native compiler exists yet.

check_compiler_image.py --image PATH --output NEW_BUILD_DIR independently checks
all-feature images before native execution (standard modules/entry plus compact
PIC, seven bridge anchors and explicit pool/wrapper/placement bounds). It passes
the retained helper image and rejects three unexecuted one-byte corruptions in
image-validator-001. This is validator qualification, not a native compiler.

Packed-source-001 phase1 completes324275 bytes/body268243,2094 symbols/219
routines/254 bindings. Actual BBC observations:7 pages,13948 symbol bytes,5473
other metadata string bytes. Private bound including observed content97366 leaves
4087 of101453 before headers/scalars/overhead. Validation/output are still active;
no native fit/image is claimed from this arithmetic alone.

packed-source-001 was externally terminated with controller exit143/SIGTERM
before validation finished; no BBC diagnostic or output pass is claimed. Its
partial logs/layout/disposition are frozen with unknown termination origin.
packed-source-002 restarts the identical target and BBC driver. Host orchestration
now streams SOURCE progress and records SIGTERM; poll the running tool session
regularly. Inputs are persisted up front by the latest controller revision. No
native compiler image exists yet. Do not run another CLI against this SD while
the source probe is active.

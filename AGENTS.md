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
C005/ERRORS.md. The self-source capacity probe is running. C005/streaming holds
unqualified candidate fc67e57c (2160 lines,205 defs,248 static private names),
with a BBC three-pass emitter. Do not replace the active prototype while a
qualification uses it. Read C005/STREAMING.md. C006 has refined generation and
native-regression workflows only; no generation or physical result exists yet. The compiler is still BBC BASIC; assembly is runtime code, not a
replacement compiler implementation.

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

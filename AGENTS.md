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
Slice assignment and remaining required operations stay C003. Read
`docs/tasks/C003/SCALARS.md`, `docs/tasks/C003/STRINGS.md`,
`docs/tasks/C003/SLICES.md`, `docs/tasks/C003/CONVERSIONS.md`,
`docs/tasks/C003/SEARCH-REPEAT.md` and the task record. C004–C006 remain unstarted. The compiler is still BBC BASIC; assembly is runtime code, not a
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

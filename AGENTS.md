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

C001 was promoted after its recorded 39-case/15-execution qualification and
repeat validation at the live location. C002 is active: the adapter and numeric
VDU expressions, standard unary math functions and default numeric PRINT are
promoted; general fractional/exponent literals remain pending.
Read `docs/tasks/C002/OUTPUT.md`, `docs/tasks/C002/EXPRESSIONS.md`,
`docs/tasks/C002/ABI.md` and its task record for scope/results. C003–C006 remain
unstarted. The compiler is still BBC BASIC; assembly is runtime code, not a
replacement compiler implementation.

Use `.venv/bin/python` explicitly. `compiler/README.md` contains build/test
commands. `.emulator/` is an ignored automated CLI fixture, not a graphical
human review instance. No graphical emulator or hardware has been deployed.
The Author explicitly requested pre-tranche checkpoints on 2026-11-01:
`a45a15f`, `ccd09af` before C007, `227b620` before expression integration,
and `b1b708c` before numeric functions/output.
All are pushed to the Author's origin. Keep this development branch and promote
to `main` only after testing is accepted; do not create a redundant `compiled`
branch. Oryx is down for maintenance until the Author says otherwise: use the
Pi5's automated CLI fixture or defer emulator testing, never contact Oryx.
C007's completed source search and measurement contract are indexed by
`compiler/TESTING.md`; no new benchmark performance was measured. New work
remains uncommitted pending review and the canonical emulator validation policy.

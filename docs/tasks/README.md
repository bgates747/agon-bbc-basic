# Task records and experimental code

Every task has an immutable ID, a detailed document, and a matching directory
for substantial experiments. The root TODO is the only unfinished-work list.
This convention was established by the Author on 2026-10-31 and applied
retrospectively to the compiler work already performed.

## Record and directory contract

1. `TODO.md` contains unfinished tasks, each linked to `docs/tasks/<ID>.md`.
   IDs are never reassigned or renumbered when tasks close, split or move.
2. `docs/tasks/<ID>.md` states the objective, origin, status, dependencies,
   scope, acceptance criteria, implementation/experiment record, evidence and
   promotion disposition. Retrospective records explicitly identify work
   performed before the document existed.
3. `docs/tasks/<ID>/` holds that task's experimental source, scripts, fixtures
   and retained evidence. Create it when there are artifacts to retain;
   unstarted briefs do not need empty directories. Disposable build outputs
   belong in an ignored `build/` subdirectory. Keep selected results and
   provenance in a versionable `evidence/` subdirectory.
4. Passing experiments may be promoted into live source. Record the exact
   tested inputs, passing evidence, destination, changes made during promotion
   and resulting validation in the task document. Preserve useful experiment
   provenance; do not create competing maintained implementations.
5. Automated qualification, live promotion, human emulator validation and
   permission to commit are distinct states. The canonical emulator policy
   still governs emulator-related commits. Task recording alone does not
   perform promotion or approve a commit.
6. When accepted, rejected or superseded, retain the task document, record the
   ID/evidence/rationale in the dated development log, and remove its TODO
   entry. A later reopening retains the same ID and records why it reopened.
7. Task acceptance criteria are definitions, not a second actionable checklist.
   Future work stays in the root TODO. Specifications and the compatibility
   matrix own behavior/status; task documents link them rather than duplicate
   their full contents.
8. Shared `.venv/` and `.emulator/` remain project-local ignored infrastructure
   at the locations required by the canonical environment guide. Their setup,
   provenance and use are recorded in the owning task. Task scripts do not
   mutate upstream checkouts or other projects' profiles.

## Record index

| Immutable ID | Detailed record |
| --- | --- |
| C000 | [Project setup, task convention and retrospective accounting](C000.md) |
| C001 | [Runtime investigation and native bootstrap experiment](C001.md) |
| C002 | [Numeric runtime and expression semantics](C002.md) |
| C003 | [Scalar variables and mutable strings](C003.md) |
| C004 | [Structured flow, procedures, functions and LOCAL](C004.md) |
| C005 | [Arrays, indirection and bootstrap I/O](C005.md) |
| C006 | [Self-hosting and physical qualification](C006.md) |
| C007 | [Curated correctness and performance program search](C007.md) |
| C008 | [Manual hardware qualification and programming package](C008.md) |
| C009 | [Possible anonymous labels — low-priority candidate](C009.md) |

Open work is listed only in [TODO.md](../../TODO.md). Broad unstarted briefs
must be refined before implementation; their existence does not mean work has
begun or that a design has been accepted.

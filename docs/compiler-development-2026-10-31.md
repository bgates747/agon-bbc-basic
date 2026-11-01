# Compiler development — 2026-10-31

This session established a small BBC BASIC compiler and investigated the
reference runtime. It is an initial implementation, not a self-hosting
compiler. Work is on `codex/native-bbc-compiler`. The Author subsequently
established immutable task documents and experimental silos; the retrospective
records are [C000](tasks/C000.md) and [C001](tasks/C001.md). No implementation
has been promoted to live source.

## Initial scope and decisions

1. Inspected the existing BASIC V ADL interpreter before choosing a backend;
   cloned the pinned Dean Belfield ADL reference into temporary storage and
   recorded its calling conventions and dependencies in
   [the investigation](../compiler/REFERENCE.md).
2. Read all eleven canonical `agon-dev-env/codex` files after the Author
   supplied their location. The shortened `mystuff/codex` path does not exist.
   Created the project `.venv` with the Author's explicit approval; installed
   interpreter reports Python 3.14.8.
3. Started the compiler under `compiler/` without changing the reference
   interpreter source. Direct binary emission avoids a target assembler
   dependency. Runtime code in this stage is new and small; numeric/string
   interpreter routines have not been extracted.
4. Created the dedicated branch at the Author's request, carrying the current
   uncommitted compiler files onto it. No commits, pushes or deployment to
   hardware or human review hosts occurred.
5. Added a provisional single TODO with stable C001–C006 IDs. The authoritative
   task structure still needs agreement. No later implementation stage is
   started by this milestone.

## Validation work

1. Built the unmodified reference interpreter with installed ARM64 AgonDev
   GNU tools. Existing upstream `ez80asm` and Fab CLI executables on this host
   were x86-64; built the unchanged official Fab 1.2.5 CLI source into
   `/tmp/bbc-compiler-cli-target` using Cargo's locked offline dependency set.
2. Generated a project-local automated CLI profile through the canonical setup
   helper. MOS v3.0.2 Arthur image and map matched its pinned hashes. Kept the
   generated wrapper; selected the rebuilt text-only CLI backend. The CLI
   warns about the wrapper's unused firmware-family option and its minimal
   fake VDP reports unsupported startup packets. This does not constitute
   graphical or physical qualification.
3. Exercising the real compiler exposed parser errors around colon-separated
   statements, nested single-line conditionals, and an early FN exit with a
   live FOR frame. Reworked those paths to finish structured loops before
   returning. Empty literals and repeated compilations are regression cases.
4. C001 bootstrap implementation and automated qualification completed:
   **39 compiler cases and 15 native executions passed**, including exact
   output and MOS status checks, 24 compilation-error/output-preservation
   cases, deterministic repeated compilation and an independently assembled
   complete executable oracle. The successful run took **13.043 seconds** for
   compilation, oracle assembly and native execution; setup/build time is
   excluded. Unlimited-speed CLI execution is not hardware timing. The report
   was originally in ignored `compiler/build/test-results.json`; the report
   and logs are now retained in
   [C001 qualification-001](tasks/C001/evidence/qualification-001/results.json).
   Removed C001 from the unfinished list; this records technical evidence,
   not human emulator acceptance or approval to commit.
5. Qualified inputs: compiler SHA-256
   `170aa81fae100127aaf8de4411c621de43b256fa62dcbedc00a7da0c73c2ddef`,
   reference interpreter SHA-256
   `a1ae6d381d9861abbc5d87550c683827499d5a8cbe1de49fd9dfa3687382653d`,
   ARM64 CLI SHA-256
   `bf5f29b243b8214e54c515dcc26edf47399ce440356af2ebc3ce3d7664ae11eb`.
   The MOS image SHA-256 is
   `d564243283972690933a4554296ad6202ca4ef54572279533a942960846bebae`.
6. An initial native script stopped when a runtime error correctly returned
   status 1. The final harness uses MOS `Try` and checks `Try$ReturnCode` for
   every native execution, proving both error and success paths return to MOS.
   The independent assembly oracle initially miscounted one error-message
   length; correcting that fixture produced byte-for-byte equality without a
   compiler change.

## Initial stopping point and proposed structure (subsequently superseded)

1. `TODO.md` owns unfinished tasks and stable IDs; each future implementation
   task should state its scope, dependencies and observable acceptance test.
2. `compiler/SPECIFICATION.md` owns behavior, `COMPATIBILITY.md` owns feature
   status and `REFERENCE.md` owns verified external facts. A task brief can
   link these rather than duplicate them.
3. Dated logs own evidence and the rationale for closing or replacing task
   IDs. `AGENTS.md` owns concise session startup and current-state pointers.
4. C000 is the next discussion: agree this arrangement and split the broad
   provisional C002–C006 stages into implementation-sized tasks before more
   code. All changes remain uncommitted on `codex/native-bbc-compiler`.

The compatibility matrix records the incomplete language. General numbers,
mutable strings, PROC/FN/LOCAL and self-hosting remain unfinished; graphical
review, physical execution and performance measurement remain unqualified.

## Retrospective task records and experimental relocation

1. The Author established the convention `docs/tasks/<ID>.md` for detailed
   records and `docs/tasks/<ID>/` for experimental code/scripts, with tested
   promotion into the live tree recorded separately. The later request to
   "retcon" all work authorised creation of the retrospective records and
   relocation of the existing experiment.
2. **C000 completed:** recorded environment/branch/documentation work,
   established [the task-record contract](tasks/README.md), and mapped every
   existing TODO ID to a detailed task document. Removed C000 from the TODO;
   [its record](tasks/C000.md) retains the origin and closure rationale.
3. **C001 reopened for promotion disposition:** the experiment had met its
   automated technical criteria, but its placement under `compiler/` did not
   establish live promotion. The matching task now records research, code,
   failed attempts, corrections, successful tests and remaining limits. Added
   its unfinished promotion disposition back to the TODO using the same ID.
4. Moved `compiler/compiler.bas`, `compiler/examples/`, `compiler/tests/`,
   `compiler/tools/` and disposable `compiler/build/` into `docs/tasks/C001/`.
   Only harness path resolution changed. Compiler/sample/oracle hashes were
   preserved; [the relocation manifest](tasks/C001/evidence/relocation.json)
   records prior paths and identities. Project `compiler/` documents remain
   the specification, compatibility matrix, reference audit and runbook.
5. Copied the original successful report/logs and available early-attempt logs
   from ignored storage into C001's versionable evidence directory. Reran the
   relocated harness: **39 compiler cases and 15 native executions passed**
   again in **13.155 seconds**, with unchanged qualified input hashes. Retained
   the result and logs separately as
   [qualification-002](tasks/C001/evidence/qualification-002/results.json).
   Shared `.venv/` and `.emulator/` remain in their canonical project locations.
6. C002–C006 now have detailed draft briefs with scope, dependencies and
   acceptance criteria, all explicitly marked unstarted. No future-stage
   implementation or live promotion was performed during this accounting work.
   Changes remain uncommitted and unpushed on the dedicated branch.

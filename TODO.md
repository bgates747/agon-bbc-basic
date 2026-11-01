# Compiler work

This is the single list of unfinished work. Immutable task IDs link to detailed
records under `docs/tasks`; experimental code belongs in the matching task
directory. See [the task convention](docs/tasks/README.md). Feature status is in
`compiler/COMPATIBILITY.md`. C000 is complete and retained in its task document
and the dated log. C002–C006 remain broad, unstarted scopes.

1. [ ] [C001](docs/tasks/C001.md) — Resolve live promotion of the tested bootstrap;
   preserve its qualification evidence and record the selected live destination.
2. [ ] [C002](docs/tasks/C002.md) — Specify and adapt the numeric runtime: exact four-byte integers,
   five-byte floats, conversions, mixed arithmetic, comparisons and overflow;
   qualify against the reference interpreter before enabling expressions.
3. [ ] [C003](docs/tasks/C003.md) — Add scalar variables and mutable strings with defined ownership,
   allocation limits, assignment and BBC BASIC naming/type conventions.
4. [ ] [C004](docs/tasks/C004.md) — Add structured control flow and separate PROC/FN activation
   records, arguments, recursion, and LOCAL save/restore, including strings.
5. [ ] [C005](docs/tasks/C005.md) — Add arrays, byte/word indirection, binary/text file operations,
   and the remaining facilities used by the compiler source.
6. [ ] [C006](docs/tasks/C006.md) — Compile the compiler with itself, run that binary to compile it
   again, compare deterministic output, and qualify on physical Agon hardware.

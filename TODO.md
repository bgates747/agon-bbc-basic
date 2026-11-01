# Compiler work

This is the single list of unfinished work. Immutable task IDs link to detailed
records under `docs/tasks`; experimental code belongs in the matching task
directory. See [the task convention](docs/tasks/README.md). Feature status is in
`compiler/COMPATIBILITY.md`. C000 and C001 are complete and retained in their
task documents and dated logs. C002 is active; C003–C006 are unstarted scopes.

1. [ ] [C007](docs/tasks/C007.md) — Search and curate correctness/performance
   programs covering interpreter-heavy control flow, calls, variables, strings,
   parsing and I/O, with arithmetic controls and a fair measurement protocol.
2. [ ] [C002](docs/tasks/C002.md) — Integrate the qualified experimental numeric
   adapter: implement compiler literals/expressions, emission and runtime
   relocation. Preserve four-byte integers, five-byte floats, conversions,
   comparisons and overflow; resolve the recorded constant-reader discrepancy
   explicitly before promoting numeric language support.
3. [ ] [C003](docs/tasks/C003.md) — Add scalar variables and mutable strings with defined ownership,
   allocation limits, assignment and BBC BASIC naming/type conventions.
4. [ ] [C004](docs/tasks/C004.md) — Add structured control flow and separate PROC/FN activation
   records, arguments, recursion, and LOCAL save/restore, including strings.
5. [ ] [C005](docs/tasks/C005.md) — Add arrays, byte/word indirection, binary/text file operations,
   and the remaining facilities used by the compiler source.
6. [ ] [C006](docs/tasks/C006.md) — Compile the compiler with itself, run that binary to compile it
   again, compare deterministic output, and qualify on physical Agon hardware.

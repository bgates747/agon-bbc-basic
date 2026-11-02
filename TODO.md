# Compiler work

This is the single list of unfinished work. Immutable task IDs link to detailed
records under `docs/tasks`; experimental code belongs in the matching task
directory. See [the task convention](docs/tasks/README.md). Feature status is in
`compiler/COMPATIBILITY.md`. C000–C002's qualified initial scopes are complete
and retained in their task documents and dated logs. C007's corpus search is
complete and retained alongside them. C003–C006 are unstarted scopes.

1. [ ] [C003](docs/tasks/C003.md) — Add scalar variables and mutable strings with defined ownership,
   allocation limits, assignment and BBC BASIC naming/type conventions.
2. [ ] [C004](docs/tasks/C004.md) — Add structured control flow and separate PROC/FN activation
   records, arguments, recursion, and LOCAL save/restore, including strings.
3. [ ] [C005](docs/tasks/C005.md) — Add arrays, byte/word indirection, binary/text file operations,
   and the remaining facilities used by the compiler source.
4. [ ] [C006](docs/tasks/C006.md) — Compile the compiler with itself, run that binary to compile it
   again, compare deterministic output, and qualify on physical Agon hardware.

# Compiler work

This is the single list of unfinished work. Immutable task IDs link to detailed
records under `docs/tasks`; experiments belong in the matching task directory.
See [the task convention](docs/tasks/README.md). C000–C003 and C007 retain
completed initial scopes and evidence in their task records and dated logs.
Feature status is in `compiler/COMPATIBILITY.md`.

1. [ ] [C004](docs/tasks/C004.md) — Add structured control flow and separate PROC/FN activation
   records, arguments, recursion, and LOCAL save/restore, including strings.
2. [ ] [C005](docs/tasks/C005.md) — Add arrays, byte/word indirection, binary/text file operations,
   and the remaining facilities used by the compiler source.
3. [ ] [C006](docs/tasks/C006.md) — Compile the compiler with itself, run that binary to compile it
   again, compare deterministic output, and qualify on physical Agon hardware.

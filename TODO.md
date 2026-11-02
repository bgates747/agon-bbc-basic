# Compiler work

This is the single list of unfinished work. Immutable task IDs link to detailed
records under `docs/tasks`; experimental code belongs in the matching task
directory. See [the task convention](docs/tasks/README.md). Feature status is in
`compiler/COMPATIBILITY.md`. C000–C002's qualified initial scopes are complete
and retained in their task documents and dated logs. C007's corpus search is
complete and retained alongside them. C003 scalar numeric bindings are
promoted alongside the mutable string core, expression slices and string
comparisons and VAL/STR$/ASC; further string operations remain unfinished.
C004–C006 are unstarted scopes.

1. [ ] [C003](docs/tasks/C003.md) — Complete remaining string functions (INSTR/STRING$ and other required
   functions) and slice assignment with reference behavior; retain qualified numeric bindings,
   owned strings, expression slices and comparisons.
2. [ ] [C004](docs/tasks/C004.md) — Add structured control flow and separate PROC/FN activation
   records, arguments, recursion, and LOCAL save/restore, including strings.
3. [ ] [C005](docs/tasks/C005.md) — Add arrays, byte/word indirection, binary/text file operations,
   and the remaining facilities used by the compiler source.
4. [ ] [C006](docs/tasks/C006.md) — Compile the compiler with itself, run that binary to compile it
   again, compare deterministic output, and qualify on physical Agon hardware.

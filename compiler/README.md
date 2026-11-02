# Native BBC BASIC compiler — development

This is the first small implementation of the self-hosting compiler project.
The compiler is BBC BASIC and emits native eZ80 ADL code directly. It currently
compiles literal/numeric output, labelled control flow, numeric byte VDU
expressions, standard math functions, scalar numeric variables and a mutable
string core with expression/assignment slicing, comparisons, VAL/STR$/ASC and INSTR/STRING$. It cannot compile itself.
The interpreter elsewhere in this repository remains the compatibility
reference and bootstrap host. The tested implementation was promoted under
[task C001](../docs/tasks/C001.md) to `compiler/compiler.bas`; sample programs,
regression tests and tooling are alongside it. C002's numeric expressions, output,
fractional/scientific literals and runtime
are in this development tree, with the corrected C002 baseline accepted for
a development checkpoint. C003 numeric bindings and the mutable string core
and conversions are promoted; further string functions remain unfinished. Promotion to `main` awaits accepted testing.

## Running on Agon

From `compiler/` on the Agon SD card, load `compiler.bas` into the
repository's BASIC V ADL interpreter and `RUN`.
Enter the plain-text input filename and destination `.bin` filename at its
prompts. For example, compile `examples/hello.bas` into `hello.bin`. Exit BASIC
with `*BYE`, then run `hello.bin` from MOS. Loading the generated program
replaces the interpreter at `&40000`; reload BASIC for another compilation.

`compiler.bas` has line numbers so that the existing interpreter can load it
without a preprocessor. Programs being compiled may omit line numbers. The
compiler performs source parsing, symbol resolution, relocation, runtime
emission and binary output itself; the Python harness only runs tests. The
numeric and string runtime templates are already embedded as DATA, so the Agon compiler
needs no separate runtime image or assembler.

## Current documents

1. [Language and implementation](SPECIFICATION.md) — current behavior and
   proposed boundaries for later stages.
2. [Compatibility matrix](COMPATIBILITY.md) — implemented and missing features.
3. [Runtime investigation](REFERENCE.md) — inspected upstream sources,
   register conventions, dependencies and licensing.
4. [Tasks](../TODO.md) — the single unfinished-work list, linked to detailed
   immutable-ID documents in `docs/tasks/`.
5. [Development log](../docs/compiler-development-2026-11-01.md) — experiments
   and verification evidence.
6. [Testing and benchmarking corpus](TESTING.md) — curated source programs,
   eligibility, correctness oracles and measurement protocol.
7. [Possible interpreter improvements](INTERPRETER-FINDINGS.md) — research
   observations and reproductions, separate from compiler compatibility.

## Automated qualification

Use the project `.venv`; it needs no third-party Python packages. Build the
reference interpreter using the installed AgonDev tools, for example:

```bash
make ASM=/Agon/agondev/release/bin/ez80-none-elf-as \
  LINKER=/Agon/agondev/release/bin/ez80-none-elf-ld
```

The test runner needs a host-native `agon-cli-emulator`, from the official Fab
source. The retained upstream executable on this machine is x86-64; the host
is ARM64. Build its unchanged CLI backend into an isolated output directory:

```bash
cargo build --release --locked --offline \
  --manifest-path /Agon/fab-agon-emulator/Cargo.toml \
  -p agon-cli-emulator --target-dir compiler/build/cli
.venv/bin/python compiler/tools/test_compiler.py \
  --cli compiler/build/cli/release/agon-cli-emulator
```

The harness imports the canonical `agon-dev-env` profile generator, verifies
the MOS image/map and uses the generated profile-local launcher. The ignored
`.emulator` profile uses the CLI backend for automated text tests; its parser
warns about the wrapper's unused `--firmware platform` argument. This profile
does not provide a graphical human review fixture. It maps only individual
files and standard utilities, never the containing project directory.

The tests run the actual BBC BASIC compiler, compare one complete executable
against independently assembled GNU eZ80 source, run generated executables,
exercise compilation failures and check that old output survives them. Logs
remain in `.emulator`; successful results and input hashes are written to
`compiler/build/test-results.json`. Retained qualification reports and
logs are in `docs/tasks/C001/evidence/`. These checks do not qualify physical
hardware or prove self-hosting.

For numeric integration and assembly-template regeneration, see the
[runtime runbook](runtime/README.md) and [C002 expression record](../docs/tasks/C002/EXPRESSIONS.md).
The [numeric output record](../docs/tasks/C002/OUTPUT.md) describes math functions,
default PRINT formatting and qualification. [numbers.bas](examples/numbers.bas)
provides a small executable example.

[Decimal literal compatibility](../docs/tasks/C002/LITERALS.md) records the
reference conversion dependency, source grammar and differential qualification.
Execution speed is the only intended observable runtime difference for supported
conventional BBC programs. Possible [interpreter improvements](INTERPRETER-FINDINGS.md)
are retained separately as research; the compiler must not silently adopt them.

[Scalar numeric bindings](../docs/tasks/C003/SCALARS.md) documents plain/LET
assignment, numeric suffixes, physical storage and reference existence rules.
[variables.bas](examples/variables.bas) demonstrates them. C003-owned transcript
and memory probes qualify the single live compiler.

[Mutable string core](../docs/tasks/C003/STRINGS.md) documents `$` assignment,
independent copying, concatenation, LEN/CHR$, five-byte descriptors and the
bounded private heap. [strings.bas](examples/strings.bas) demonstrates it.
[String slices and comparisons](../docs/tasks/C003/SLICES.md) adds LEFT$/RIGHT$/MID$
expressions and six relations returning ordinary -1/0 Booleans. The reference
low-byte index/count behavior is preserved. Array/indirect targets, LOCAL and I/O-dependent string facilities remain
within C004/C005.

[String conversions](../docs/tasks/C003/CONVERSIONS.md) adds VAL, G9/hex STR$ and
ASC with reference types, text and errors. [conversions.bas](examples/conversions.bas)
is the qualified mixed example. Raw source control bytes inside quotes are
rejected; construct such string data with CHR$.

[String search and repetition](../docs/tasks/C003/SEARCH-REPEAT.md) adds INSTR
and STRING$, preserving empty searches, low-byte arguments and error order.
[search-repeat.bas](examples/search-repeat.bas) is the qualified mixed example.

The INSTR/STRING$ prototype, selected live checks and existing regressions pass
on the Pi5 CLI under the Author's renewed authorization.
The Author authorized completing the remaining TODO without prior approval
stops. See C003 for the exact qualification scope and evidence.

[Slice assignment](../docs/tasks/C003/SLICE-STORE.md) updates existing scalar
string contents with reference range rules. [slice-store.bas](examples/slice-store.bas)
is the qualified mixed example; length and allocation stay unchanged.

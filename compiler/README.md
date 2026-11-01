# Native BBC BASIC compiler — bootstrap

This is the first small implementation of the self-hosting compiler project.
The compiler is BBC BASIC and emits native eZ80 ADL code directly. It currently
compiles literal output and labelled control flow; it cannot compile itself.
The interpreter elsewhere in this repository remains the compatibility
reference and bootstrap host. The tested implementation was promoted under
[task C001](../docs/tasks/C001.md) to `compiler/compiler.bas`; sample programs,
regression tests and tooling are alongside it. The numeric runtime experiment
remains siloed under [C002](../docs/tasks/C002.md) and is not yet emitted by the
compiler.

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
emission and binary output itself; the Python harness only runs tests.

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

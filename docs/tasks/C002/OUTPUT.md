# Numeric functions and output

The compiler now prints numeric expressions in BBC's default format and accepts
the standard unary math functions and PI. Qualification compares both packed
arithmetic results and exact printed output with the actual interpreter. General
fractional/exponent source literals and variables remain unsupported; this is a
qualified C002 slice, not completion of the whole numeric task or self-hosting.

This record describes the output tranche at its qualification checkpoint.
The subsequent [decimal literal tranche](LITERALS.md) supersedes its fractional/
exponent source exclusions and records the current compiler source identity.

Current compatibility qualification uses identical conventional source in BASIC
and the compiler, including the formerly substituted 2^32 literals. Numeric error
text comes from the interpreter's actual REPORT$ behavior, not comments in the
arithmetic package. [LITERALS.md](LITERALS.md) records the subsequent correction;
earlier counts/source identities below remain historical.

## Source behavior

1. PRINT accepts numeric expressions alongside literal strings in a semicolon
   list. It uses G9 (nine significant figures) with an initial minimum numeric
   field width of ten characters. A semicolon removes numeric padding for
   subsequent items; a trailing semicolon suppresses newline. Each new PRINT
   starts with the default field width. Leading/repeated semicolons are supported.
2. Comma zones, TAB/SPC, `PRINT ~`, @% assignment and source-level STR$/VAL remain
   unsupported. Runtime formatting is a private compiler service, not a claim
   of mutable-string support. The original literal-string behaviors remain.
3. Built-ins are ABS, ACS, ASN, ATN, COS, DEG, EXP, INT, LN, LOG, NOT, RAD, SGN,
   SIN, SQR, TAN and PI. Functions consume one item, including a parenthesised
   expression: `SQR16+9` is 13; `SQR(16+9)` is 5. Digits can follow function
   names without whitespace. Alphabetic operands require a separator or
   parentheses; general crunched-keyword compatibility is not claimed.
4. Binary/unary arithmetic, 32-bit integer payloads, 40-bit float records and
   numeric error behavior are preserved. INT floors while SFIX truncates.
   The tested reference's ABS(INT_MIN) wraps to INT_MIN. General decimal
   parsing retains the earlier clear exclusions; no host IEEE format is used.
5. [numbers.bas](../../../compiler/examples/numbers.bas) is a small native
   demonstration with arithmetic, SQR, PI, INT and a fractional quotient.
   It needs the BASIC compiler to build it; its emitted executable runs alone
   under MOS, with no interpreter or external numeric library installed.

## Runtime boundary

1. The expanded numeric adapter accepts binary selectors 0..15, unary 16..31,
   PI 35 and conversions 38/39. Internal constants and pointer-based VAL/STR
   selectors remain rejected there. No vendor math source was changed.
2. The separate formatter supplies STR's actual format/output pointers, uses
   private G9 control and preserves its input/index pointers/native stack. It
   returns a full pointer-difference length and explicitly terminates output;
   it does not inherit the interpreter's page-aligned accumulator assumption.
   The [ABI](ABI.md) owns exact register/buffer contracts.
3. Numeric PRINT reuses 32 bytes of private display scratch. Combined runtime
   size is 4028 bytes with 380 local 24-bit relocations, before value slots and
   existing numeric-error glue. BBC BASIC performs final relocation and binary
   emission. Literal-only programs still omit the numeric template and retain
   the original complete assembly golden.

## Qualification and reproduction

1. [Initial evidence](evidence/output-001/summary.json) records 449 packed
   arithmetic/ABI cases, 45 formatter cases and 22 integration programs (14
   native executions, eight rejections). Integration includes 58 earlier
   arithmetic observations bundled into five programs, exact PRINT transcripts,
   independent emitted-runtime links, native errors and repeat determinism.
   The original compiler regression suite passed 39 cases/15 native executions;
   24 additional legacy cases passed, including 17 syntax rejections and
   numeric error exit inside GOSUB.
2. Formatter qualification covers exact valid packed minimum/maximum floats,
   integer boundaries, small/large exponents, NUL termination, buffer guards,
   unchanged input, pointer/SP preservation and a buffer crossing a 256-byte
   page. Python only prepares/builds/compares fixtures; actual BASIC supplies
   arithmetic/string oracles. No numerical or formatting model runs in Python.
3. A reporting-only path bug was fixed by resolving explicit compiler/runtime
   arguments before deriving repository-relative hash keys. The affected legacy
   batches were rerun successfully. This changed no target arithmetic behavior.
4. The exact qualified BBC source was promoted from C002/output to the single
   maintained `compiler/compiler.bas`; its SHA-256 is
   `fa57cc43b08ee279e42fef3fbe78e549a9c6ecbfcf4eea65778e49788643aa41`.
   Updated adapter/helpers and DATA packer moved with it. Frozen evidence
   sources are historical snapshots. The probe/harnesses stay under C002.
5. [Live-location rechecks](evidence/output-promotion-001/summary.json) passed
   449 numeric cases (17.447 seconds), 45 formatter cases (2.036 seconds), the
   39-case/15-execution baseline (22.534 seconds), and 18 output programs with
   `--skip-legacy` (10 native/eight rejections, 62.599 seconds). This last run
   includes the new numbers demonstration. Runtime DATA regeneration preserved
   the qualified compiler bytes. New work remains uncommitted for Author
   review; the earlier checkpoint is pushed and main is unchanged.
6. Final harness cleanup removed redundant identical assembly include paths
   and required the full explicit EVAL diagnostic in the baseline suite.
   Runtime regeneration remained byte-identical; the 39-case baseline passed
   again in 22.532 seconds and all 449 numeric cases in 17.549 seconds.
   Their reports and final qualification-tool hashes are in promotion evidence.

From the project root, using the Pi5's existing canonical automated CLI fixture:

```bash
.venv/bin/python compiler/tools/build_numeric_runtime.py --update-compiler
.venv/bin/python compiler/tools/test_compiler.py \
  --cli /tmp/bbc-compiler-cli-target/release/agon-cli-emulator
.venv/bin/python docs/tasks/C002/tools/test_numeric.py \
  --cli /tmp/bbc-compiler-cli-target/release/agon-cli-emulator
.venv/bin/python docs/tasks/C002/tools/test_format.py \
  --cli /tmp/bbc-compiler-cli-target/release/agon-cli-emulator
.venv/bin/python docs/tasks/C002/tools/test_output.py \
  --cli /tmp/bbc-compiler-cli-target/release/agon-cli-emulator
```

Run sequentially: these tools share the profile. Output integration takes about
two minutes for the original 22-program suite on this host; this is a retained
qualification duration, not a timeout estimate or physical Agon benchmark.
`--skip-legacy` selects the newer output cases plus the demonstration for a
shorter post-promotion check. Oryx was not contacted; no graphical review or
physical hardware measurement took place. Main acceptance remains separate.

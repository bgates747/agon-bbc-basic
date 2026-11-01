# Native numeric expression integration

The compiler emits native arithmetic and byte VDU expressions against
the qualified BBC numeric package. Arithmetic runs in generated executables,
without a resident interpreter. The 84-case experiment passed and its exact
source was promoted to the development tree on 2026-11-01. Main acceptance,
human review and physical hardware testing remain separate.

## Supported slice

1. Use `compiler/compiler.bas` in the project root as the complete numbered BBC
   BASIC source. Its generated DATA section contains the runtime template and
   relocation offsets. The compiler is BBC BASIC; the assembly runtime packer
   does not parse BASIC programs or generate their expression code.
2. VDU accepts comma-separated numeric expressions. Each result uses SFIX
   conversion and emits its low byte, matching the inspected interpreter's
   byte VDU path. Negative/out-of-byte-range values are accepted when the
   conversion fits a signed integer. Overflow during conversion is a runtime
   error. Word/zero-fill VDU delimiters remain unsupported.
3. Expressions support parentheses, unary `+`, `-`, `NOT`, TRUE/FALSE, and
   binary `+ - * / ^ DIV MOD AND EOR OR = <> <= >= < >`. No short-circuit
   semantics are introduced. Variables, function calls, shifts, numeric PRINT,
   fractional decimal literals and exponent literals are excluded from this
   tranche and diagnosed. EVAL remains deliberately unsupported.
4. Precedence from tightest to loosest is item/unary, power, multiply/divide/
   DIV/MOD, add/subtract, comparison, AND, EOR/OR. Power is left-associated:
   `2^3^2` is 64 and `-2^2` is 4. These follow the inspected BASIC V evaluator,
   rather than common assumptions about mathematical notation. One comparison
   is accepted per unparenthesised expression level.
5. Decimal whole literals have at most ten digits (including leading zeros)
   and range from 0 through 2^32 inclusive. An optional
   decimal point must be followed by one or more zero digits; it forces the
   package's floating conversion. Fractional results from division and other
   arithmetic still use the full five-byte BBC representation. Hex literals
   contain one to eight uppercase digits and denote signed 32-bit bit patterns.
6. Decimal digits accumulate using BBC arithmetic, without VAL or another
   numeric format. All intermediates through the chosen whole-literal bound
   are exact in the 32-significant-bit representation. Values beyond signed
   integer range naturally promote. Hex values are packed bytewise as integer
   bit patterns, avoiding an out-of-range floating-to-integer conversion at
   the signed boundary. The previous
   2^32 reader discrepancy is intentionally corrected, for both whole and
   `.0` forms; it is not an interpreter compatibility promise.

## Generated runtime and storage

1. The existing packed pointer ABI is unchanged. The template adds an inline
   five-byte literal copier and a bytewise unary-minus helper. Integer unary
   minus preserves the integer representation, including INT_MIN wrap; float
   minus changes the sign bit. Binary subtraction from zero would not provide
   the same integer overflow behavior.
2. The BBC parser emits loads, calls and absolute fixups. Each intermediate
   occupies a five-byte static slot. Binary operations consume two slots and
   leave the result in the left slot. Completed VDU arguments release all
   slots; separate statements reuse them. The compiler allocates only the
   maximum required number, with a limit of 32. Recursive parser entries are
   separately bounded at 32, including both item and expression entries.
3. This temporary storage model is safe for the currently admitted expressions,
   which cannot call user code. It does not settle a future recursive FN/PROC
   expression stack. Do not reuse live intermediates across user calls without
   defining the later activation/value-stack contract.
4. The whole numeric template is included once when any numeric VDU is used.
   Literal-only PRINT/labels retain the old complete image, including its
   independent assembly golden. There is no pruning of unused package entries.
5. At runtime numeric errors branch to messages for codes 18 and 20–24, or a
   generic numeric error. They return status 1 through the existing MOS exit
   path, restoring the saved stack even inside GOSUB. Compilation failures
   preserve existing destination files, as before.
6. Runtime packaging assembles unchanged `numeric.s`/vendor source plus the
   helper file. All relocations must be three-byte local absolute relocations;
   unsupported kinds and unresolved symbols fail the build. The packer checks
   relocation against independent GNU links at &41000 and &47000. BBC BASIC
   performs actual image copying/relocation, not Python. The resulting compiler
   needs no assembler, template file or reference interpreter at generated
   program execution time.

## Reproduction and evidence

From the project root on the Pi5, using the existing canonical CLI fixture:

```bash
.venv/bin/python compiler/tools/build_numeric_runtime.py --update-compiler
.venv/bin/python compiler/tools/test_compiler.py \
  --cli /tmp/bbc-compiler-cli-target/release/agon-cli-emulator
.venv/bin/python docs/tasks/C002/tools/test_expressions.py \
  --cli /tmp/bbc-compiler-cli-target/release/agon-cli-emulator --start 0 --count 12
```

The first command packages assembly and updates only the generated DATA suffix
in the complete compiler. Runtime sources and notices are in `compiler/runtime/`;
the builder resolves them there. Template packaging is a
host build step; the complete compiler source includes its result.

The integration harness creates BASIC reference bytes, runs the actual BBC
compiler and executes its standalone outputs. Independently stated predicates
cover precedence, full-width signed values, promotion, fractions and precision;
the interpreter independently evaluates them. Two 2^32 literal cases use exact
arithmetic construction in the reference because the original reader is known
to disagree. These deliberate source differences remain explicit in case data.
Repeat the final command with starts 12, 24, 36, 48, 60 and 72 to cover all
bounded batches; the final batch stops at the end of the case list.

Compile batches are materially larger than the old literal-only fixtures.
The runner accepts an explicit longer batch timeout, rather than assuming the
old 45-second budget is an execution estimate. Source hashes, cases, raw logs,
oracle bytes, runtime metadata and qualification durations belong in the task's
evidence; disposable integration products stay under C002 `build/expressions/`
and assembly packaging under `compiler/build/numeric-runtime/`. Automated
Pi5 qualification is separate from human review and physical Agon testing.

The original [qualification summary](evidence/expressions-001/summary.json)
records 84 cases, 67 native executions, 17 rejections, 58 BASIC reference
expressions and 66 independently linked emitted runtime images. The seven
bounded batches total 330.787 seconds, excluding profile provisioning; this
is host qualification duration, not physical Agon performance. The frozen
compiler snapshot is evidence, not a second maintained implementation. The
promoted compiler has the same SHA-256, `4095e9e61e953a84b2f257717a6642f4609df49a57a15bee5ffd0d84de8f03d2`.

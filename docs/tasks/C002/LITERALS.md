# Reference-compatible decimal literals

The compiler must preserve the reference interpreter's numeric results, types,
errors and output, including reader quirks. Execution speed is the only intended
observable runtime difference for supported conventional programs. The earlier
exact-decimal experiment is superseded as compiler semantics and retained only
as research for possible separately approved interpreter improvements.

## Conversion and dependencies

1. The BBC BASIC compiler scans a decimal atom, passes its original text to
   bootstrap BASIC's VAL, and copies the returned five-byte record into native
   literal data. The reference's EVAL.Z80 source-number entry and string VAL
   both select numeric package operation 36, which calls CON/NUMBER. For these
   unsigned atoms, VAL's initial SIGNQ has no effect. Unary signs remain native
   expression operations. No host IEEE or Python conversion is involved.
2. The dependency is the pinned reference BASIC V ADL bootstrap interpreter,
   not a runtime dependency of generated applications. The compiler does not
   call an undocumented fixed interpreter address. Generated executables carry
   packed constants and the standalone numeric runtime; they need no BASIC
   binary installed to execute. A future native compiler must implement source
   VAL's string-pointer interface as part of bootstrap closure; this work does
   not claim self-hosting or general source VAL support yet.
3. Reference CON truncation, decimal scaling, integer/float decisions,
   underflow and exponent-counter behavior are preserved. In particular,
   `4294967296` and `4294967296.0` produce `FAFFFF7F9F`, rather than the exact
   power-of-two record `00000000A0`. More mathematically accurate results do
   not qualify as compiler fixes.
4. Reader errors are captured while compiling and emitted as native errors at
   the atom's execution point. An unreachable `1E39` must not cause an error;
   evaluating it does. Emission uses the existing saved-stack error exit.
   Numeric messages follow MAIN.Z80's message table and actual REPORT$,
   rather than comments in MATH.Z80: `Number too big`, `-ve root`,
   `Log range`, `Accuracy lost`, `Exponent range`, `Division by zero`.
5. The 4028-byte/380-relocation arithmetic template and vendor source/license
   remain unchanged. Only the BBC compiler's parser, constant emission and
   emitted error text change. The compiler remains written in BBC BASIC.

## Source boundary

1. Decimal atoms contain digits and an optional point, including leading or
   trailing points. The reference also accepts a point alone as zero. An
   uppercase E consumes spaces before an optional sign and then any digits;
   missing exponent digits retain the reader's zero-exponent behavior.
   Thus `1E+` is 1 and `1E 3` is 1000. Space after the sign is not swallowed.
2. EOR remains an operator boundary (`1EOR2`). No lowercase-e extension or
   independent exponent-value limit is introduced. The reference's counter
   behavior remains visible: for example `1E000003` and `0E999` raise
   `Number too big`, while `1E-999` becomes zero.
3. Unspaced alphabetic text following a scientific exponent is rejected as an
   unsupported tokenisation form; general keyword crunching is not claimed.
   Lowercase e, which can introduce a variable in interpreted source, is
   rejected along with other unsupported variable syntax. No valid result
   from an invented lowercase exponent grammar is emitted.
4. Existing 255-byte physical source lines, eight-digit uppercase hex limits,
   unsupported binary literals, variables and source EVAL/VAL/STR$ remain
   explicit in the compatibility matrix. Hex bit patterns and unary minus
   preserve their prior qualified behavior.

## Qualification contract

1. `tools/test_literals.py` executes the same literal spelling in direct
   reference BASIC assignment. It records the five-byte value or error and
   the actual formatted value or REPORT$ text. It separately checks VAL's
   bytes for successful readings, auditing the bootstrap conversion choice.
2. The compiler's inline payload must match that direct-source value byte for
   byte. Native output must match the reference transcript, including errors.
   Independent GNU links check runtime relocation. Rejected syntax preserves
   an existing output, and repeat compilation checks determinism.
3. Historical exact binary/midpoint anchors and arithmetic expressions remain
   research metadata only. They never override direct-source expectations.
   In particular, the earlier two 2^32 arithmetic-substitution oracles have
   been removed from expression and bundled PRINT qualification.
4. Generated stressful decimal strings remain useful test inputs, including
   long significands, ties, leading zeroes and range endpoints. The BASIC
   generator's exact anchors do not define compatible reader results.
   Runs are automated Pi5 CLI qualification, not hardware validation,
   performance measurements, approval to commit or acceptance for main.

## Retained history

1. The [earlier exact converter](evidence/literals-001/compiler.bas) and
   [174-case report](evidence/literals-001/summary.json) intentionally selected
   different results in 104 stress cases. That result is rejected as compiler
   compatibility qualification. Preserve its reports and source identities
   unchanged for investigation; see the separate
   [interpreter findings](../../../compiler/INTERPRETER-FINDINGS.md).
2. [Preliminary reports](evidence/literals-preliminary-001/summary.json),
   [promotion rechecks](evidence/literals-promotion-001/summary.json) and
   [prototype debugging](evidence/literals-debug-001/README.md) likewise remain
   historical. They do not establish permission for behavioral changes.
3. The first [compatibility correction run](evidence/literal-compatibility-debug-001/README.md)
   matched packed values but failed on the previously incorrect error text.
   That failure prompted comparison with actual reference error messages.
4. The Author accepted the corrected C002 baseline for committing/pushing on
   the development branch. C003 follows; graphical/hardware acceptance is separate.

## Corrected qualification

1. [Reference-compatible evidence](evidence/literal-compatibility-001/summary.json)
   records 180 literals: 170 values and ten reader errors. Every value matches
   direct BASIC byte for byte, and native value/error output matches. Eight
   unsupported forms are rejected without replacing existing output. Both
   batches repeat deterministically and their runtimes match independent links.
2. The batches took 61.998 and 85.406 seconds (147.404 total), reusing the
   previous BASIC-generated stress inputs without regenerating their anchors.
   These are qualification durations, not target performance measurements.
3. Tested compiler SHA-256 is
   `9a33abb5ffd4e9f6818d22c611842d9ac3bd606aa386bbc2bc7a370d68c0e33a`.
   Runtime and vendor identities are unchanged. The Author explicitly approved
   the development checkpoint; automated results do not approve main promotion.
4. The broader suite passes 28 output programs (20 native executions/eight
   rejections, including 58 prior arithmetic observations) in 148.288 seconds.
   It captures actual reference numeric errors and verifies that an unreachable
   overflowing literal causes no failure. Another 26 targeted expression cases
   pass (nine native/17 rejected) in 51.214 seconds. These compare program
   output and REPORT text, not interactive interpreter prompts.

## Reproduction

Use the existing Pi5 CLI fixture, sequentially from the project root:

```bash
.venv/bin/python docs/tasks/C002/tools/test_literals.py \
  --cli /tmp/bbc-compiler-cli-target/release/agon-cli-emulator \
  --start 0 --count 60 --reject --timeout 180
.venv/bin/python docs/tasks/C002/tools/test_literals.py \
  --cli /tmp/bbc-compiler-cli-target/release/agon-cli-emulator \
  --generated docs/tasks/C002/build/literals/generated/cases.tsv \
  --start 58 --count 122 --timeout 360
.venv/bin/python docs/tasks/C002/tools/test_output.py \
  --cli /tmp/bbc-compiler-cli-target/release/agon-cli-emulator --timeout 300
```

The second command reuses the historical BASIC-generated input TSV; use
`--generate` instead of `--generated` when it is absent. The runner snapshots
compiler source before execution and rejects edits during qualification.

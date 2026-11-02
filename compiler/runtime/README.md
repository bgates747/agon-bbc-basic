# Standalone runtimes

The BBC compiler embeds this runtime as DATA and emits it only when a program
uses numeric expressions. It preserves four-byte integers and five-byte BBC
floats; generated programs execute without the interpreter. The current image
is 4028 bytes before temporary slots and error-message glue.

1. `numeric.s` is the qualified pointer adapter plus required bytewise helpers.
   [ABI](../../docs/tasks/C002/ABI.md) documents selectors, preservation, aliases
   and error handling. C002 qualified binary/conversion calls first, then
   standard unary math functions and PI without altering the vendor source.
2. `expression_runtime.s` adds inline packed-literal copying, unary minus,
   a read-only G9 formatter and numeric PRINT output.
   It includes `numeric.s` last because the unchanged vendor source ends with
   assembler END. All numeric-field accesses in these helpers are byte-sized.
3. `vendor/MATH.Z80` is the unchanged pinned BASIC V package. Keep its
   [license](vendor/LICENSE.txt), headers and [provenance](vendor/PROVENANCE.md).
   The new helpers/adapter are identified as adaptations, not upstream source.
4. Regenerate the complete compiler's DATA suffix from the project root:

   ```bash
   .venv/bin/python compiler/tools/build_numeric_runtime.py --update-compiler
   ```

   The packer rejects unresolved symbols and non-local/non-24-bit relocation
   kinds, and compares rebasing against independent GNU links at &41000 and
   &47000. Its output stays in ignored `compiler/build/numeric-runtime/`.
   Runtime packaging is not BASIC compilation; BBC BASIC performs the final
   source parsing, emission and relocation. Keep generated DATA in the complete
   `compiler.bas`; no external template is needed on Agon.
5. Run the normal [compiler tests](../README.md#automated-qualification), then
   the [C002 integration batches](../../docs/tasks/C002/EXPRESSIONS.md) and
   [numeric ABI probe](../../docs/tasks/C002/README.md) after runtime changes.
   They share one automated CLI profile and must run sequentially. Human
   validation and promotion to main remain separate from automated qualification.

C003's scalar storage glue is emitted by the BBC compiler outside this template.
Physical one/four/five-byte payloads and separate existence flags use native
byte copies; integer/byte assignment calls the existing qualified SFIX adapter.
The numeric template, vendor package and pointer ABI remain unchanged.

C003 adds `strings.s`, a separate 264-byte standalone string core. Its descriptor,
private allocator context, calling conventions and provenance are documented
in the [string contract](../../docs/tasks/C003/STRINGS.md). Regenerate its
embedded DATA independently:

```bash
.venv/bin/python compiler/tools/build_strings_runtime.py --compiler compiler/compiler.bas
```

The string packer checks independent links at &42000 and &48000 and writes
ignored `compiler/build/string-runtime/` artifacts. String DATA starts at 30000;
numeric regeneration at 20000 preserves it. Neither template needs an assembler
or a separate runtime file on the target. Literal-only PRINT still uses its
original compact path and complete assembly golden.

# Standalone runtimes

The BBC compiler embeds this runtime as DATA and emits it only when a program
uses numeric expressions. It preserves four-byte integers and five-byte BBC
floats; generated programs execute without the interpreter. The current image
is 4460 bytes before temporary slots and error-message glue.

1. `numeric.s` is the qualified pointer adapter plus required bytewise helpers.
   [ABI](../../docs/tasks/C002/ABI.md) documents selectors, preservation, aliases
   and error handling. C002 qualified binary/conversion calls first, then
   standard unary math functions and PI without altering the vendor source.
2. `expression_runtime.s` adds inline packed-literal copying, unary minus,
   a read-only G9 formatter, numeric PRINT output and VAL/STR$ bridges.
   [Conversion ABI](../../docs/tasks/C003/CONVERSIONS.md) documents copied
   NUL-terminated VAL input, G9/hex output, private scratch and preservation.
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
The numeric adapter/vendor package and its pointer ABI remain unchanged;
C003 conversions extend the enclosing template by 432 bytes and seven
relocations (4460 bytes/387 relocations total). The packer supports isolated
--source/--output/--compiler paths; default paths remain live source/build.

C003 adds `strings.s`, a separate 623-byte standalone library: the original
264-byte core plus 105 bytes for slices/comparisons, 164 for search/repetition
and 90 for slice assignment.
Its two internal 24-bit relocations are rebased by the BBC compiler. Its descriptor,
private allocator context, calling conventions and provenance are documented
in the [string contract](../../docs/tasks/C003/STRINGS.md) and
[slice/comparison contract](../../docs/tasks/C003/SLICES.md) and
[search/repetition contract](../../docs/tasks/C003/SEARCH-REPEAT.md) and
[slice-assignment contract](../../docs/tasks/C003/SLICE-STORE.md). Regenerate its
embedded DATA independently:

```bash
.venv/bin/python compiler/tools/build_strings_runtime.py --compiler compiler/compiler.bas
```

The string packer checks independent links at &42000 and &48000 and writes
ignored `compiler/build/string-runtime/` artifacts. String DATA starts at 30000;
numeric regeneration at 20000 preserves it. Neither template needs an assembler
or a separate runtime file on the target. Literal-only PRINT still uses its
original compact path and complete assembly golden.

## Native control records

`control.s` implements C004's typed loop/GOSUB stack:8657 bytes (including8192
record bytes),30 internal ADL24 relocations and one compiler-patched numeric
bridge operand. `build_control_runtime.py` packages DATA40000 and checks two
independent link bases. The entry trampoline resets the next-free pointer on
every native entry;256 records have explicit type/body/variable/limit/step fields.
[Control contract](../../docs/tasks/C004/loops/CONTROL.md) and C004 evidence own
ABI/status/qualification. No interpreter globals or entry addresses are linked.

## Scalar procedure/local helpers

`procedures.s` is502 bytes with27 internal ADL24 relocations. Four compiler
patches connect control push/check/pop and numeric conversion. IX/IY/SP are
preserved on ordinary calls; HL returns a saved-local record where documented.
A distinct PROC marker and LOCAL records own a bounded32768-byte private arena;
numeric records occupy14 bytes, string records269 including255 owned bytes.
The arena is reserved after emitted runtime/string workspace and is not emitted
as zero padding. Entry initialises it while preserving MOS DE.
`build_procedure_runtime.py` packages DATA50000 and independent link checks.
[Contract](../../docs/tasks/C004/activations/PROCEDURES.md) owns admission/ABI.

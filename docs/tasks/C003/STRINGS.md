# Mutable string core

The live BBC compiler now supports owned string variables, copying,
concatenation, string PRINT, LEN and CHR$. Qualification compares real BASIC
execution and raw contents, with separate memory and native calling-convention
probes. Expression slicing and string comparisons are now covered by the later
[SLICES.md](SLICES.md) tranche and VAL/STR$/ASC in [CONVERSIONS.md](CONVERSIONS.md); INSTR/STRING$ in [SEARCH-REPEAT.md](SEARCH-REPEAT.md). Slice assignment is covered by [SLICE-STORE.md](SLICE-STORE.md).
LOCAL/arrays/I/O and self-hosting remain C004–C006.

## Source behavior

1. `$` names share the 128-binding limit with numeric names. Names remain
   case-sensitive and suffix-sensitive. Plain and LET assignment create an
   empty binding before evaluating the RHS. An executed read of an uncreated
   binding reports `No such variable`; skipped assignments create nothing.
2. Assignment copies the complete expression result. `a$=a$`, `a$=a$+"x"`,
   copying to another variable and then changing either value preserve owned
   contents. GOSUB sees the same globals. LOCAL/PROC/FN are still rejected;
   future LOCAL must save existence and owned contents and restore prior values.
3. Strings contain zero through 255 bytes. Embedded zero bytes are ordinary
   contents, not terminators. Concatenation associates left-to-right; a grouped
   RHS completes before the enclosing concatenation checks its length. This
   preserves errors such as division by zero inside CHR$ before an outer
   concatenation could overflow. Error 19 reports `String too long`.
4. LEN consumes a string item and produces an integer. CHR$ consumes a numeric
   item, uses the unchanged numeric package's SFIX and takes its low byte.
   Parentheses admit complete expressions; unparenthesised function binding
   matches the reference. PRINT retains numeric field-width/semicolon behavior
   while string expressions write exact bytes through MOS character output.
5. Invalid string/numeric mixing, arrays, I/O-dependent
   additional string functions are compile-time errors. Expression slices and
   string relations are documented in SLICES.md; VAL/STR$/ASC in CONVERSIONS.md. No compound assignment
   or alternate numeric representation is introduced.

## Storage, allocation and ownership

1. A binding has a separate existence byte and a five-byte descriptor:
   length u8, capacity u8, data address u24 little endian. This follows the
   baseline EXEC.Z80 STORE4STR/STORES layout. Length zero avoids dereferencing
   a null pointer. The logical byte contents define the language value;
   addresses and spare capacities need not match the interpreter's heap layout.
2. Expression values occupy private length-prefixed 256-byte buffers. At most
   16 simultaneous string buffers are admitted; numeric/string parser recursion
   shares a 32-entry bound. The compiled image owns these temporary buffers.
   Assignment copies from a completed temporary into the binding's heap block.
   Temporaries and global slots are not yet an activation stack for user calls.
3. Each descriptor retains its capacity on shrink. Storage reuses capacity,
   extends the current tail allocation when possible, or allocates a new block
   and abandons the old one. First allocation has exact length; non-tail growth
   after prior allocation rounds to 2^k-1. This adapts STORES rather than
   inventing reference-incompatible string behavior. No general garbage
   collector or deletion exists in this bounded global-only tranche.
4. Private heap workspace starts immediately after the image. It is reserved
   address space, not file padding, and need not be pre-zeroed. The budget is
   1024 bytes per declared string binding, including unexecuted declarations.
   Capacity never decreases. With arbitrary intervening tail growth, abandoned
   capacities can reach 2+6+14+30+62+126+254, followed by a live 255-byte block:
   at most 749 bytes for a binding. Thus the budget bounds retained allocations
   without importing interpreter variable tables or stack-dependent FREE.
5. The compiler rejects workspace ending above &B0000. Its existing 64 KiB
   image limit and 128 bindings keep this workspace below the MOS module area.
   The MOS stack is retained. Future dynamic bindings, LOCAL or deletion require
   a new ownership/allocation audit; this bound does not cover them.
6. Runtime context contains exact u24 FREE and exclusive-limit pointers.
   Allocation validates the candidate end before updating descriptor/context or
   copying data. Insufficient room returns error 0 (`No room`) and leaves
   descriptor/context unchanged. The compiler's prior binding-creation flag is
   independent. A direct ABI probe exercises this failure with a small limit;
   normal admitted programs have the per-binding reserve above.

## Runtime interface and provenance

The live [strings.s](../../../compiler/runtime/strings.s) now contains the original 264-byte core plus 105 bytes of slices/comparisons.
It is standalone adaptation/new glue based on the baseline's EXEC.Z80 STORES/STORE4STR
and EVAL.Z80 LOADS, CHRS, LEN and string addition. Baseline commit is
`2998edd4ceb6030d6840cb4e3d587e75d94dc44c`; the repository [license](../../../license.txt)
applies. Upstream source and notices remain intact. No interpreter parser,
ACCS, FREE, HIMEM, variable chains, error handler or fixed entry address is linked.

| Entry | Offset | Input | Result |
| --- | --- | --- | --- |
| rt_strliteral | 0 | IX buffer, inline length/payload | Consumes inline record, copies length+payload |
| rt_strload | 14 | IX buffer, IY descriptor | Copies logical contents, avoids null for empty |
| rt_strcat | 37 | IX lhs buffer, IY rhs buffer | A=0/Z/NC; overflow A=19/NZ/C, lhs unchanged |
| rt_strstore | 82 | IX descriptor, IY complete buffer, HL context | A=0/Z/NC; no room A=0/Z/C, descriptor/context unchanged |
| rt_strprint | 234 | IX buffer | Writes length bytes with RST.LIS &10 |

All entries preserve IX/IY and return with balanced SP (literal advances the
inline return address); AF/BC/DE/HL are volatile. Counts for LDIR initialise
all 24 BC bits. Descriptor/context pointer loads and stores deliberately use
ADL three-byte accesses; byte lengths/capacities use byte accesses. No page
alignment assumption is inherited from ACCS. The direct probe crosses a page
with a descriptor and poisons upper BC bits.

The runtime has no absolute internal relocations or unresolved imports.
Packaging still verifies independent links at &42000 and &48000; BBC BASIC
copies the template and owns final symbol resolution/emission. Numeric DATA
at line 20000, its vendor package and license are unchanged. String DATA begins
at 30000. Numeric regeneration preserves the string DATA suffix.

## Reproduction and evidence

Use the existing Pi5 CLI fixture and run sequentially from the project root:

```bash
.venv/bin/python compiler/tools/build_strings_runtime.py --compiler compiler/compiler.bas
.venv/bin/python docs/tasks/C003/tools/test_strings.py \
  --cli /tmp/bbc-compiler-cli-target/release/agon-cli-emulator \
  --compiler compiler/compiler.bas --timeout 360
.venv/bin/python docs/tasks/C003/tools/test_string_storage.py \
  --cli /tmp/bbc-compiler-cli-target/release/agon-cli-emulator
.venv/bin/python docs/tasks/C003/tools/test_string_abi.py \
  --cli /tmp/bbc-compiler-cli-target/release/agon-cli-emulator
.venv/bin/python docs/tasks/C003/tools/test_string_limits.py \
  --cli /tmp/bbc-compiler-cli-target/release/agon-cli-emulator
```

[Prototype evidence](evidence/strings-001/summary.json) retains exact compiler,
runtime, tools, source programs, transcripts and raw memory. It passes 23
programs (14 native/nine rejected) in 88.088s, 15 string bindings plus an
uncreated descriptor and memory guards in 53.404s, and the ABI probe in 1.016s.
The storage probe used 1055 bytes of its 16384-byte heap reserve and checked
15361 untouched bytes after FREE, including 32 beyond the limit. It also
checks a LEN result in a four-byte integer binding. Binary snapshots use
`.dat` without altering their bytes; manifests cover retained files.

The initial string-core promotion's compiler SHA-256 is
`2f1c96a70756f07b7a833707092c52a91ab680e66aa81d286ed936b1195b9458`.
[Live-location evidence](evidence/strings-promotion-001/summary.json) passes
23 string programs in 93.371s, 15 string bindings plus guards in 53.419s,
and the expanded ABI probe in 1.015s. The example and the explicit 16-buffer/
32-nesting rejections pass as a three-program batch in 27.974s. The expanded
probe also checks complete descriptor/context state after allocation failure,
all remaining heap guard bytes, and same-buffer concatenation. Numeric
regressions pass 29 scalar programs, 28 output programs and expression batches
of 12 and 26; the 39-case baseline retains its full assembly golden.
Failed early experiments remain separate evidence, not counted passes. One
regression discovered stale first-binding metadata when consecutive programs
began with the same name; the lookup now uses WHILE rather than a BBC FOR loop
with a reversed zero-length range. Both numeric and string suites exercise it.

Automated CLI qualification does not claim a speedup, human graphical emulator
acceptance, physical hardware qualification or permission to merge to main.
Oryx remains untouched. New tranche changes remain uncommitted for Author review.

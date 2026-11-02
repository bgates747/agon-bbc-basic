# Assignment to string slices

LEFT$/RIGHT$/MID$ assignment modifies an existing string without changing its
length, descriptor or allocation. It follows the reference's byte-range rules,
which differ from expression slicing. The fully qualified
prototype is promoted to compiler/compiler.bas and compiler/runtime/strings.s;
C003.md records exact evidence. Selected live rechecks pass; C003 is complete for its initial scalar/string scope.

## Source and reference contract

1. Forms are LEFT$(target$[,count])=source$, RIGHT$(target$[,count])=source$,
   and MID$(target$,start[,count])=source$. The target must be an existing scalar
   string binding; it is not created implicitly. Array/indirect targets remain
   C005. GETSTR checks target existence before count/start and RHS evaluation.
2. EXEC.Z80 LEFTSL/RITESL/MIDSL encode a first/last byte range. Starts/counts
   pass through SFIX then use their low byte. Every explicit argument is
   evaluated, and RHS is evaluated even for empty targets and no-op ranges.
   Default LEFT modifies all but the last character; default RIGHT modifies
   at most one final character. Explicit count zero does nothing.
3. LEFT begins at the first character and copies up to count existing bytes.
   RIGHT uses min(count,RHS length) before selecting its start: RIGHT$(a$,5)="XY"
   replaces the final two characters (when available), using "XY". A shorter
   target bounds the copy; no form extends a string.
4. MID start byte minus one becomes the first-index marker. Start zero with
   omitted count does nothing, while start zero with explicit nonzero count
   uses RIGHT's selection behavior. A computed last marker of 255 means
   all-but-last; for example MID$(a$,2,255) preserves the final character.
   Overflow of the last-index sum otherwise caps it to254. These reference
   quirks are preserved, not replaced with saturating mathematical ranges.
5. RHS is a completed private value before mutation, preserving self-reference
   and independent bindings. The target descriptor is read after RHS evaluation,
   so later FN side effects can change its current contents/length before the
   write, matching MIDSL1. Count/RHS errors occur before any slice write.

## Native contract

1. rt_strwrite takes IX=five-byte destination descriptor, IY=read-only length-
   prefixed RHS buffer, and L/H=first/last range markers. Upper HL is ignored
   and cleared internally. Descriptor identity is stable; its length/capacity/
   pointer and the binding existence flag are not changed. No allocator call or
   FREE update occurs. Source/target data do not overlap because RHS is copied.
2. IX/IY/SP are preserved; AF/BC/DE/HL otherwise volatile. Completion returns
   A=0/Z/NC, including no-op cases. Range/count and source errors are handled
   before this entry. Empty targets may have a null data pointer; zero-copy
   paths never dereference it or enter LDIR with a zero count.
3. The 90-byte adaptation of SUBSL0–9 replaces ACCS and XEQ with explicit caller
   buffers and return status. Full 24-bit pointers/counts are deliberate; poison
   in upper offset/count registers cannot affect a write. Buffer page crossing
   is supported. Same repository zlib-style license/source attribution applies.
4. The former 533-byte library is an exact prefix of the 623-byte template.
   The two original internal relocations remain; both packer/GNU independent
   links and BBC relocation must agree. Numeric runtime/DATA/vendor/license are
   unchanged. The compiler remains BBC BASIC.

## Qualification and reproduction

Run sequentially with the project Python and authorized Pi5 CLI fixture. Oryx
remains unavailable. The Author waived earlier approval stops, while actual
emulator/hardware evidence must still be distinguished.

```sh
.venv/bin/python compiler/tools/build_strings_runtime.py --compiler compiler/compiler.bas
.venv/bin/python docs/tasks/C003/tools/test_slice_store.py --cli /tmp/bbc-compiler-cli-target/release/agon-cli-emulator --timeout 600
.venv/bin/python docs/tasks/C003/tools/test_slice_store_abi.py --cli /tmp/bbc-compiler-cli-target/release/agon-cli-emulator
.venv/bin/python docs/tasks/C003/tools/test_string_storage.py --slice-store --cli /tmp/bbc-compiler-cli-target/release/agon-cli-emulator
```

C003.md and the dated log record exact inputs, hashes, durations and promotion.
This contract does not implement arrays, LOCAL or I/O; their accepted scopes
remain in C004/C005 in the sole TODO.

# String and numeric conversions

VAL, STR$ and ASC use the reference BASIC behavior. Decimal parsing and G9
formatting execute the pinned numeric package; no Python parser or alternate
numeric representation is involved. The qualified source is
promoted to compiler/compiler.bas and compiler/runtime/expression_runtime.s;
C003.md records evidence and exact promotion. New work remains uncommitted.

## Reference contract

1. EVAL.Z80 VAL calls ITEMS (one string item, with parentheses admitting a full
   expression), places NUL at ACCS+length, then invokes FPP selector 36. MATH.Z80
   VAL uses SIGNQ/CON/NUMBER; it parses a decimal prefix, not an expression.
   Leading ASCII spaces and one sign are accepted; a space after the sign,
   tab, hexadecimal prefix or nonnumeric first character yields the reference
   zero/prefix result. Uppercase E has the existing exponent quirks. Embedded
   NUL terminates conversion even when the logical string continues.
2. The native bridge copies all logical bytes into private 256-byte scratch,
   appends NUL and calls exactly selector 36. It stores the returned integer/
   float five-byte record without coercion. Package errors propagate at runtime;
   input strings and the result on failure remain unchanged.
3. EVAL.Z80 STRS consumes ITEMN. With the default @% high byte zero it selects
   G9 regardless of PRINT's field width. STR$ therefore has no PRINT padding.
   The existing rt_format helper calls FPP selector 37 with private G9 control;
   the bridge stores its returned text length in the string temporary. Mutable
   @% and other format modes remain unsupported.
4. STR$~ adapts EVAL.Z80 HEXSTR: SFIX first, then eight high-to-low nibbles,
   uppercase hex digits with leading zeros suppressed except the final zero.
   Negative integers produce eight digits. Fractional values truncate with the
   same SFIX and out-of-range values raise its error. Unlike ACCS's aligned-page
   length convention, the bridge subtracts full pointers so buffers may cross
   a page boundary.
5. ASC consumes one string item. Empty returns integer -1; otherwise the first
   unsigned byte is returned, including NUL and bytes 128..255. The BBC compiler
   emits this directly with an explicit length test and a four-byte integer
   result; it does not depend on C string termination.
6. The existing typed expression parser preserves item binding: STR$ 1+STR$ 2
   concatenates two strings, while STR$(1+2) converts a numeric expression.
   VAL "1"+"2" is a compile-time type mismatch; VAL("1"+"2") is valid.
   Nested conversions retain independent numeric/string temporaries.
7. Agon's text loader OSLOAD_TXT2 discards control bytes even inside quotes.
   Raw source bytes below ASCII space in quoted literals are rejected clearly
   until that normalization is qualified. Use CHR$ to construct such runtime
   data; all 0..255 string bytes remain supported.

## Standalone bridge ABI

| Entry | IX | IY | Result |
| --- | --- | --- | --- |
| rt_val | Writable five-byte packed number | Read-only length-prefixed string | Number stored on success only |
| rt_strnum | Read-only five-byte packed number | Writable 256-byte length-prefixed buffer | G9 text and length |
| rt_strhex | Read-only five-byte packed number | Writable 256-byte length-prefixed buffer | 1..8 hex characters and length |

1. IX/IY/SP are preserved. Other registers and flags are volatile except status:
   success A=0/Z/NC; failure A=package error/NZ/C. Input/output do not overlap.
   STR$ commits length only on success; decimal character scratch may already
   have been written if the formatter raises an error. Hex SFIX errors precede
   all output writes. VAL never mutates its input or a failed result.
2. VAL scratch is private, synchronous and non-reentrant, like the existing
   numeric PRINT scratch. There are no interpreter-global, firmware-address or
   external BASIC-binary dependencies. Future asynchronous/reentrant runtime
   use needs an explicit scratch-lifetime change.
3. Full 24-bit pointers/counts are initialized. Zero-length input skips LDIR;
   maximum input copies 255 bytes and places its NUL inside the 256-byte
   scratch. Packed numeric access remains five explicit bytes, never a wide
   load across a payload boundary.
4. MATH.Z80 and its license remain unchanged. New bridges and HEXSTR adaptation
   carry the same repository license/provenance described in REFERENCE.md and
   runtime/vendor/PROVENANCE.md. HEXSTR is adapted code, not an unmodified entry:
   it uses caller-owned length-prefixed storage and preserves the native ABI.

## Reproduction

Use `.venv/bin/python` from the repository root and the Pi5 automated fixture.
Oryx remains unavailable; these are automated CLI checks, not human/hardware
acceptance. The runtime packer accepts --source/--output/--compiler for isolated
experiments and still independently verifies relocation at two nonzero bases.

```sh
.venv/bin/python compiler/tools/build_numeric_runtime.py --update-compiler
.venv/bin/python docs/tasks/C003/tools/test_conversions.py --cli /tmp/bbc-compiler-cli-target/release/agon-cli-emulator
.venv/bin/python docs/tasks/C003/tools/test_conversion_abi.py --cli /tmp/bbc-compiler-cli-target/release/agon-cli-emulator
.venv/bin/python docs/tasks/C003/tools/test_string_storage.py --conversions --cli /tmp/bbc-compiler-cli-target/release/agon-cli-emulator
```

[Prototype evidence](evidence/conversions-001/summary.json) passes 29 programs
(18 native/11 rejected), 14 string bindings/22 numeric records, native ABI and
the 39-case baseline. [Live rechecks](evidence/conversions-promotion-001/summary.json)
repeat the example, memory/ABI/baseline and earlier string/numeric regressions,
including 449 numeric ABI cases and 45 formatter cases. Their scopes are
separate; the full 29-case run was at the prototype path. Exact hashes and
promotion destinations are recorded in C003.md and the dated development log.
The full conversion run took 201.849s; its default compile guard is 360 seconds. Search/repetition are now covered by [SEARCH-REPEAT.md](SEARCH-REPEAT.md);
slice assignment and remaining facilities stay in the sole TODO.

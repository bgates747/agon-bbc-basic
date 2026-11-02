# String slicing and comparisons

This C003 tranche adds expression slices and the six string relations needed
by the compiler's own parsing logic. Results and errors are qualified against
the actual reference interpreter. VAL/STR$/ASC are qualified in the later
[conversion tranche](CONVERSIONS.md). [Slice assignment](SLICE-STORE.md) is qualified separately. I/O-dependent string
functions, LOCAL and arrays retain their separate C004/C005 scope.

## Reference audit and source contract

1. Audited baseline `2998edd4ceb6030d6840cb4e3d587e75d94dc44c`, EVAL.Z80
   MIDS/LEFTS/LEFT1/RIGHTS/RIGHT1 (around lines 1606–1709) and EXPR2S/SCP0
   (around lines 284–311 and 1870–1910). These entries depend on expression
   parsing, interpreter stacks, ACCS page alignment, alternate-register values
   and error machinery. The runtime adapts their byte algorithms to explicit
   private buffers; no interpreter entry is called at a fixed address.
2. `LEFT$(s$,n)` returns the first min(length,n-low-byte) bytes; `RIGHT$(s$,n)`
   returns the last such bytes. Omitted LEFT$ count removes one final byte;
   omitted RIGHT$ count returns one final byte. Empty remains empty.
3. `MID$(s$,start[,n])` uses the low byte of the one-based start. Start zero
   retains the full string; otherwise it selects from start to end, or empty
   when start exceeds length. The optional count then applies LEFT$ to that
   result. A zero count selects empty. Explicit count 256 becomes zero;
   count -1 becomes 255. These quirks are preserved, not replaced by signed
   clamping. Argument expressions pass through the unchanged numeric SFIX
   package first; out-of-range conversion still errors before low-byte use.
4. Argument evaluation is left-to-right: source string, start/count expression
   and its SFIX, then optional MID$ count and SFIX. The MID$ start operation
   occurs before its optional count expression. Even an empty intermediate
   result still evaluates an explicit count. RHS errors and overflow preserve
   reference ordering. Functions require parentheses; slice assignment targets
   remain rejected clearly.
5. Strings compare unsigned bytes from the first character, then lengths when
   one is a prefix. NUL is ordinary data; byte 255 sorts above byte 128 and
   ASCII letters. =, <>, <, <=, > and >= return numeric signed integers -1 or 0,
   usable in PRINT, VDU, assignments, arithmetic, Boolean expressions and
   existing functions. Operators retain numeric precedence; concatenation binds
   before relations, which bind before AND/EOR/OR. Comparisons do not chain
   without parentheses. Source operands remain independently owned.
6. The BBC parser carries an explicit numeric/string result kind. Both parsers
   share the existing numeric and string temporary pools and recursion limit;
   runtime values retain their existing packed layouts. Invalid type mixing
   is a compile-time error. Literal-only PRINT retains its original direct
   output path and complete assembly golden. No new numeric reader or format
   behavior is introduced.

## Native buffer interface

The original 264-byte string core remains the exact prefix of the 369-byte
library. The new helpers occupy 105 bytes and need no absolute internal
relocations or globals. They derive from the reference routines above, authored
by Richard T. Russell (1981–2025), and are marked as altered standalone glue.
The root license and original source notices remain in the distribution.

| Entry | Offset | Input | Output |
| --- | --- | --- | --- |
| rt_strleft | 264 | IX buffer, A count low byte | In-place prefix |
| rt_strright | 272 | IX buffer, A count low byte | In-place suffix |
| rt_strmid | 283 | IX buffer, A start low byte | In-place suffix from one-based start; zero keeps all |
| rt_strcompare | 326 | IX lhs buffer, IY rhs buffer | A=255 less, 0 equal, 1 greater; operands unchanged |

All preserve IX/IY and balanced SP; AF/BC/DE/HL are volatile. Slices cannot
increase a length or allocate. Moves clear all 24 BC bits and bypass LDIR when
count is zero. Pointer arithmetic uses full ADL addresses, with byte-sized
lengths/data and no page-aligned ACCS assumption. Comparison reads only logical
contents and never modifies them. The BBC compiler turns the order result into
four signed Boolean bytes plus the zero integer marker, using the existing
five-byte numeric slot; no alternate representation is introduced.

## Qualification and promotion

Experimental code and tools belong under C003 until qualification. Selected
source, logs, exact contents, native guards and independent-link evidence are
retained in C003 evidence directories. Task C003 owns promotion disposition;
TODO remains the sole unfinished-work list. Human/hardware validation and main
promotion are separate from the Pi5 automated CLI checks. Oryx remains unused.

[Prototype evidence](evidence/slices-001/summary.json) passes 36 programs
(25 native/11 rejected) in 277.395s, 23 raw string bindings plus guards in
86.461s, the native ABI probe in 1.016s and the 39-case/15-execution assembly
baseline in 29.518s. The promoted compiler is byte-identical, SHA-256
`09e736f210007086a5c4645e4e96e14a717f28f340acbe1860c170bf19dcfbc0`.
Numeric DATA/vendor/license and the old string-runtime prefix are unchanged.
Historical failed experiments remain evidence, not accepted passes.

Run sequentially from the project root using the existing automated CLI fixture:

```bash
.venv/bin/python compiler/tools/build_strings_runtime.py --compiler compiler/compiler.bas
.venv/bin/python docs/tasks/C003/tools/test_slices.py \
  --cli /tmp/bbc-compiler-cli-target/release/agon-cli-emulator --timeout 480
.venv/bin/python docs/tasks/C003/tools/test_string_storage.py --slices \
  --cli /tmp/bbc-compiler-cli-target/release/agon-cli-emulator
.venv/bin/python docs/tasks/C003/tools/test_slice_abi.py \
  --cli /tmp/bbc-compiler-cli-target/release/agon-cli-emulator
```

`--smoke` selects the first mixed integration program. The full 36-program
suite runs on the prototype; selected integration, memory/ABI probes and prior
regression suites repeat at the exact promoted live source. Retained
[live evidence](evidence/slices-promotion-001/) distinguishes these scopes.
The parser retains the 32-entry guard's existing accounting: all items and
numeric expression frames count; string expression frames do not add a second
charge. The independent 16-string-buffer guard remains in place.

[Live qualification](evidence/slices-promotion-001/summary.json) passes the
39-case baseline in 29.361s, selected mixed integration in 33.787s, both native
ABI probes in 1.016s each and 23 raw string bindings plus guards in 85.953s.
The previous 23-case string suite, three limit/example cases, 29 scalar cases,
28 numeric-output programs and expression batches of 12/26 all pass.

A focused additional program checks quoted-literal PRINT comparisons, field
widths, concatenation precedence, numeric-function input and a slice count
reading its original target. It passes in 30.774s and is now the **37th** case
in the full maintained suite. Run it alone with `--print-dispatch`. The full
36-program prototype run and selected live checks are recorded separately;
no full live 37-program run or benchmark speedup is claimed. Source/runtime
promotion remains exact and new tranche work stays uncommitted for review.

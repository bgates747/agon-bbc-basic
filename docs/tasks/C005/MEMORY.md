# Arrays, raw allocation and indirection qualification

The live BBC compiler now supports global arrays of the existing BBC value
types, raw DIM blocks and byte/integer/variant memory access. Reference quirks
are retained, including DIM's target-address seed and repeated-DIM error path.
DATA, file/input syntax, source error handlers and self-hosting remain separate
C005/C006 work.

## Admitted language and representation

1. Numeric/string arrays share256 bindings with scalars; array and scalar names
   are distinct. Each array has a three-byte pointer cell and existence flag.
   The allocated descriptor contains a dimension byte and inclusive24-bit counts;
   elements are one-byte `&`, signed32-bit `%`, five-byte numeric variants or
   five-byte string descriptors. Indexing is row-major. Allocation zeroes all bytes.
2. DIM accepts1..16 dimensions, consistent static arity, and SFIX dimensions/indices.
   Validate each dimension/index before evaluating the next. Preserve undeclared
   read26 versus undimensioned write/address14, bad dimension10, space11 and
   subscript15. Existing numeric/byte DIM evaluates subscripts, seeds the element
   and raises Syntax16 when no raw size follows; strings raise10.
3. Raw DIM supports four-byte/variant numeric targets, including zero-byte blocks
   from size-1. It seeds the target with its own address's low16 bits before RHS
   evaluation. Its final store replaces only the low24 pointer bits, retaining
   any high byte/exponent changed by the RHS. Do not replace this behavior by zero.
4. Unary `?`, `!`, `|` access byte, four-byte integer and five-byte variant values;
   binary `base?offset`/`base!offset` use ITEM/SFIX precedence and low24 addresses.
   Unary `^` obtains a scalar/element address, creating a missing scalar binding.
   Native addresses refer to the program's own storage; integer payloads remain
   four bytes regardless of ADL pointer width. Lvalue addresses survive RHS calls.
5. Array string elements retain independent owned contents. Global DIM/string
   allocation shares an explicit heap ending at&AFF00, excluding a32768-byte
   activation arena when needed. Programs without these memory facilities retain
   the earlier scalar string layout. Existing LOCAL/argument/FN-prefix restoration
   remains distinct from global allocation; ordinary LOCAL pointers do not roll
   back DIM allocations.
6. Explicit exclusions: LOCAL arrays, whole-array operations/parameters, array
   FOR targets and slice-assignment targets, raw byte targets, DIM LOCAL blocks,
   inconsistent arity and raw-DIM sizes targeting array elements. FN/address-of
   in array DIM bounds is unqualified because reentrant reference allocation can
   stall; reject clearly. Raw block RHS FN/address expressions are admitted.

## Evidence and exact promotion

1. `array-reference-001/003` retain actual BBC observations;002 is the failed
   nested-DIM run with29 completed observations before its180s guard. Source
   findings and corrections are in ARRAYS.md and interpreter findings. No
   intended-result oracle replaces the reference.
2. `memory-abi-001` qualifies the734-byte/83-relocation helper in1.016s:65537-byte
   zeroing, guards, exact bounds/overflow, widths/strides,16 dimensions, early
   checks, error atomicity and IX/IY/SP preservation. Independent links are at
   &42000/&48000.
3. The first1777-line prototype (SHA d865116e) passes combined smoke210.478s,
   full53 cases995.165s (40 native/13 rejected) and baseline71.317s. All used
   NUM/string/memory helpers match GNU links; selected activation/control images,
   bridges and entry arena checks also pass. `memory-smoke-001` and `memory-001`
   are curated current-scope artifacts.
4. The binding stress first fails at the older2048-fixup cap; retain
   `bindings-fixup-limit-001` as failed evidence. Actual interpreted host PROCinit
   free space is163763 bytes. Enlarging only those four tables by34816 bytes
   leaves128947, measured again. This is host evidence, not a native compiler fit.
5. Exact promoted source SHA256
   `d0368b1ea7ebc0ac26da0f13d07c3f40d6c776c9f5f2b0c4a2c31bc78576ab1c`
   retains1777 ordered lines,256 bindings and4096 fixups. It passes binding5-case
   scope1289.261s, including256/257 and oversized-branch rejection; array53-case
   scope998.339s wall time; baseline71.307s and FN smoke83.489s. All five live
   packers reproduce it. `memory-capacity-001` freezes exact source/results;
   selected live checks are separately retained in `memory-promotion-001`: baseline
   71.907s, memory smoke145.424s and typed-loop smoke70.781s (controller times).
6. Numeric/vendor, string, control and activation runtime sources remain unchanged.
   The new library is standalone assembly runtime; all compiler logic remains
   BBC BASIC. No emulator result is a human review, hardware result, self-hosting
   proof or benchmark-speed measurement.

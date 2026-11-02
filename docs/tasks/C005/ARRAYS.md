# Array, DIM and address implementation contract

Arrays and memory access are required by the compiler's real BBC source. This
tranche preserves the reference's numeric/string widths, dimension evaluation
and error boundaries; it supplies standalone runtime state instead of linking
the interpreter's parser, variable chains, FREE or error machinery. Nothing in
this document is a qualification result.

## Reference and dependency audit

1. `include/bbc-ez80/EXEC.Z80` DIM/DIM1/DIM3/DIM4/DIM8 allocates a descriptor
   containing a dimension byte and inclusive counts stored as24-bit values.
   Elements are byte, four-byte signed integer, five-byte numeric variant or
   five-byte string descriptor. Allocation zeroes every element/block byte.
   MAIN.Z80 GETVAR/GETV3 indexes rows using `offset*current_count+index`.
2. Dimensions/subscripts first use the qualified SFIX conversion. Dimensions
   require a zero top integer byte (error10); inclusive-count/product overflow
   or exhausted storage gives11. Subscript bounds use error15. Missing array
   bindings use26; a created but undimensioned array uses14.
3. **Corrected by actual reference probes:** an existing array takes DIM4's VAR
   path, evaluates the parenthesized expressions as subscripts and may treat a
   numeric element as a raw block target. `DIM a%(FNmark)` after allocation prints
   the side effect and gives Syntax error16, rather than an early Bad DIM10.
   Its target can already have changed before the missing size expression fails.
   Do not use the helper's existing-pointer guard as BBC DIM statement semantics.
4. **Corrected by actual reference probes:** raw DIM changes its target before
   evaluating size, but the initial assumption that this stores zero is false.
   `DIM p% p%` allocates an unexpected nonzero block in the pinned interpreter.
   `array-reference-003` confirms an integer equal to the target address's low16
   bits (variant exponent0), matching DIM8's EXX/STOREN path. A size FN can
   overwrite the target's top byte; DIM3 subsequently replaces only the low24
   pointer bits. Preserve both effects; do not replace the initial store by zero.
   The size is truncated to24bits and incremented. Explicit `DIM p% LOCAL size`
   selects stack storage;
   `LOCAL p%` followed by ordinary DIM only localizes the pointer binding.
   Byte-target raw DIM and LOCAL arrays/whole-array arguments remain excluded
   initially; they are not bootstrap-source requirements.
5. GETV5/6/F/8/9/A/0 defines byte/four-byte/five-byte indirection, low24-bit
   addresses and ITEMI offset precedence. EVAL.Z80 ADDROF obtains the actual
   value address. The compiler must preserve these representations and stage
   target addresses across RHS FN calls. It must not substitute three-byte
   numeric integers for ADL convenience.
6. MUL24 can be adapted with explicit private scratch; retain repository license
   and identify the altered implementation. No arithmetic parser, hidden
   interpreter entry or global R0/FREE dependency may remain.

## Initial standalone helper ABI, before implementation

1. `mem_alloc`: IX addresses `{u24 free,u24 exclusive_limit}`; HL is a24-bit
   byte count. Success zeroes exactly that range, advances free, returns DE=old
   free and HL=new free with A0/Z/NC. Zero count is valid and writes nothing.
   A11/NZ/C means overflow/no space with context and destination unchanged.
2. `array_dim`: IX addresses a three-byte array pointer cell (zero initially),
   IY points to contiguous five-byte SFIX dimension records, HL addresses the
   shared allocation context, A is dimension count1..16, B element width1/4/5.
   Validate every count/product before allocation; commit the pointer only on
   success. A10 or11/C reports Bad DIM or DIM space. This guarded helper handles
   a new-array allocation; the BBC frontend must separately preserve DIM4's
   existing-array behavior and any reentrant dimension-expression effects.
3. `array_addr`: IX addresses the pointer cell, IY addresses SFIX subscript
   records, A is subscript count, B element width. Return HL=element address,
   A0/Z/NC. Errors14/15 mean undimensioned array/bounds;5/27 mean missing comma or
   right bracket. Initial compiler admissions require consistent static arity
   so staged arguments cannot introduce wrong-arity side-effect differences.
4. All entries preserve IX/IY/SP; AF/BC/DE/HL are volatile. Helpers are synchronous
   with no language evaluation/callback inside them. Private scratch is allowed;
   nested BASIC expressions finish before helper entry. Clear full ADL counts
   and guard null/zero LDIR. The helper neither parses BASIC nor performs SFIX.
5. Numeric/string allocations share one explicit context when these facilities
   are enabled, with a separately reserved activation arena. Existing programs
   retain their qualified allocation layout. Array string elements use the same
   owned five-byte descriptors and storage helper as scalar strings.
6. `dim_step`: IX addresses a five-byte positive integer running product, IY
   a five-byte SFIX bound. Validate bound/inclusive-count/product and update only
   the running product on success. Return10/11/C atomically on failure. Emit
   after each bound expression, before evaluating the next. The final array_dim
   still validates its inputs independently and includes element-width overflow.
7. `array_prefix`: same input registers as array_addr, count0..16. Validate the
   array before the first expression (count0), then the evaluated index prefix
   after each expression. Success returns A0/Z/NC (HL unspecified); a short
   prefix needs no missing-comma error. This preserves early bounds errors
   without allowing a nested FN call to corrupt hidden incremental state.

## Qualification scope

1. Capture actual interpreter oracles before admitting syntax: zero/fractional
   dimensions, strides, all element types, missing arrays, bounds, redimension
   ordering, raw zero/negative sizes, address wrapping and offset precedence.
2. Native ABI probes independently link helper images, poison upper registers,
   cross pages and test exact allocation bounds, zero initialization, guards,
   descriptors, error atomicity and index/stack preservation.
3. Differential programs exercise nested array subscripts, LOCAL scalar pointers,
   recursion/FN side effects while storing, string ownership and raw numeric
   bytes. Preserve all earlier baseline/PROC/FN/loop behavior. Record static
   arity/LOCAL-array exclusions explicitly before promotion.

## DIM admission correction before frontend integration

1. `array-reference-002` reaches nested-first-dim, then stalls until the180s
   guard. The29 preceding observations are retained as partial evidence; it is
   not a successful oracle run. The clean30-case `array-reference-003` omits
   that stalling case and confirms raw-target seeding/mutation, repeated numeric,
   byte and string DIM behavior and early product overflow.
2. Array DIM bound expressions containing FN calls or unary address-of remain
   explicitly unqualified initially. Reject those at compile time: reentrant
   allocation while the reference has a pending descriptor is not a safe
   compatibility contract. Raw block size FN/address expressions remain admitted
   for separate tests; DIM4 obtains FREE after their evaluation.
3. Capture whether the array already exists before evaluating bounds. A new
   array validates bounds/products incrementally; an existing one validates
   subscripts incrementally. With no size expression after `)`, a repeated
   numeric/byte DIM seeds the selected element from its own address and raises
   Syntax error16; string elements raise10. The frontend must preserve these
   states when error recovery is later enabled. Extra raw-DIM sizes targeting
   array elements remain outside initial admissions.
4. Initial frontend code in memory/frontend.bas is unintegrated experimental
   source. Its earlier zero-store/early-redimension assumptions are superseded
   by this correction and must be replaced before qualification.

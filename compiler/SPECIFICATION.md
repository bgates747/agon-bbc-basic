# Native compiler specification — DRAFT

The current implementation proves the path from BBC BASIC source to a MOS
native executable. Later stages must preserve BBC BASIC values and activation
semantics before broadening the accepted language. This draft describes the
promoted C001 bootstrap, C002 numeric expression/output and C003 scalar/string operations, C004 control/activations and C005 memory facilities in
`compiler/compiler.bas`. These remain on the development branch pending
accepted testing before promotion to main.
Task documents and experimental silos follow
[the accepted task convention](../docs/tasks/README.md).

## Current source language

The reference interpreter defines observable behavior for supported conventional
programs. Execution speed is the only intended runtime difference. Preserve its
numeric conversion, rounding, types, errors and output, including quirks; a more
mathematically accurate result is not a compatibility fix. Optional line numbers
and named labels are the explicitly agreed syntax extensions. Unsupported
facilities must be rejected clearly. Possible interpreter improvements are
recorded separately in [research findings](INTERPRETER-FINDINGS.md) and do not
change this contract. Earlier deliberate decimal-reader corrections are withdrawn;
The Author accepted the corrected C002 baseline for a development checkpoint.

1. Input is plain byte text with LF, CRLF or CR line endings; final newline is
   optional. Maximum physical line length is 255 bytes. Tokenised `.bbc` input
   and UTF-8 identifiers are unsupported. Raw control bytes inside quoted source
   are rejected; construct them with CHR$. The reference text loader drops such
   bytes, so accepting them literally would change behavior. Diagnostics use physical file line
   and column positions, independent of optional BASIC line numbers.
2. Keywords are uppercase. Names are case-sensitive, begin with an ASCII
   letter or underscore, and contain letters, digits or underscores, with a
   maximum body length of 32; scalar type suffixes are separate. Keyword
   abbreviations and ambiguous keyword-prefix variable forms are unsupported.
3. Optional decimal line numbers are labels in file order. Numbered lines must
   increase strictly and be in 0..65279. Mixed numbered and unnumbered source
   is allowed. The compiler does not reorder physical lines.
4. Proposed named label syntax is `@name:` at a statement boundary; targets
   are `GOTO @name` and `GOSUB @name`. For example:

   ```basic
   GOSUB @message
   END
   @message:
   PRINT "Hello"
   RETURN
   ```

   `@` followed by a name distinguishes a label from a variable, PROC, FN,
   and BASIC's `@%` format variable. Labels belong to the global or current
   PROC/FN scope; branches across activation boundaries are rejected.
5. `GOTO` and `GOSUB` accept numeric line constants or named labels. Forward
   references are resolved after parsing. Duplicate and undefined labels are
   compile errors. Computed destinations are unsupported.
6. Colon separates statements. A named label may precede a statement on the
   same line. `REM` consumes the rest of the physical line, including colons.
7. `PRINT` accepts string and numeric expressions in a semicolon list.
   Numeric output uses the reference's default G9 format and an initial minimum
   field width of ten characters. A semicolon sets subsequent numeric padding
   to zero; a final semicolon suppresses the newline. A leading semicolon is
   supported. Bare `PRINT` emits CR/LF. Doubled quotes represent one quote;
   colon inside a string is data. Comma zones, TAB/SPC, hexadecimal PRINT,
   @% assignment remain unsupported. STR$ and STR$~ are string expressions.
8. `VDU` accepts comma-separated numeric byte expressions, converts each through
   the package's SFIX semantics and emits the low byte. Negative values and
   byte wrapping are supported when conversion fits a signed integer. Word
   and zero-fill forms remain unsupported. `CLS` emits VDU 12.
9. `END` and falling off the source exit to MOS. `RETURN` without GOSUB reports
   `No GOSUB`; nested GOSUB is limited to 255 frames. Runtime failures return
   status 1, success returns status 0. `END` unwinds all outstanding GOSUBs.
10. Unsupported statements and trailing unparsed text are compile errors.
    `EVAL` is deliberately excluded. No compound assignment or other unrelated
    syntax is introduced.
11. Scalar numeric assignment accepts `name=expression` and `LET name=expression`.
    Names and suffix variants are case-sensitive. Unsuffixed variables preserve
    five-byte numeric variants; `%` stores four signed integer bytes and `&`
    stores one unsigned byte. Integer/byte assignment uses reference SFIX,
    including its range failures; byte stores the low byte. A%–Z% are predefined
    at zero. Other bindings are created at zero before their first assignment
    RHS executes; reading an uncreated binding reports `No such variable`.
    GOSUB shares these global bindings. Arrays, pseudo-variable assignments
    and LOCAL remain rejected. See the [scalar contract](../docs/tasks/C003/SCALARS.md).
12. String assignment accepts `name$=expression`, optionally preceded by LET.
    `$` names are independent of numeric suffix variants. Assignment creates
    an empty binding before the RHS and copies the completed value. Strings
    contain 0..255 bytes including embedded NUL. Concatenation uses + and
    parentheses; groups finish before an enclosing length check. LEN consumes
    a string item and returns an integer; CHR$ consumes a numeric item, applies
    reference SFIX and takes its low byte. Undefined reads and GOSUB sharing
    follow numeric bindings. See the [string contract](../docs/tasks/C003/STRINGS.md).
13. LEFT$/RIGHT$/MID$ expression forms require parentheses. Counts and MID$
    starts use the low byte after reference signed SFIX. LEFT$(s$) removes the
    final byte, RIGHT$(s$) returns the final byte, MID$(s$,0) retains the full
    string, and an optional MID$ count applies LEFT$ to that result. Empty
    results still evaluate explicit count expressions. Further I/O-dependent
    string functions remain unsupported.
14. String =, <>, <, <=, > and >= compare unsigned bytes then prefix lengths,
    including NUL/high bytes. Results are ordinary integer -1/0 and work in
    numeric assignments, arithmetic, Boolean expressions, parentheses, functions,
    PRINT and VDU. Concatenation binds before relations, which bind before
    AND/EOR/OR. Comparisons require parentheses to chain. Invalid type mixing
    is rejected at compile time. See the [slice/comparison contract](../docs/tasks/C003/SLICES.md).

15. VAL consumes a string item and calls the unchanged reference decimal-prefix
    reader, preserving numeric types, suffix/NUL stopping, exponent quirks and
    runtime range errors. STR$ consumes a numeric item and returns unpadded G9
    text; STR$~ uses SFIX then uppercase hex, including eight digits for negative
    integers. ASC consumes a string item and returns integer -1 for empty or
    the first unsigned byte. Parentheses admit expressions. Mutable @% remains
    unsupported. See [conversion contract](../docs/tasks/C003/CONVERSIONS.md).

16. INSTR(main$,sub$[,start]) evaluates its strings then optional numeric
    start, applies SFIX and uses the low byte. Omitted/zero/one start selects
    the beginning. It returns integer 1..255 or zero; empty needle returns zero,
    matching the reference. STRING$(count,s$) evaluates count/SFIX before its
    string, including when count becomes zero. Low-byte repetition is bounded
    at 255 bytes and overflows report String too long. See the
    [search/repetition contract](../docs/tasks/C003/SEARCH-REPEAT.md).

17. LEFT$/RIGHT$/MID$ assignment modifies existing scalar strings without
    resizing, allocation or implicit target creation. Target existence is
    checked before starts/counts and RHS. Counts use SFIX/low bytes; RHS is
    always evaluated. Reference range markers, short-RHS right alignment and
    self-reference are preserved. See [slice assignment](../docs/tasks/C003/SLICE-STORE.md).

18. IF accepts numeric conditions, inline THEN/ELSE colon lists, omitted THEN
    before an inline statement, conventional constant THEN/ELSE line targets,
    and multiline IF THEN / ELSE / ENDIF. Conditions pass through reference SFIX
    then test all four integer bytes. Inline false paths select the first
    unquoted ELSE before REM/end-of-line, including through nested inline IFs;
    executed ELSE skips the remaining line. Block ELSE/ENDIF begin their physical
    statement line; opening a multiline IF inside an inline IF is rejected.
    Inline and multiline nesting each have32 entries. Invalid structures fail
    before output creation. Unselected arms do not execute their binding creation,
    arithmetic or literal-error code.

19. REPEAT/UNTIL and WHILE/ENDWHILE use reference SFIX truth. Numeric FOR
    accepts a scalar numeric variable, TO and optional STEP; NEXT accepts an
    optional variable/list. Initial assignment precedes limit/step evaluation,
    both captured once as five-byte values. The body executes at least once.
    NEXT adds step, applies the destination conversion and compares the full
    updated value against the captured limit (< for negative step, > otherwise).
    A byte variable stores its low byte but that immediate comparison uses the
    full converted result. Explicit zero/fractional steps retain reference behavior.
    Native typed records distinguish FOR, WHILE, REPEAT and GOSUB, with256 total
    entries. Closers check markers before expression evaluation. RETURN requires
    a GOSUB marker, so unfinished loops preserve reference errors. Source blocks
    have32 total lexical nesting levels; mismatched/crossed blocks and unmatched
    NEXT names are rejected. Native jumps use recorded body/test addresses, not
    static shared per-loop limit storage. Arrays/indirect FOR variables remain C005.

20. Line-leading DEF PROC signatures support forward/recursive scalar by-value
    calls,256 definitions and16 arguments. No-argument forms omit parentheses;
    empty lists, RETURN/array parameters and other declaration placements are
    rejected. Formal prior values are saved before actual evaluation; all actuals
    finish before reverse-order binding/conversion. ENDPROC restores recognised
    LOCAL records then requires a distinct PROC marker; RETURN still requires
    GOSUB. Unfinished loop/call markers preserve reference errors.
21. Scalar LOCAL creates zero/empty dynamic bindings and restores prior numeric
    payloads/string descriptors in reverse order. Newly introduced bindings remain
    defined as zero/empty after exit, matching reference VAR creation. Each string
    local owns a fresh255-byte buffer; restoring one never resets the global heap
    or discards non-local assignments. Private records occupy14 numeric or269
    string bytes in a32768-byte bounded LIFO arena beyond emitted code/string
    workspace. PROC/LOCAL/loops/GOSUB share256 typed control records. Pointer reset
    preserves MOS registers; no arena bytes are emitted in the executable.
22. Each DEF PROC starts a branch-label scope extending until the next definition;
    global code before definitions has its own scope. Named and numeric GOTO/GOSUB
    targets must belong to the current scope. Declaration execution skips the
    physical line, preserving inline skipping and multiline body fall-through.
    LOCAL ERROR/DATA and arrays remain clearly unsupported in
    this initial activation scope.

23. DEF FN and =expression provide distinct function activation/results. PROC/FN
    share256 line-leading definitions and16 scalar arguments. Result kinds are
    inferred from actual return expressions and dependencies; unsuffixed string
    returns and optional $ names are admitted (the suffix does not force result
    kind). A unique stable numeric/string kind is required; mixed or unresolved
    kinds are rejected. Calls may be forward/recursive. Caller live numeric/string
    temporary prefixes survive argument/body execution; completed results are
    copied independently before locals and caller temporaries restore. Numeric
    variants retain all five bytes, without an implicit return conversion.
24. FN uses a distinct control marker and matching exit. Result evaluation precedes
    marker validation, preserving errors. PROC/FN/GOSUB/loops are not interchangeable
    exits. Function parameters are implicit dynamic locals with the same staged
    actuals and prior-value snapshots as PROC. The shared private32768-byte arena
    holds caller prefixes and locals; exhaustion is checked.
25. Direct FN string results carry an unqualified interpreter accumulator-pointer
    dependency. Parentheses and omitted LEFT$ preserve it; omitted RIGHT$ and
    STRING$ reject it at compile time. Explicit slices, concatenation and variable
    assignment/reload establish qualified values. The retained reference probes
    show first-byte/stale-tail behavior; the compiler does not silently replace
    those results with intended string operations or emulate interpreter-private RAM.

26. Global arrays, raw DIM and unary/binary memory access follow
    [C005 memory qualification](../docs/tasks/C005/MEMORY.md). Array elements
    retain byte/integer/variant/string widths and row-major bounds. Each bound or
    index is validated before the next expression. Preserve the reference raw-DIM
    target-address seed and repeated-DIM error path. LOCAL/whole arrays, array
    formal parameters and unqualified reentrant DIM-bound expressions are rejected.

27. OPENIN/OPENOUT/OPENUP evaluate one string item and return a MOS byte handle,
    zero on failure. BGET/EOF/CLOSE use # plus an ITEM/SFIX low-byte channel. BGET
    preserves actual MOS EOF/invalid-handle values; EOF is -1 only for MOS result1.
    BPUT evaluates the channel before its RHS; numeric values use SFIX/low-byte,
    strings write their exact bytes and append LF unless followed by semicolon.
    File-using programs close handles on END, fall-through and uncaught exit.
    Direct FN filename carriers are clearly rejected; the reference's stalled
    255-character non-control filename boundary remains unqualified.
28. INPUT LINE accepts one scalar string and an optional adjacent literal prompt.
    Without a prompt it prints `? `. MOS line editing supplies up to255 bytes.
    CRLF precedes storing a successful input; Escape17 leaves the prior value.
    Separators, multiple destinations, numeric/CSV INPUT and INPUT# are rejected.
    [I/O qualification](../docs/tasks/C005/IO.md) owns actual evidence and limits.

29. DATA must lead its physical line. READ supports scalar/array numeric and string
    destinations. It captures the next item before evaluating the destination and
    advances the cursor only after conversion/storage succeeds. Empty fields are
    empty strings or numeric Syntax16; quoted numeric reads give Type6. Numeric
    overflow stays deferred until numeric READ, while string READ retains raw text.
    Leading unquoted spaces are skipped and trailing spaces retained. Numeric READ
    currently requires literal unquoted fields throughout the program; string-only
    READ may consume unquoted text. RESTORE resets or names a constant numbered
    DATA line. Dynamic/non-DATA targets, expressions, LOCAL DATA and READ# remain
    excluded. [DATA qualification](../docs/tasks/C005/DATA.md) owns exact evidence.

## Current backend and runtime contract

1. The compiler owns a 65536-byte output buffer. Code loads at `&040000`, with
   the conventional MOS header at file offset `&40`, version 0, ADL type 1.
   This initial image uses no module services or moslet memory.
2. Absolute addresses and relocations occupy exactly three little-endian
   bytes. The compiler's `%` variables are ordinary 32-bit BASIC integers;
   their use for address calculations does not change the source numeric ABI.
3. Startup preserves AF, BC, DE, IX, IY and a three-byte SP. Exit restores the
   original stack and registers and returns a status in 24-bit HL. The code
   uses the MOS-provided stack, without disabling interrupts or changing MBASE.
4. String literals are immutable byte data, passed inline after a native call
   as an eight-bit length followed by the bytes. The print routine replaces
   its native return address with the address following those bytes and calls
   MOS `RST.LIS &18`. Character output uses `RST.LIS &10`. Empty literals emit
   no call. This is a literal-output representation, not a mutable string ABI.
5. GOSUB loads a target into HL and calls the checked dispatch routine. That
   routine increments an eight-bit depth and jumps to the target; RETURN
   decrements depth and executes RET in the original C001 path. Current C004
   programs use distinct typed GOSUB/PROC/FN records and matching exits, as above.
   Other register values and flags are volatile.
6. Limits are 1024 symbols including runtime symbols and 4096 relocations
   including runtime references. Limit breaches are diagnosed. Relocations
   carry their originating source location.
7. Source and relocations validate before opening the output. A compilation
   error preserves an existing output. An I/O error during the final write can
   leave an incomplete file. Exact identical source/output path strings are
   rejected; path aliases are not canonicalised, so use distinct files.
8. Numeric expressions use the standalone packed numeric runtime in
   `runtime/`. Its 4460-byte template includes the qualified adapter/package,
   literal/unary helpers, formatter/conversion bridges, private 32-byte display
   scratch and 256-byte VAL scratch. Scratch is synchronous and non-reentrant.
   BBC BASIC copies and rebases its 387 internal
   three-byte relocations; these do not occupy the source-fixup array. The
   template is included once per numeric program and omitted otherwise.
   Up to32 five-byte temporary slots are allocated. C004 FN calls preserve live
   numeric/string temporary prefixes in their bounded activation arena.
9. Up to256 shared scalar/array bindings have statically allocated physical payloads
   of one, four or five bytes and separate runtime existence flags. Native byte
   copies move values to/from packed expression temporaries. Writes set existence
   before RHS evaluation; reads check it when executed. The binding/error glue
   is emitted only when needed, outside the numeric template. This
   supports dynamic scalar LOCAL through C004 activation snapshots. Array bindings
   instead contain a three-byte pointer cell; their payloads are heap allocated.
10. Strings use five-byte length/capacity/u24-pointer descriptors and separate
    existence flags. Private 256-byte expression buffers are limited to 16
    simultaneous values; parser nesting shares the numeric 32-entry bound.
    Assignment copies into independently owned contents. A separate 633-byte
    runtime retains the former623-byte core/slices/comparison/search/write prefix
    and adds10 bytes for bounded FN value transfer, with two rebased relocations.
    It adapts reference descriptor/storage conventions with an explicit
    FREE/limit context, capacity reuse, tail growth and geometric non-tail
    growth. Allocation checks precede descriptor/context changes. No interpreter
    globals or parser entries are linked. Failure reports `No room`; length
    overflow reports `String too long`.
11. Without C005 memory facilities, heap workspace starts after the image and reserves1024 bytes per declared
    string binding, without adding file padding. Compilation rejects an end
    above &B0000. Monotone capacities bound abandoned plus live blocks below
    768 bytes per global binding in the original no-deletion tranche. C004 locals
    use private arena buffers. With C005 memory facilities, DIM and strings share
    an explicit heap ending at&AFF00, excluding the32768-byte activation arena
    when present. See the string and C005 memory contracts for ownership.

## Current numeric expression subset

1. Atoms are decimal integer/fraction/scientific literals, uppercase hexadecimal
   literals, TRUE/FALSE and parenthesised expressions. The reference's uppercase
   E exponent reader is used, including missing exponent digits and spaces before
   its optional sign. A decimal point alone reads as zero. Lowercase e is not
   added. EOR remains an operator boundary (`1EOR2`). Unspaced alphabetic text
   after a scientific exponent is rejected as an unsupported tokenisation form.
   Hex uses one to eight uppercase digits and denotes signed 32-bit bit patterns.
   Binary literals remain unsupported; typed scalar/array values, indirection and
   qualified C004 user function calls are admitted.
2. Precedence from tightest is item/unary, ^, * / DIV MOD, + -, comparisons,
   AND, EOR/OR. Binary operators associate left-to-right. In particular,
   `2^3^2=64` and `-2^2=4` follow the reference evaluator. Comparisons accept
   one operator per expression level; parentheses permit nested comparisons.
   Unary signs and NOT are supported. AND/OR do not short-circuit. Shifts and
   unrelated operator extensions are unsupported.
3. Decimal conversion delegates to the bootstrap BBC interpreter's VAL, which
   uses the same CON/NUMBER package as numeric source evaluation. The BBC
   compiler scans the literal boundary and copies the resulting five-byte value,
   preserving reference truncation/scaling, promotion, underflow and exponent
   quirks. Numeric reader errors generate a runtime error at the literal's
   execution point, so an unreachable overflow does not fail compilation or
   execution. No independent exact-decimal converter supplies language values.
   See [literal compatibility](../docs/tasks/C002/LITERALS.md) for the audited
   dependency and direct-source differential evidence. Hex payloads are packed
   bytewise; integer unary minus retains type, including INT_MIN wrap.
4. Standard functions ABS, ACS, ASN, ATN, COS, DEG, EXP, INT, LN, LOG, NOT,
   RAD, SGN, SIN, SQR and TAN consume a numeric item, optionally a parenthesised
   expression, matching the reference's tight function binding. PI is a numeric
   constant. Built-in functions followed immediately by digits are supported
   (for example `SQR16`); no general keyword-crunching compatibility is claimed.
   Functions preserve the tested reference behavior, including integer
   ABS(INT_MIN) wrapping to INT_MIN. INT floors; it is distinct from VDU SFIX
   truncation. Invalid domains propagate the package's numeric error codes.
5. Binary operations use selectors 0..15 of the qualified package. Runtime
   errors report their message and return status 1 through the saved-stack
   exit. VAL/STR$ use separate pointer bridges into the same package; mutable
   format control remains unavailable.
   Parser recursion is capped at 32 entries,
   counting numeric expression frames and all item routines. String expression
   frames retain their earlier accounting and do not charge an extra entry.
   The 16-buffer string limit remains separate. See C002/C003 for evidence.

## Required semantics for subsequent implementation

1. Numeric storage remains four-byte two's-complement integers and five-byte
   BBC floating point. ADL addresses do not justify 24-bit language integers,
   and IEEE single/double is not an acceptable replacement for BBC floats.
   Arithmetic promotion, integer assignment conversion, overflow and signed
   comparisons need differential tests against the reference interpreter.
2. Preserve suffix-based types, unsuffixed numeric variables and mutable,
   length-aware BASIC strings, including empty strings and embedded zero
   bytes. String ownership must survive assignment, recursion and LOCAL.
3. PROC, FN and GOSUB remain distinct language constructs. Runtime activation
   records must distinguish them and enforce their matching exits. A compiled
   function returns a value; a procedure does not silently become a GOSUB.
4. LOCAL must save prior bindings/values, including existence/type and string
   ownership, and restore them in reverse order on return. Recursive calls must
   observe dynamically installed local values as the reference does; simply
   allocating unrelated C-style locals is insufficient. Error unwinding must
    follow the actual reference handler/stack behavior; do not assume that an
    error restores discarded LOCAL records. C005 must qualify that separately.
5. A small adapter boundary hides the numeric package's split register
   representation from callers. C002 defines the qualified packed-value
   pointer ABI in `docs/tasks/C002/ABI.md`; the compiler expression/value-stack
   ABI supports the current VDU expression slice; future activation-safe
   expression storage is still required. String management
   and activation handling need explicit compiled runtimes; interpreter
   parser routines are not stable runtime entry points.
6. Self-hosting acceptance requires interpreting the BBC BASIC compiler to
   produce a native compiler, running that compiler on its own source, then
   repeating and comparing deterministic output. Running a Python translation
   or linking the interpreter as an execution engine does not satisfy this.

Unfinished implementation is tracked only in [TODO.md](../TODO.md).

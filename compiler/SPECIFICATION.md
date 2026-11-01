# Native compiler specification — DRAFT

The current implementation proves the path from BBC BASIC source to a MOS
native executable. Later stages must preserve BBC BASIC values and activation
semantics before broadening the accepted language. This draft describes the
promoted C001 bootstrap in `compiler/compiler.bas`. Experimental numeric code
is separately qualified under C002 and has not enabled language expressions.
Task documents and experimental silos follow
[the accepted task convention](../docs/tasks/README.md).

## Current source language

1. Input is plain byte text with LF, CRLF or CR line endings; final newline is
   optional. Maximum physical line length is 255 bytes. Tokenised `.bbc` input
   and UTF-8 identifiers are unsupported. Diagnostics use physical file line
   and column positions, independent of optional BASIC line numbers.
2. Keywords are uppercase. Names are case-sensitive, begin with an ASCII
   letter or underscore, and contain letters, digits or underscores, with a
   maximum length of 32. Keyword abbreviations are unsupported.
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
   and BASIC's `@%` format variable. Labels share a program-wide namespace in
   this milestone. Later procedure-local labels must not permit branches
   across activation boundaries.
5. `GOTO` and `GOSUB` accept numeric line constants or named labels. Forward
   references are resolved after parsing. Duplicate and undefined labels are
   compile errors. Computed destinations are unsupported.
6. Colon separates statements. A named label may precede a statement on the
   same line. `REM` consumes the rest of the physical line, including colons.
7. `PRINT` accepts string literals separated by semicolons. A final semicolon
   suppresses the newline. Bare `PRINT` emits CR/LF. Doubled quotes represent
   one quote; colon inside a string is data. Commas, print-position formatting,
   numeric output and general expressions are unsupported.
8. `VDU` accepts comma-separated unsigned decimal or uppercase hexadecimal
   byte constants in 0..255. Word forms, negative constants, wrapping and
   expressions are unsupported. `CLS` emits VDU 12.
9. `END` and falling off the source exit to MOS. `RETURN` without GOSUB reports
   `No GOSUB`; nested GOSUB is limited to 255 frames. Runtime failures return
   status 1, success returns status 0. `END` unwinds all outstanding GOSUBs.
10. Unsupported statements and trailing unparsed text are compile errors.
    `EVAL` is deliberately excluded. No compound assignment or other unrelated
    syntax is introduced.

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
   decrements depth and executes RET. PROC/FN are rejected rather than routed
   through this mechanism. Other register values and flags are volatile.
6. Limits are 1024 symbols including runtime symbols and 2048 relocations
   including runtime references. Limit breaches are diagnosed. Relocations
   carry their originating source location.
7. Source and relocations validate before opening the output. A compilation
   error preserves an existing output. An I/O error during the final write can
   leave an incomplete file. Exact identical source/output path strings are
   rejected; path aliases are not canonicalised, so use distinct files.

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
   eventually perform equivalent restoration.
5. A small adapter boundary hides the numeric package's split register
   representation from callers. C002 defines an experimental packed-value
   pointer ABI in `docs/tasks/C002/ABI.md`; the compiler expression/value-stack
   ABI and integration remain unimplemented. String management
   and activation handling need explicit compiled runtimes; interpreter
   parser routines are not stable runtime entry points.
6. Self-hosting acceptance requires interpreting the BBC BASIC compiler to
   produce a native compiler, running that compiler on its own source, then
   repeating and comparing deterministic output. Running a Python translation
   or linking the interpreter as an execution engine does not satisfy this.

Unfinished implementation is tracked only in [TODO.md](../TODO.md).

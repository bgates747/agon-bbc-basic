# Compiler compatibility matrix

This matrix describes the compiler, not the reference interpreter. A feature
is implemented only for the scope stated here. The compiler is not yet
self-hosting and has no variables or mutable-string runtime. Implemented
statuses describe the C001 bootstrap and qualified C002 numeric expressions/output in
`compiler/compiler.bas`. These are development-branch promotions; accepted
testing is still required before promotion to main.

| Feature | Status | Current scope or constraint |
| --- | --- | --- |
| BBC BASIC compiler implementation | Implemented | Numbered BBC BASIC source hosted by BASIC V ADL |
| MOS native executable | Implemented | Direct eZ80 ADL emission, load at &40000 |
| Unnumbered programs | Implemented | Plain-text input |
| Optional line numbers | Partial | Increasing 0..65279; no source sorting or renumbering |
| Named labels | Implemented extension | `@name:`, `GOTO @name`, `GOSUB @name` |
| Conventional GOTO/GOSUB | Partial | Constant targets only; 255 nested GOSUBs |
| RETURN and END | Implemented | Checked return; END restores MOS stack |
| REM and colon statements | Implemented | Quoted colons remain string data |
| PRINT | Partial | Literals and numeric expressions; default G9/initial width 10; semicolon padding/newline rules; no comma zones, TAB/SPC, ~ or mutable @% |
| VDU and CLS | Partial | Numeric byte expressions use SFIX and low-byte wrapping; no word/zero-fill forms |
| 32-bit integer values | Implemented | Exact four-byte temporaries and signed hex bit patterns; no ADL narrowing |
| Numeric literals | Partial | Decimal whole values 0..2^32, at most ten digits; optional zero-only fractional suffix; hex up to eight uppercase digits |
| 40-bit floating-point values | Partial | Five-byte arithmetic/promoted values and whole-valued float literals; general fraction/exponent literals unsupported |
| Arithmetic and conversion | Partial | Binary + - * / ^ DIV MOD, unary signs, package overflow/promotion and VDU SFIX |
| Standard math functions and PI | Implemented subset | ABS ACS ASN ATN COS DEG EXP INT LN LOG NOT RAD SGN SIN SQR TAN, PI; source VAL/STR$, RND and OS functions remain unsupported |
| Numeric formatting | Partial | Fixed G9, matching the reference; @% assignment and other PRINT formats unsupported |
| Comparison and Boolean expressions | Partial | Numeric = <> <= >= < >, NOT/AND/EOR/OR and TRUE/FALSE in VDU/PRINT; no shifts or IF statements |
| Numeric variables | Unsupported | Assignment/storage/bindings remain C003 |
| Mutable strings and string variables | Unsupported | Literal output does not implement assignment |
| Variable suffixes and default numeric variables | Unsupported | Assignment rejected |
| IF/CASE/FOR/WHILE/REPEAT | Unsupported | Structured control flow pending |
| DEF PROC / ENDPROC | Unsupported | Never treated as GOSUB/RETURN |
| DEF FN / function return | Unsupported | Separate activation semantics pending |
| LOCAL, recursion with locals | Unsupported | Save/restore semantics required |
| Arrays and DIM | Unsupported | Including local arrays |
| DATA/READ/RESTORE | Unsupported | Input to compiler may not use these yet |
| File I/O and INPUT in compiled programs | Unsupported | Compiler itself uses host BASIC file I/O |
| Indirection, CALL/USR, inline assembler | Unsupported | Needed bootstrap facilities tracked in TODO |
| Errors/ON ERROR in compiled programs | Unsupported | Built-in GOSUB/numeric errors only; no source error handlers |
| EVAL | Deliberately unsupported | Compile-time rejection; absent from initial language |
| STOP, RUN, CHAIN, OSCLI | Unsupported | STOP is not silently compiled as END |
| Tokenised source, abbreviations, lowercase keywords | Unsupported | No silent tokenisation assumptions |
| Self-compilation | Unsupported | Bootstrap closure and physical qualification pending |

See [the specification](SPECIFICATION.md) for exact limits and
[TODO.md](../TODO.md) for unfinished work.

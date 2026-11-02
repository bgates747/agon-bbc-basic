# Compiler compatibility matrix

This matrix describes the compiler, not the reference interpreter. A feature
is implemented only for the stated scope. C001 output/control flow, C002 numeric
expressions and C003 scalar numeric bindings are promoted in the development
tree. Mutable strings and self-hosting remain unsupported. The Author accepted
the corrected C002 baseline for a development checkpoint; accepted testing is
still required before main promotion. Execution speed is the only intended
observable runtime difference for supported conventional programs. Possible
[interpreter improvements](INTERPRETER-FINDINGS.md) are research only.

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
| 32-bit integer values | Implemented | Exact four-byte payloads and signed hex bit patterns; no ADL narrowing |
| Numeric literals | Partial | Decimal whole/fraction/uppercase E forms within 255-byte source lines; reference reader results/types/errors preserved, including quirks; lowercase e and crunched text after exponents rejected; hex up to eight uppercase digits; binary literals unsupported |
| 40-bit floating-point values | Implemented for numeric expressions | Five-byte literals/arithmetic/promoted values; reference conversion and range behavior; five-byte scalar variants; reader errors occur when executed |
| Arithmetic and conversion | Partial | Binary + - * / ^ DIV MOD, unary signs, package overflow/promotion and VDU SFIX |
| Standard math functions and PI | Implemented subset | ABS ACS ASN ATN COS DEG EXP INT LN LOG NOT RAD SGN SIN SQR TAN, PI; source VAL/STR$, RND and OS functions remain unsupported |
| Numeric formatting | Partial | Fixed G9, matching the reference; @% assignment and other PRINT formats unsupported |
| Comparison and Boolean expressions | Partial | Numeric = <> <= >= < >, NOT/AND/EOR/OR and TRUE/FALSE in VDU/PRINT; no shifts or IF statements |
| Numeric variables | Implemented subset | Plain/LET assignment and reads; five-byte unsuffixed variants, four-byte %, one-byte &; 128 bindings; runtime creation/undefined-read checks, predefined A%–Z%; global GOSUB mutation |
| Mutable strings and string variables | Unsupported | Literal output does not implement assignment |
| Variable suffixes and default numeric variables | Partial | Case-sensitive numeric names and %/& suffixes; 32-character ASCII body limit; ambiguous keyword prefixes, pseudo variables and other suffixes rejected; strings pending |
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

The [C003 scalar record](../docs/tasks/C003/SCALARS.md) describes reference
creation/storage rules, scope and qualification.

See [the specification](SPECIFICATION.md) for exact limits and
[TODO.md](../TODO.md) for unfinished work.

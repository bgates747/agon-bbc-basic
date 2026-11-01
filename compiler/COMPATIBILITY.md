# Compiler compatibility matrix

This matrix describes the compiler, not the reference interpreter. A feature
is implemented only for the scope stated here. The compiler is not yet
self-hosting and has no general numeric or mutable-string runtime. Implemented
statuses describe the tested C001 experiment in `docs/tasks/C001/`; no compiler
source has yet been promoted to the live tree. See [its task record](../docs/tasks/C001.md).

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
| PRINT | Partial | Literals, doubled quotes, semicolons, CR/LF |
| VDU and CLS | Partial | Unsigned byte constants; no word/expression forms |
| 32-bit integer values and variables | Unsupported | No narrowing to ADL width; runtime pending |
| 40-bit floating-point values | Unsupported | Required format retained as design constraint |
| Arithmetic and conversion | Unsupported | No overflow/promotion behavior claimed |
| Comparison and Boolean expressions | Unsupported | Includes numeric IF conditions |
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
| Errors/ON ERROR in compiled programs | Unsupported | Only built-in GOSUB runtime checks |
| EVAL | Deliberately unsupported | Compile-time rejection; absent from initial language |
| STOP, RUN, CHAIN, OSCLI | Unsupported | STOP is not silently compiled as END |
| Tokenised source, abbreviations, lowercase keywords | Unsupported | No silent tokenisation assumptions |
| Self-compilation | Unsupported | Bootstrap closure and physical qualification pending |

See [the specification](SPECIFICATION.md) for exact limits and
[TODO.md](../TODO.md) for unfinished work.

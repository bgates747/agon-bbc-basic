# Compiler compatibility

This describes the bundled compiler and its explicitly stated subset. For supported conventional programs, execution speed is the only intended observable behavioral difference. Automated command comparisons do not establish rendered or human acceptance.

| Feature | Status | Current scope or constraint |
| --- | --- | --- |
| BBC BASIC compiler implementation | Implemented | Numbered BBC BASIC source hosted by BASIC V ADL and its own native compiler |
| MOS native executable | Implemented | Direct eZ80 ADL emission, load at &40000 |
| Unnumbered programs | Implemented | Plain-text input |
| Optional line numbers | Partial | Increasing 0..65279; no source sorting or renumbering. Zero is a compiler label; pinned Agon text loading treats zero as immediate mode |
| Control bytes in source | Partial | Line endings and whitespace tabs supported; quoted bytes below ASCII 32 rejected (use CHR$); reference text-loader normalization pending |
| Named labels | Implemented extension | `@name:`, `GOTO @name`, `GOSUB @name` |
| Conventional GOTO/GOSUB | Partial | Constant targets only; 255 nested GOSUBs |
| RETURN and END | Implemented | Checked return; END restores MOS stack |
| REM and colon statements | Implemented | Quoted colons remain string data |
| PRINT | Partial | Literals, string and numeric expressions; default G9/initial width 10; semicolon padding/newline rules; no comma zones, TAB/SPC, ~ or mutable @% |
| VDU and CLS | Partial | Numeric byte expressions use SFIX and low-byte wrapping; no word/zero-fill forms |
| MODE | Partial | Numeric expression, reference SFIX/low8, VDU22 and acknowledgement wait; inherits MOS/VDP mode support |
| GCOL | Partial | One colour argument (action0) or action,colour; per-argument SFIX and low8 bytes |
| PLOT | Partial | Two coordinates (selector69) or selector,x,y; per-argument SFIX, low8 selector and low16 coordinates; BY and other graphics statements unsupported |
| Numeric GET | Partial | Bare keyboard GET waits and returns unsigned0..255; Escape17 through existing error policy; GET(port), GET#, GET$ and general asynchronous Escape remain unsupported/unqualified |
| 32-bit integer values | Implemented | Exact four-byte payloads and signed hex bit patterns; no ADL narrowing |
| Numeric literals | Partial | Decimal whole/fraction/uppercase E forms within 255-byte source lines; reference reader results/types/errors preserved, including quirks; lowercase e and crunched text after exponents rejected; hex up to eight uppercase digits; binary literals unsupported |
| 40-bit floating-point values | Implemented for numeric expressions | Five-byte literals/arithmetic/promoted values; reference conversion and range behavior; five-byte scalar variants; reader errors occur when executed |
| Arithmetic and conversion | Partial | Binary + - * / ^ DIV MOD, unary signs, package overflow/promotion and VDU SFIX |
| Standard math functions and PI | Implemented subset | ABS ACS ASN ATN COS DEG EXP INT LN LOG NOT RAD SGN SIN SQR TAN, PI; RND and other OS functions remain unsupported |
| Numeric formatting | Partial | Fixed G9, matching the reference; @% assignment and other PRINT formats unsupported |
| Comparison and Boolean expressions | Partial | Numeric and string = <> <= >= < >, numeric NOT/AND/EOR/OR and TRUE/FALSE in expressions, assignments, VDU/PRINT; comparisons return -1/0; no shifts |
| Numeric variables | Implemented subset | Plain/LET assignment and reads; five-byte unsuffixed variants, four-byte %, one-byte &;256 bindings shared with arrays; runtime creation/undefined-read checks, predefined A%–Z%; global GOSUB mutation |
| Mutable strings and string variables | Partial | Plain/LET `$` assignment, owned copying/self-assignment, + and parentheses, 0..255 bytes including NUL, LEN/CHR$/ASC, VAL and STR$ (default G9 or ~ hex), INSTR/STRING$, string PRINT, runtime existence; bounded private heap; LEFT$/RIGHT$/MID$ expressions with reference low-byte counts/optional arguments and six string relations; LEFT$/RIGHT$/MID$ scalar slice assignment with unchanged length/allocation and reference range markers; further I/O-dependent string functions unsupported; omitted RIGHT$ and STRING$ on direct FN-derived carriers rejected (see findings) |
| Variable suffixes and default numeric variables | Partial | Case-sensitive numeric/string names with %/&/$ suffixes; 32-character ASCII body limit; ambiguous keyword prefixes, pseudo variables and other suffixes rejected |
| IF/THEN/ELSE/ENDIF | Partial | Inline colon lists, omitted THEN, constant THEN/ELSE line targets and multiline blocks; SFIX truth and reference first-ELSE association; 32 nesting entries; block ELSE/ENDIF begin their line; multiline IF inside inline IF rejected |
| FOR/WHILE/REPEAT | Partial | Numeric FOR/TO/STEP/NEXT (including named lists), WHILE/ENDWHILE, REPEAT/UNTIL;32 lexical block levels;256 typed loop/GOSUB records; limit/step captured once; FOR enters body once even past limit; mismatched structures rejected |
| CASE | Unsupported | Pending |
| DEF PROC / ENDPROC | Partial | Forward/recursive scalar by-value calls; staged arguments and reverse binding;256 line-leading definitions,16 arguments; unique names within each PROC/FN family (bare and parameterised forms cannot share a stem); no empty parentheses, RETURN/array parameters; ENDPROC requires PROC marker after restoring locals |
| DEF FN / function return | Partial | Forward/recursive scalar functions with a unique inferred numeric/string result kind; unsuffixed string results and optional $ names; saved caller temporaries and distinct FN exit; mixed/unresolved kinds rejected |
| LOCAL, recursion with locals | Partial | Scalar numeric/string LOCAL and implicit parameter locals; dynamically visible, reverse restoration; newly created bindings remain defined;32768-byte arena and shared256 control records; LOCAL ERROR is a no-op; LOCAL DATA/arrays unsupported |
| Arrays and DIM | Partial | Global byte/integer/variant/string arrays,1..16 dimensions and consistent static arity; row-major inclusive counts, SFIX/bounds, zero initialization, owned strings; raw %/variant DIM blocks and reference target mutation/repeated-DIM errors; LOCAL/whole arrays, array formals/FOR/slice targets, byte raw targets, DIM LOCAL and FN/address-of in array bounds rejected |
| DATA/READ/RESTORE | Partial | Leading DATA, literal numbers/quoted strings, string-only unquoted fields, scalar/array READ and bare or constant numbered DATA-line RESTORE; captured field before target evaluation, commit after successful store; numeric READ rejects unquoted nonliteral DATA globally; dynamic/non-DATA targets, DATA expressions, LOCAL DATA and READ# excluded |
| File I/O | Partial | OPENIN/OPENOUT/OPENUP, BGET/EOF/CLOSE and numeric/string BPUT; low-byte handles, binary data, LF/semicolon behavior and cleanup on exit; direct FN filename carriers rejected;255-character non-control paths unqualified; PTR/EXT and other file forms unsupported |
| INPUT | Partial | INPUT LINE with one scalar string and optional literal prompt; actual MOS line editor, ordinary/empty/255-byte input, Escape17; separators, multiple targets, numeric/CSV INPUT and INPUT# unsupported |
| Indirection and address-of | Partial | Unary ?/!/\| (byte/32-bit/five-byte variant), binary numeric base?offset/base!offset, unary ^scalar/element; low24 addresses and ITEM/SFIX precedence; string indirection and array-element binary targets excluded |
| CALL/USR, inline assembler | Unsupported | No interpreter fallback |
| Errors/ON ERROR in compiled programs | Partial | ON ERROR rest-of-line handlers, LOCAL/OFF, LOCAL ERROR no-op, ERROR, REPORT and read-only ERR/ERL; retained handlers and reference discarded-local behavior; numbered ERL quirks and modern ERL0; REPORT token/LF/NUL/startup behavior; held Escape at handler entry; inline-IF installation, multiple handler bodies per line, RESTORE ERROR and direct FN message carriers excluded; general asynchronous Escape and compact built-in-only failure formatting remain unqualified |
| EVAL | Deliberately unsupported | Compile-time rejection; absent from initial language |
| STOP, RUN, CHAIN, OSCLI | Unsupported | STOP is not silently compiled as END |
| Tokenised source, abbreviations, lowercase keywords | Unsupported | No silent tokenisation assumptions |
| Self-compilation | Implemented for qualified source | Exact source70d3c5c6 produces 327205-byte image40e4ae06 from the prior qualified native seed; its fresh native self-build matches completely. Native baseline39, representative12, error39 and18 graphics/key pairs pass. Earlier hardware results describe the prior source/image; this version awaits physical/human results |

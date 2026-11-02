# Bootstrap closure implementation contract

C005 supplies the facilities exercised by the actual compiler source and removes
resource limits that prevent compiling that source. The first self-source probe
stops at the128-definition cap; it is not evidence of self-hosting. Subsequent
work remains bounded by the compatibility matrix and actual BBC reference tests.

1. Raise the shared PROC/FN signature capacity to256, preserving old native output
   and clear bound diagnostics. The pinned source has140 definitions. Re-run the
   self-source probe to reveal the next genuine gap; do not suppress diagnostics.
2. Implement global numeric/string arrays and DIM blocks, byte/word/address
   indirection, with exact32-bit integer/five-byte variant/string-descriptor widths.
   Probe dimensions, indexing, existence, bounds, ownership and LOCAL interactions
   against the pinned interpreter before admitting each form.
3. Implement DATA/READ/RESTORE for the embedded runtime records, plus actual MOS
   file/input paths used by the source. Preserve open/EOF/byte/close behavior and
   error order; Python may prepare fixtures but cannot implement compilation or
   substitute a numeric format.
4. Add the source's ON ERROR, LOCAL ERROR, REPORT, ERR, ERL and custom ERROR paths.
   Extend typed unwind records and preserve prior locals, handler state, caller
   temporaries and native SP. Qualification must cover normal returns and newly
   enabled error recovery, not merely successful input files.
5. Reassess code-buffer/fixup-table memory from actual source/target requirements.
   A two-pass streaming emitter and interned symbol metadata are acceptable
   implementation choices if needed: all validation must precede opening output,
   deterministic native bytes/golden results must remain identical, and all compiler
   logic must stay BBC BASIC. Do not raise large buffers blindly beyond user RAM.
6. String-function transfers currently copy full256-byte private buffers. A
   length-bounded runtime copy may remove unnecessary work during compiler lexing,
   provided maximum/empty data, ownership, unsupported carrier boundaries and all
   existing observable results remain qualified. This changes implementation,
   not the language or the reference oracle.
7. Refine each facility's ABI/test scope before coding, retain experiments here,
   freeze passing inputs, promote exactly and recheck live behavior. C006 remains
   separate until every compiler-source construct maps to an implemented feature.

## Bounded string transfer ABI before implementation

1. Append a copy entry to the unchanged623-byte string runtime prefix. HL points
   to a length-prefixed source, DE to a256-byte destination; buffers are disjoint
   or identical. Copy exactly length+1 bytes, including the header; empty strings
   copy one byte and maximum strings256. Clear all BC bits before forming count.
2. Preserve IX/IY/SP; AF/BC/DE/HL are volatile. Return A0/Z/NC; no allocation or
   descriptor change. Bytes beyond the copied logical value remain untouched.
3. Replace only the compiler's full-buffer FN result transfer with this entry.
   Caller prefix snapshots and ownership stay unchanged. Keep source-carrier
   exclusions; this does not reinterpret stale interpreter RAM or change an oracle.
4. Native ABI probes cover poisoned upper BC, empty/maximum/page crossing, read-only
   source and guards; differential FN/string/PROC behavior and baseline golden must
   pass before exact promotion alongside the required256-definition capacity.

## Return-scan boundary before implementation

1. Reference DATA, like REM, consumes the remaining physical line; its payload is
   not executable FN return syntax. Skip leading DATA/REM lines in the signature
   pass and terminate return collection at either statement outside strings and
   parentheses. This also avoids scanning the compiler's large embedded images.
2. Qualify256 routine definitions, rejection of257, empty/maximum FN strings,
   and DATA containing apparent return text. Preserve actual FN returns before
   DATA and ordinary quoted DATA/REM text. DATA execution remains a later facility.

## Symbol lookup index before implementation

1. The256-routine source produces an18131-byte executable but its interpreted
   qualification spends roughly ten minutes building/resolving labels. The
   current FNsymbol scans every label even after a match; definition and
   relocation work is quadratic. This is a compiler implementation cost.
2. Keep the original symbol/address arrays and insertion order unchanged. Add
   a sorted integer index, binary-search the names through it, and insert each
   new symbol index in order. Duplicate detection and case-sensitive comparisons
   retain their behavior. No source-language semantics or emitted bytes change.
3. Compare the complete256-routine executable with the existing captured output,
   run the baseline assembler golden, duplicate/missing target rejections and
   string/function resource cases. Retain any time-limited earlier attempt as
   partial evidence; a timeout is not successful qualification or a program error.

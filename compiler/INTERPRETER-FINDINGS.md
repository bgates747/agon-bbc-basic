# Possible interpreter improvements

This is a research record, not compiler policy or an upstream submission plan.
The compiler must preserve the pinned reference interpreter's behavior for
supported programs. Findings may support a separately reviewed interpreter
change; no proposal here authorizes changing compiler results.

## Decimal reader precision

1. Reference: repository interpreter baseline
   `2998edd4ceb6030d6840cb4e3d587e75d94dc44c`, `bin/basic.bin` SHA-256
   `a1ae6d381d9861abbc5d87550c683827499d5a8cbe1de49fd9dfa3687382653d`.
   `include/bbc-ez80/MATH.Z80` CON/NUMBER accumulates a bounded unsigned
   significand, discards further digits and applies decimal scaling.
2. Reproduction: compare `4294967296.0` with `2147483648.0*2`, including
   their five-byte records. The reader produces `FAFFFF7F9F` for the first,
   rather than the exact power of two `00000000A0`. The compiler must reproduce
   the reader result for that spelling.
3. The superseded [exact-conversion experiment](../docs/tasks/C002/evidence/literals-001/summary.json)
   retained 104 differences across 174 deliberately stressful fixtures.
   Those include truncation/scaling, range and exponent syntax differences;
   this is neither 104 established bugs nor an ordinary-program failure rate.
   Each candidate needs individual assessment against BBC compatibility and
   the supported grammar before an upstream fix is proposed.
4. The frozen [BBC converter](../docs/tasks/C002/evidence/literals-001/compiler.bas)
   explores exact integer workspace and one rounding decision. It is research
   material, not an approved replacement for the interpreter's assembly reader.
   A future proposal would need an assembly implementation, licensing review,
   differential regressions, resource/performance evidence and an explicit
   compatibility decision. No such upstream change has been made or submitted.

## Exponent syntax and range

1. GETEXP in the same reference accepts uppercase E and counts exponent
   digits with an eight-bit, two-digit path. Long exponents, leading zeroes,
   missing digits and spaces require case-by-case reproduction. A more liberal
   grammar is a language change, not automatically a bug fix.
2. Existing [literal experiment records](../docs/tasks/C002/evidence/literals-001/)
   retain reader bytes/errors and experimental expectations. Those expectations
   do not override reference behavior in compiler qualification.

Unfinished authorized work is tracked only in [TODO.md](../TODO.md).

## Floating-to-integer negative boundary

1. C003's [reference probe](../docs/tasks/C003/evidence/reference-probe-001/README.md)
   records that `n=-2147483648:big%=n` reports `Number too big`, while storing
   the integer bit pattern `n=&80000000:big%=n` succeeds. The distinction passes
   through STORE/SFIX, not merely decimal display formatting.
2. Preserve this behavior in compiled code. Its consistency with the intended
   interpreter conversion range is a candidate for a separately reviewed
   upstream investigation, not an accepted compiler correction.

## String function results and accumulator-pointer consumers

1. Reference remains bin/basic.bin SHA-256
   `a1ae6d381d9861abbc5d87550c683827499d5a8cbe1de49fd9dfa3687382653d`.
   C004's [RIGHT probe](../docs/tasks/C004/functions/right-oracle.bas) returns
   ASC65 for RIGHT$(FNa) where FNa returns "ABC", versus67 with explicit count1.
   Literal, parameter, concatenated, CHR$ and LOCAL-return producers show the same
   first-byte result. Parentheses retain it; adding an empty string restores67.
2. The [STRING probe](../docs/tasks/C004/functions/repeat-oracle.bas) demonstrates
   dependence on prior accumulator contents: after scratch$="123456", STRING$(2,FNa)
   produces "ABC456"; changing scratch$ to "UVWXYZ" changes the trailing bytes
   to "XYZ". STRING$(2,FNa+"") produces "ABCABC". These are actual pinned-BASIC
   results, not proposed replacement oracles.
3. Source inference: EVAL.Z80 RIGHTS/RIGHT1 and STRING/STRIN2 use DE as the string
   accumulator destination. EXEC.Z80 FNEND reconstructs the result length/type
   without explicitly re-establishing the complete accumulator pointer. PUSHS/POPS
   in explicit slices and EXPR3 concatenation re-establish the accumulator path.
   Exact corrupted-write addresses/register lifetimes still require a separate
   interpreter audit; no claim is made that every such program merely selects
   its first byte or that stale tails are deterministic language values.
4. A possible interpreter improvement is to restore the complete string-result
   pointer contract at function return or at these consumers, preserving flags,
   lengths and numeric returns. It needs independent upstream qualification.
   No interpreter source or pinned binary is changed by this finding.
5. Compiler policy: do not silently emit the mathematically intended last byte or
   repeated string for these inputs. Direct FN-derived values through parentheses
   and omitted LEFT$ retain an unqualified-carrier flag; omitted RIGHT$ and STRING$
   reject them at compile time. Assignment/reload, concatenation and explicit
   slices establish qualified values. C004 records tests and this intentional
   partial admission; the compiler does not emulate interpreter-private stale RAM.

## DIM target mutation and reentrant allocation

1. C005's [clean reference observations](../docs/tasks/C005/evidence/array-reference-003/results.json)
   confirm that raw DIM initially stores the target address's low16 bits, with
   integer marker0, before evaluating size. `DIM p% p%` therefore allocates
   `(^p% AND &FFFF)+1` bytes. DIM8's EXX/STOREN path explains this source-level
   dependency; the compiler must preserve it rather than assume the comment's
   intended zero store. DIM3 subsequently writes only the low24 pointer bits,
   preserving a top byte/exponent changed by the size expression.
2. An existing array takes DIM4's VAR path: subscripts evaluate, numeric targets
   are seeded and a missing following size gives Syntax error16. String targets
   give Bad DIM10. A premature native Bad DIM would change effects and error order.
3. [Failed nested-DIM probe](../docs/tasks/C005/evidence/array-reference-002/status.json)
   stalls at `DIM a%(FNinnerdim)` where FNinnerdim itself DIMs that array. The
   controlled180s guard terminates the CLI; this is failed/partial evidence.
   Descriptor allocation against a changing FREE is a source-inferred cause,
   not a proved corruption address. Further upstream repair needs separate
   interpreter work. Initial compiler array-DIM admissions reject FN/address-of
   bound expressions clearly instead of silently assigning new behavior.

## C005 maximum-length filename boundary

Actual OPENIN STRING$(255,"q") stalls through a45s guard in the reference; a
separate255-character variable path stalls through20s. The direct standalone
helper and a page-aligned direct MOS call return within1.016s each. This isolates
a reference/native boundary but does not establish a root cause or authorize an
interpreter change. Retained C005 long-path/reference-stall evidence owns the
observations. The compiler's file admission records this as unqualified; it is
not a faster-open benchmark or an accepted behavioral improvement.

## WHILE condition error-line attribution

1. The pinned reference reports ERL60 for a direct division failure while
   ENDWHILE re-evaluates a WHILE on line40. Replacing part of that condition with
   a normally returning FN yields ERL40 for the later failure. Five actual probes
   are retained in [the loop observations](../docs/tasks/C005/evidence/errors-loop-reference-001/results.json).
2. EXEC.Z80 ENDWH1 calls EXPRI without XEQ updating CURLIN. Normal FN return
   restores caller expression context. This explains the observed difference;
   it is not permission to substitute a more intuitive error line in the compiler.
3. An upstream attribution change could be investigated separately for consistency
   and historical BBC compatibility. The compiler retains both actual outcomes;
   no interpreter change or upstream submission has been made.

## Held Escape during line-input error handling

1. Actual keyboard input terminated by Escape preserves the previous string,
   but a handler on line30 reports ERL30 instead of INPUT LINE's40 in the retained
   [failure observations](../docs/tasks/C005/evidence/errors-escape-attribution-failure-001/reference.log).
   A direct [MOS key-state probe](../docs/tasks/C005/evidence/errors-escape-key-state-001/native.log)
   reads editline1B, ASCII1B and key-down01 immediately after return.
2. agon_os.s OSLINE1 jumps to LTRAP1, clearing the Escape flag while leaving a
   held key observable. XEQ/TRAP can raise Escape again after selecting the
   handler's CURLIN, before its first statement. This is timing-sensitive key
   behavior, not a categorical ERL rule for released keys.
3. Consuming line-editor Escape once, or changing its handler attribution, would
   need separate upstream compatibility review. The native adapter instead polls
   documented MOS state at handler entry and preserves the observed retrigger.
   No interpreter keyboard/FLAGS code has been modified.

## Dynamic-variable first-character chains

1. MAIN.Z80 LOCATE/LOC1 derives the dynamic-variable root from the first name
   character; LOC2/LOC3 then follow links and compare names linearly. The
   compiler's private c-prefixed variables therefore share one host chain.
   This is a source audit, not a measured profile or speedup.
2. C005's isolated `streaming/names.bas` removes that redundant private prefix
   while preserving quoted text, DATA, comments, PROC/FN names and the compiler
   algorithm. Reverse renaming reproduces the original source exactly. Its four-native /
   one-rejection smoke passes54.687s with all four complete old images identical;
   comparable earlier workflow180.881s also includes a source-reader difference.
   These are CLI controller observations, not hardware profiling. This changes compiler implementation names, not
   the interpreter or the variable semantics of compiled programs.
3. A secondary lookup index is a possible separate interpreter improvement. It
   would need evidence that addresses, LOCAL restoration, creation and lookup
   behavior remain intact, plus an actual profile. No interpreter change,
   timing benefit or upstream submission is claimed here.

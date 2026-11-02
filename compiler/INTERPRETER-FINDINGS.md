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

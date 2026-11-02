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

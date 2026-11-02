# Scalar numeric bindings

This C003 tranche adds numeric variables using the reference interpreter's
storage, assignment and existence rules. The compiler remains BBC BASIC and
emits native reads, copies and conversions. Strings, LOCAL and user procedure
activation remain outside this tranche; their semantics are not approximated.

## Reference contract

1. MAIN.Z80 LOCATE/CREATE/TYPE and EXEC.Z80 ASSIGN/STOREN establish separate
   case-sensitive bindings for unsuffixed, `%` and `&` names. Unsuffixed storage
   is a five-byte variant record, `%` is signed four-byte integer storage, and
   `&` is one byte read as unsigned. SFIX handles integer/byte assignment;
   byte assignment stores its low byte. Unsuffixed assignment preserves the
   result's integer/float representation, without forcing SFLOAT.
2. Uppercase A%–Z% exist at zero before assignment. Other admitted variables
   are dynamic: reading before creation reports `No such variable`. ASSIGN
   creates and zeroes a missing target before evaluating its RHS, so `x=x+1`
   succeeds and becomes one. A skipped assignment does not create its target.
3. Assignment accepts plain `name=expression` or `LET name=expression`.
   Existing arithmetic, PRINT, VDU and GOSUB use the same global bindings.
   Evaluation remains in source order. Suffix/case variants have distinct
   bindings. No compound assignment, new operators or implicit declarations
   are introduced.
4. Follow the reference even for surprising conversion failures. In the pinned
   BASIC, `n=-2147483648:big%=n` reports `Number too big`, while the integer
   bit pattern `n=&80000000:big%=n` succeeds. Retain both in qualification;
   a possible interpreter improvement does not authorize changing the compiler.

## Representation and emitted code

1. The compiler records each scalar's exact source name, physical width and
   static/dynamic classification. Each allocated payload has a separate
   one-byte existence flag. Static flags start at one, dynamic flags at zero;
   all payload bytes start at zero. The flag is implementation metadata, not an
   extra numeric byte or a substitute for four-byte BBC integers.
2. Assignments set the target's flag before evaluating the RHS. Since newly
   allocated payloads start at zero and a binding is never deleted in this
   tranche, this preserves CREATE ordering without resetting existing values.
   Integer/byte destinations convert through the existing qualified SFIX
   adapter; successful values copy exactly four/one bytes. Variant destinations
   copy all five bytes unchanged.
3. Reads check the flag at execution time, copy the physical payload into a
   five-byte expression temporary and zero-fill any remaining bytes. The
   compiler emits LD/LDIR byte copies, not ADL-wide numeric field accesses.
   Existing numeric functions consume the same packed temporaries. Every
   absolute address uses the existing three-byte fixup mechanism.
4. The qualified 4028-byte/380-relocation numeric template is unchanged. The
   compiler emits binding data and its undefined-read message outside that
   template, once per program. Nonvariable programs retain their existing
   output bytes. Binding metadata can later participate in explicit LOCAL
   save/restore; this tranche implements no LOCAL or activation stack.

## Boundaries

1. At most 128 scalar bindings (shared with strings) are admitted, subject to existing image,
   symbol, relocation and expression limits. Identifiers have at most 32 body
   characters, begin with an ASCII letter/underscore and contain ASCII letters,
   underscores or digits. The optional numeric suffix is separate from that
   length. Names containing other BBC-accepted punctuation remain unsupported.
2. A BBC-written reserved-word predicate follows the reference keyword table's
   letter-only spellings and its required-boundary markers. Keyword/function
   prefixes that cannot be treated as ordinary identifiers are rejected.
   General keyword crunching, abbreviations, pseudo variables and ambiguous
   keyword-prefix forms are unsupported. Functions are not silently accepted
   as user variable names.
3. Arrays, indirection, extended numeric suffixes, @% and other
   pseudo-variable assignments, PROC/FN/LOCAL and compound assignment remain
   rejected. The later [string core tranche](STRINGS.md) adds `$` bindings,
   ownership, allocation and core operations. Further string functions remain
   C003 work in the sole TODO.

## Qualification

1. `tools/test_scalars.py` reuses the C002 transcript runner with C003-owned
   programs/build outputs. Actual BASIC executes the same conventional source,
   including numeric and undefined-variable errors. The runner resets dynamic
   variables and A%–Z% between reference programs. Named-label/GOSUB fixtures
   exercise the agreed syntax and global mutation. Rejections preserve old
   output, repeat compilation checks determinism, and independent GNU links
   verify every included numeric runtime.
2. `tools/test_storage.py` captures physical reference bytes using BBC address
   indirection, gets native addresses/widths from the BBC compiler's symbol
   metadata, executes the binary, and uses MOS SAVE to retrieve native memory.
   Python only extracts and compares bytes; it does not model BASIC arithmetic.
   The probe checks exact payloads, flags, an unreachable undefined binding,
   and unchanged image bytes outside scalar/expression/saved-stack storage.
3. The first reference probe corrected an incorrectly classified success case
   at the negative integer boundary. A prototype implementation also attempted
   a function return with an active FOR frame; the bootstrap reported `Not in
   a FN`. The corrected predicate completes its loops before returning. These
   failed attempts are retained in task evidence, not counted as passes.
4. These are Pi5 automated qualifications, not human emulator review, physical
   hardware validation or measured performance. Oryx remains unavailable.

## Reproduction

Run sequentially from the project root, using the existing automated profile:

```bash
.venv/bin/python docs/tasks/C003/tools/test_scalars.py \
  --cli /tmp/bbc-compiler-cli-target/release/agon-cli-emulator \
  --compiler compiler/compiler.bas --timeout 300
.venv/bin/python docs/tasks/C003/tools/test_storage.py \
  --cli /tmp/bbc-compiler-cli-target/release/agon-cli-emulator \
  --compiler compiler/compiler.bas
```

The experimental compiler was promoted byte for byte to the single live source.
Historical compiler snapshots remain evidence, not maintained forks.

## Qualification and promotion record

1. [Initial qualification](evidence/scalars-001/summary.json) passes 26
   transcript/rejection programs (14 native executions/12 rejected sources)
   in 169.295 seconds, and 20 raw variable payloads plus undefined-binding and
   image-write checks in 44.231 seconds. Independent links and deterministic
   recompilation pass.
2. The exact tested compiler is promoted to `compiler/compiler.bas`, SHA-256
   `7de07d887b68cd13442474b1c0c4e26668c7054c927b5fc93aa2ff4f00ecbbd7`.
   Runtime DATA, assembly, vendor math and license remain unchanged. Only frozen
   evidence retains historical compiler copies.
3. At the live location, the 39-case/15-execution baseline passes in 47.362
   seconds with the full assembly golden. The expanded scalar suite, including
   the variables example, passes 27 programs (15 native/12 rejected) in 118.424
   seconds. The 20-payload memory qualification passes again in 22.663 seconds.
   These are host qualification durations and show substantial host variation;
   they are not target benchmarks or a measured compiler performance change.
4. The earlier baseline runner's 45-second compile guard expired during normal
   progress. It now accepts an explicit compile-batch budget (180-second
   default), without relaxing output/byte expectations. Rejection fixtures that
   previously rejected scalar assignment/reads now reject still-unsupported
   strings/arrays, since numeric scalar support is intentional.
5. [Live-location evidence](evidence/scalars-promotion-001/summary.json) also
   passes 28 older numeric-output programs (20 native/eight rejected, including
   58 arithmetic observations) in 156.036 seconds and 26 targeted expression
   cases (nine native/17 rejected) in 53.916 seconds. Full program transcripts,
   runtime relocation, deterministic compilation and the baseline assembly
   golden pass. New scalar changes remain uncommitted for Author review;
   mutable strings remain C003 work.
6. The string-core tranche corrects stale metadata on consecutive compilations
   starting with the same variable name. The promoted compiler now passes
   **29 scalar programs** (**17 native/12 rejected**) in **128.957 seconds**,
   with paired same-first-name cases. The numeric template remains unchanged;
   [string live-location evidence](evidence/strings-promotion-001/summary.json)
   records this requalification. Scalar checkpoint approval/push preceded the
   still-uncommitted string tranche.
7. Slicing/comparison integration requalifies the same numeric storage/runtime
   through **29 scalar programs** in **137.337s**. The [new live record](evidence/slices-promotion-001/summary.json)
   includes prior output/precedence regressions and confirms unchanged numeric
   runtime/vendor bytes. String relations produce ordinary four-byte integer
   Boolean payloads with a zero numeric marker in five-byte variant slots.

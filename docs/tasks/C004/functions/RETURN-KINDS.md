# FN return kinds and caller temporaries

The qualified activation tranche adds functions to the PROC/LOCAL
contract. The compiler source requires unsuffixed string-returning functions;
function result type cannot be inferred solely from a name suffix.

1. Prescan function signatures and actual result expressions. Infer string or
   numeric kinds from literals, variable suffixes, standard functions, operators
   and known FN results. Iterate dependencies to a stable result for recursive
   calls with a grounded return. Reject inconsistent mixed-kind returns and
   unresolved kinds clearly; do not force unsuffixed FN results to numeric.
2. Assign a distinct FN control marker. Result expressions execute before marker
   validation, preserving evaluation errors. Restore recognised LOCAL records and
   require FN; a PROC/GOSUB/loop marker is not an interchangeable return address.
3. On FN entry, save the currently live numeric/string temporary prefixes in the
   private LIFO arena before argument evaluation/parameter installation. Record
   pool pointers/counts on that activation. Nested argument calls must preserve
   previous actual values as well as the surrounding expression's pending values.
4. Stage all actuals before parameter stores, retaining the PROC snapshot timing.
   Copy completed function results to an independent numeric/string return buffer
   before restoring locals and caller temporaries. The caller immediately copies
   that result to its new owned temporary slot; subsequent calls may reuse the
   bridge buffer without corrupting earlier results. No numeric conversion is
   introduced merely by returning a numeric variant.
5. Extend the BBC parser's call metadata to handle nested argument compilation,
   keeping PROC and FN names/exits separate. Admission includes forward/recursive
   scalar calls and optional string suffixes; unsupported argument modes remain
   explicit. Labels retain activation scope and declaration fall-through rules.
6. Qualify numeric/string results, unsuffixed string FNs, early returns, recursive
   expressions, swapped arguments, nested calls in later actuals, pending string
   and numeric temporaries, LOCAL restoration, marker/type errors, arena limits,
   deterministic output and previous PROC/loop/conditional/string behavior.
   C004.md records full prototype, supplemental and selected live qualification.

## Reference carrier limitation found during qualification

The full FN comparison exposed an actual reference buffer-pointer dependency for
omitted-count RIGHT$(FNstring) and STRING$(count,FNstring). RIGHT returned the
original first byte; STRING exposed prior accumulator tail bytes. Reproductions
and source inference are retained in compiler/INTERPRETER-FINDINGS.md and the
function oracle fixtures. The failed comparison remains evidence, not a pass.

Compile-time string-value metadata now distinguishes direct FN-derived carriers
from values re-established by assignment/reload, concatenation or explicit slices.
Parentheses and omitted LEFT$ preserve that metadata. Omitted RIGHT$ and STRING$
clearly reject unqualified carriers, including nested forms; the compiler must
not silently replace the reference behavior with intended string operations.

## Promoted evidence and ABI

1. Compiler SHA6feb0b21b09ac4353347876df89043caf8800727b5a8c4f985588c3e6741c8f4
   and783-byte/58-relocation module are promoted exactly. Four DATA packers reproduce
   the source; no maintained FN compiler/runtime fork remains.
2. FN marker7 stores checkpoint2..4, numeric pool5..7/count8, string pool9..11/
   count12. LOCAL marker6 records restore first. The arena reserves5 bytes per
   numeric prefix slot and256 per string slot; zero counts skip copying. Entry/
   leave preserve IX/IY/SP. Transfer buffers are five numeric and256 string bytes.
3. Full28 programs (15 native/13 rejected), five supplemental cases, native/old
   PROC ABI and baseline pass. Selected live checks and three additional string
   consumer/RHS-side-effect programs pass. Exact durations and archives are in
   C004.md and the dated log. Failed/interrupted carrier attempts remain separate.
4. Static kind nesting is bounded32;512 result expressions and128 total PROC/FN
   definitions are admitted. Mixed/unresolved kinds and unqualified string carriers
   are explicit partial-feature rejections, not changed reference oracles.

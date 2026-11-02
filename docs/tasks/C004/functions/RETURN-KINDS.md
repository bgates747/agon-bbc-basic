# FN return kinds and caller temporaries

The next activation tranche will add functions to the qualified PROC/LOCAL
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
   No FN implementation or qualification is claimed by this preparatory contract.

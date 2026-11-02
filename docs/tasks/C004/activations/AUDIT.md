# Procedure, function and LOCAL source audit

PROC/FN require their own call records and reversible dynamic bindings. This
preparatory audit records reference dependencies and design constraints; no
activation implementation or successful qualification is claimed here.

1. EXEC.Z80 FN/PROC/PROC1–5 place distinct FNCHK/PROCHK markers and parse/cache
   definitions through interpreter state. Those entry points cannot be copied
   into a standalone native program. DEF dispatch itself uses REM, so executing
   a declaration skips its physical line; it does not automatically skip all
   following lines through ENDPROC. Native declaration layout must preserve this.
2. SAVLOC saves formal variables before ARGUE evaluates actuals. ARGUE stages
   all actual values on a stack and UNSTAK installs them in reverse order. Its
   explicit comment requires PROCFRED(A,B) / DEF PROCFRED(B,A) to work. Actual
   expressions therefore see original formal values, and argument evaluation
   must finish before parameter stores. Side effects during arguments require
   reference probes to establish snapshot/restoration timing precisely.
3. FNEND and ENDPRO restore recognised LOCAL records until their matching
   FNCHK/PROCHK. RESLOC recognises LOCAL/RETURN/local-array records; FOR, WHILE,
   REPEAT and GOSUB have different markers. Test early exits under every enabled
   marker; do not silently unwind constructs that the reference rejects.
4. LOCAL checks its top marker against FN/PROC/LOCAL/array/RETURN, then SAVLOC
   parses and saves variables and LOCAL2 zeroes them. Ordinary globals remain
   dynamically visible to called routines. Formal parameters are implicit locals.
   VAR can create absent bindings during this process; actual reference probes
   must establish their existence after return rather than assuming deletion.
5. FNEND returns the expression's actual type; the compiler source itself has
   unsuffixed string-returning FNs such as FNpeek/FNname. Do not infer the return
   type solely from a dollar suffix. A planned initial static return-kind pass
   may reject genuinely mixed numeric/string returns clearly, but it must infer
   every compiler-source FN and support recursion with a known return kind.
6. Caller numeric/string temporary values must survive nested FN/PROC calls.
   Save the live prefixes captured at each call site, not only scalar locals.
   Captured argument values must likewise survive later argument calls. Return
   results need independent storage until binding/temporary restoration finishes.
7. A private LIFO activation arena can hold prior binding bytes, existence,
   saved temporary prefixes and fresh255-byte LOCAL string capacities. Fresh
   owned buffers avoid rollback of non-local heap changes. Bound and initialise
   each record before use; check workspace limits and every unwind path. The
   loop control stack can gain distinct PROC/FN/LOCAL markers; GOSUB returns
   remain separate. No experimental global heap reset may discard global writes.
8. Scalar by-value arguments and LOCAL are first; RETURN parameters, whole-array
   arguments, LOCAL DATA/ERROR and error unwinding require explicit qualification
   before admission. Array/I/O/error facilities needed by self-compilation remain
   C005; the sole TODO continues to own unfinished work.

## Actual BASIC probe results

The authorized Pi5 probes confirm staged/swapped arguments, prior formal snapshot
before argument side effects, unsuffixed recursive string returns, dynamic LOCAL
visibility and reverse restoration. Newly LOCAL-created bindings remain defined
with zero/empty values after return; they are not deleted. Repeated LOCAL zeroes
the current value and finally restores the original. LOCAL under a FOR reports
"Not in a FN or PROC". Further exact error/declaration results are retained in
oracles.json and individual source/transcript files.

ENDPROC under FOR reports "Not in a PROC" and function result under FOR reports
"Not in a FN". Top-level LOCAL and =result produce the same corresponding
errors. Inline declaration skips its whole physical line; multiline declaration
falls through into its following body and reports "Not in a PROC" at ENDPROC.
These probes support the source audit; implementations must preserve the results.

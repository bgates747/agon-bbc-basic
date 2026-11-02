# DATA, READ and RESTORE implementation contract

The compiler's embedded runtimes are ordinary BBC DATA records. This tranche
must consume them through native READ/RESTORE code with the same numeric values
and string contents; Python must neither parse programs nor implement READ.

## Reference audit

1. EXEC.Z80 DSRCH/SEARCH looks for DATA at the beginning of a physical program
   line. DATA execution skips the remaining line. READ0 gets the next record
   before VAR resolves/evaluates its destination, so exhausted DATA wins over
   destination/index side effects. READ2 updates DATPTR only after successful
   conversion and storage. An error must not prematurely consume a record.
2. Numeric READ calls EXPRN on the DATA text, then STOREN. String READ uses
   FETCHS/XTRACT: leading spaces are skipped; unquoted text extends to comma/CR,
   preserving trailing spaces; quoted text uses CONS. Numeric text read into a
   string remains text. A quoted string read numerically gives Type mismatch.
   Probe empty fields, quoting and exact terminator behavior before admission.
3. RESTORE without target restarts DATA. A conventional numeric target is found
   as a program line before DSRCH; RESTORE +n/DATA/ERROR/LOCAL has separate
   interpreter machinery and is outside initial DATA admissions.

## Initial native scope before implementation

1. Admit physical-line-leading DATA with literal numeric fields and quoted or
   unquoted string fields. Initial RESTORE accepts bare reset or a constant
   numbered DATA-line target, covering all compiler runtime loaders. Reject
   nonleading DATA, unsupported numeric expressions and other RESTORE forms
   clearly; no EVAL/interpreter fallback is allowed.
2. A program with numeric READ and unquoted nonliteral fields requires an
   explicit conservative rejection until numeric DATA expression semantics are
   qualified. String-only READ may retain such fields as text. Mixed quoted
   strings and numeric literals are required by the actual compiler source.
3. Reuse the qualified literal conversion/packed representation. Preserve a
   deferred numeric error for a field that overflows: DATA declaration or a
   string read must not eagerly raise its numeric conversion error. Preserve
   32-bit integer versus five-byte numeric storage and SFIX at the destination.
4. Encode private records with raw string bytes, numeric-kind/error metadata
   and a five-byte numeric value. A bounded length determines the next record;
   avoid a relocation per DATA item. Keep an explicit cursor/end context and
   reset it at program entry. Constant RESTORE targets map to record offsets.
5. Capture the selected record before evaluating a READ destination. Scalar and
   array numeric/string stores are required; commit the captured record's next
   pointer only after successful conversion/storage. Nested destination calls
   must not replace that captured record with their own READ/RESTORE cursor.
6. Probe source-order, type/conversion/overflow/error ordering, restore targets,
   empty/maximal text, repeated reads, nested calls and byte-exact runtime loader
   records. Independently inspect/link the helper and recheck existing suites.
   No DATA syntax or self-hosting claim follows from this design document.

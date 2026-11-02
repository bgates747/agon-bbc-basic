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

## First actual observations

`data-reference-001` passes18 cases in1.606s. Empty/blank/trailing string fields
are empty; empty numeric fields give Syntax16, quoted numeric gives Type6. Leading
spaces are removed and unquoted trailing spaces retained. Doubled quotes and
quoted comma/colon survive. Numeric DATA expressions really evaluate; initial
literal-only admission must reject them clearly. Nonleading DATA is not searched.
RESTORE may target an existing non-DATA line and finds its next DATA, but the
initial constant DATA-line admission can remain narrower and explicit. Exhaustion
raises42 before destination effects; nested destination READ commits the captured
outer next pointer. Conversion/store failure leaves the field for retry. Numeric
overflow text reads as a string without error. Trailing junk after quoted fields
and numeric colon terminators have parser quirks; reject those unqualified forms.

## Frontend qualification history

The1962-line BBC prototype SHA55643c54bbbff7c0d36f139cad2e9824cec5e36a7078e9f7274b30ebf2d7b8fa
passes two generated smoke programs170.554s, with typed scalar/array values,
strings, literal records, RESTORE, repeat and numeric/string/PIC DATA identity.
The first shared reference fixture omitted RESTORE (CLEAR
keeps DATPTR); the next success fixture incorrectly expected decimal signed-min
integer READ to succeed. A stepped reference gives20 at that first READ. The
success boundary uses &80000000; decimal -2147483648 is retained as an error case.
The mixed-data fixture also needed to respect the declared conservative admission:
quote nonnumeric text when the program has numeric READ. Retain all failed fixture
records rather than altering observed reference results or the numeric package.

The full32-source controller exits143 after22 native images and10 expected
rejections, before fresh repeat/native execution reporting. The cause is unknown;
a native owned-process check finds no remaining CLI. `resume_data.py` verifies
exact compiler definitions/DATA against the retained driver and every source,
status/image or rejection sentinel before resuming only the missing repeat,
execution and independent link/entry phases. The partial archive is not a pass.

## Qualified development promotion

Exact SHA55643c54 passes the32-source scope:22 native/10 rejected,19 shared reference
oracles plus3 independent exhaustion cases. A shared EOF fixture had consumed the
following case's DATA; isolated runs prove Out of DATA for no fields, one missing
field and exhaustion before FN index effects. `data-shared-eof-fixture-001` retains
the wrong shared expectation; `data-exhaustion-reference-001` supplies the actual
three oracles in1.016s. No compiler source/numeric runtime change corrected them.

The verified fresh repeat matches p0 byte for byte. All22 native outputs and
NUM/string/memory/control/activation links, bridges, arena and DATA cursor-entry
reset checks pass. `data-001` retains resumed completion. Its3.477s measures only
the final resume validation/execution/link phase; interrupted compilation and the
earlier fresh repeat are excluded. It is not a32-program compile duration.

Baseline39/15/repeat/GNU golden passes80.355s. Exact live smoke2 passes170.183s
with PIC template and entry/memory checks; all seven packers reproduce the source.
Promotion copies the unchanged source to compiler/compiler.bas, the120-byte/no-
relocation helper to compiler/runtime/data.s and its packer to compiler/tools.
Numeric/vendor and earlier runtime sources are unchanged. Source handlers, native
compiler resource closure and C006 remain open; this is not self-hosting, human
review, hardware or benchmark evidence.

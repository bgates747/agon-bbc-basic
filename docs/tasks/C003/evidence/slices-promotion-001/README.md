# Live slicing and comparison qualification

The promoted compiler is exactly the prototype source qualified by the full
36-program suite in ../slices-001. At the live path, selected mixed integration,
raw contents/guards and both native ABI probes pass, together with the prior
baseline, string, limits, scalar, output and numeric-expression suites.

A focused final program checks unparenthesised quoted-literal PRINT relations,
field widths, concatenation precedence, numeric-function input and a slice whose
count reads the original assignment target. It passes against BASIC and is now
the 37th program in the full maintained test_slices.py suite. The earlier full
36-program result remains a prototype result; it is not relabelled as a full
live 37-program run. See summary.json for exact scopes and host durations.

The numeric output suite initially stopped on an obsolete diagnostic expectation
for invalid ABS("x"). It correctly rejected the string input. Only that message
expectation changed; no valid output or compiler/runtime code changed. The
failed attempt remains separately under slices-output-fixture-debug-001.
The two archived qualification drivers record the original sequence and its
remaining jobs; all selected successful reports are copied before shared build
locations are reused. No accepted run is duplicated in the counts.

Source/tool snapshots, reports, logs and byte snapshots are covered by the
manifest. Binary snapshots use .dat without changing bytes; JSON retains
original build paths. Numeric library/vendor/license and the old string core
are unchanged. No Oryx, graphical/hardware review or benchmark is claimed.
New tranche work remains uncommitted for review; HEAD/upstream are be0f299 and
main remains the interpreter baseline.

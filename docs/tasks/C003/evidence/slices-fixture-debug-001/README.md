# Unsupported-target diagnostic fixture correction

All accepted programs compiled, but the suite stopped before execution because
its first unsupported slice-assignment target expected the wrong diagnostic.
The compiler correctly rejected it as `Unsupported string item LEFT`; corrected
the fixture to match that existing reserved-name diagnostic. This incomplete
run is not counted as native qualification. Before repeating, retained the
existing string-specific recursion accounting in the unified parser and added
a deep, previously admitted string-expression case.

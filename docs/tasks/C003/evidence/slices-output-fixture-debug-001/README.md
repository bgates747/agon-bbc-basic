# Numeric-output type-error diagnostic fixture correction

The output suite stopped before native execution on the invalid source
`PRINT ABS("x")`. The typed parser correctly rejected a string passed to a
numeric function, with `String value used as a numeric item`; the older fixture
expected `Expected a numeric item`. Updated that one diagnostic expectation.
No compiler, numeric runtime, valid-program output or oracle value changed.
The incomplete run is not counted as a pass.

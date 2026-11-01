# Whole-literal reader observation

The expression oracle reproduced the previously recorded 2^32 constant-reader
discrepancy without a decimal point. This is source-reader behavior, not an
arithmetic-package change. The retained reference source identifies the exact
observation; this directory is not a passing qualification fixture.

1. Reference interpreter binary SHA-256:
   `a1ae6d381d9861abbc5d87550c683827499d5a8cbe1de49fd9dfa3687382653d`.
2. In the first integration-oracle run, zero-based case 42 evaluated
   `65-((4294967296)=(2147483648.0*2))` to byte **65**, indicating unequal values.
   The independently expected result was **66**. The assertion retained in the
   tool output was `AssertionError: (42, ... , 65)`. The run stopped before
   copying the full oracle byte file into the build evidence directory; no
   complete raw byte fixture is claimed here.
3. `reference.bas` is the exact original generated source from that failed
   setup. Earlier C002 `precision-fixture-001` separately preserves packed-byte
   observations for the `.0` form.
4. Integration cases now use exact multiplication construction in the reference
   for the two affected compiler literals, with an explicit
   `intentional_reference_literal_correction` marker. The compiler's new digit
   accumulator handles the whole and `.0` forms exactly within its stated
   literal subset. It does not claim general decimal-fraction correctness.

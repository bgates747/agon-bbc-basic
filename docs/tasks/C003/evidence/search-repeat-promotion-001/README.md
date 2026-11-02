# Live search/repetition qualification

The live compiler/runtime match the fully qualified prototype byte for byte.
Selected live checks and existing string/numeric regressions pass; summary.json
indexes exact scopes, hashes and durations. The full 30-program prototype suite
is in ../search-repeat-001 and is not claimed as a full live rerun.

1. qualification-driver.py completed baseline, mixed example, ABI and storage,
   then met stale VAL/STR$ rejection fixtures. The failed expectation check is
   retained separately in ../search-repeat-string-fixture-debug-001.
2. qualification-driver-finish.py began corrected tests, was interrupted at
   the Author's initial request, then reran successfully after reauthorization.
   The interruption is retained separately in ../search-repeat-deferred-001.
   All subsequent suites in the finish driver completed on resumption.
3. Native ABI checks cover original core, slices and new search/repetition;
   typed outputs, memory/ownership, limits and 12 expressions pass. Source/tool/
   runtime snapshots and manifest preserve the artifacts. Actual graphical/
   hardware testing and benchmark measurements are not claimed. The Author
   waived earlier approval stops for the remaining project work.

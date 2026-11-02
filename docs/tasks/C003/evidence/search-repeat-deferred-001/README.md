# Emulator validation deferred at the Author's request

The Author prohibited further emulator work on the Pi5 for the night. The
corrected older-string regression was interrupted with SIGINT (exit 130);
no emulator or graphical instance was subsequently launched. The CLI harness
uses owned-process cleanup on interruption. This is not a failed semantic
comparison or a passing regression run.

1. The full 30-program prototype, native ABI, raw storage and baseline passed
   before this restriction. Selected live baseline, mixed example, ABI and
   raw storage also passed. Their evidence is indexed separately.
2. The older string suite had stale VAL/STR$ rejection expectations. Its first
   attempt is retained under search-repeat-string-fixture-debug-001. The
   corrected 23-program suite (16 native/7 rejected) is not yet qualified.
3. Remaining live emulator checks are deferred: corrected string suite, selected
   slices, string limits, core/slice ABI, conversion smoke and 12 expressions.
   They are tracked under C003 in the sole TODO. Static checks may proceed.

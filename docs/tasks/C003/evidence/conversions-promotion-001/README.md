# Live conversion qualification

The live compiler and runtime match the fully qualified prototype byte for byte.
These selected live checks confirm integration and prior numeric behavior; the
full 29-program conversion suite is retained in ../conversions-001, not repeated
here. summary.json and static-results.json index exact scopes, hashes and times.

1. qualification-driver.py ran baseline, conversion example, native ABI,
   raw-memory probe, mixed slices, string limits, numeric ABI and formatter.
   Its numeric-output step encountered the old 180-second guard; that attempt
   is retained separately in ../conversions-output-timeout-debug-001.
2. qualification-driver-finish.py reran numeric output with --timeout 360 and
   completed 12 expression cases, then froze the final inputs and runtime data.
   The shared output runner now defaults to 360 based on observed durations.
   Compiler/runtime bytes did not change for this repeat.
3. static-checks.py verifies promotion, DATA, hashes, source limits, document/
   tool formats, prior manifests, stageable evidence and unchanged Git state.
   manifest.json hashes every retained member; generated caches are excluded.
4. All CLI sessions ended through the harness's owned-process cleanup. This
   evidence is automated Pi5 qualification, not graphical/hardware acceptance,
   a performance benchmark, permission to commit, or acceptance for main.

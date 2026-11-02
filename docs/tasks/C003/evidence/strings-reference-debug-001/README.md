# Overlong reference fixtures

The first full suite put two long literals on one source line, exceeding the
BBC program-record limit. BASIC reported `Bad program` before execution. The
owned emulator run was explicitly cancelled by moving its log, causing the
harness finally block to stop it. The fixtures now use separate source lines.
No compiled-program result from this attempt was accepted.

# Relative runtime report-path correction

The original PROC ABI probe returned native status0 against the extended FN runtime, then report generation rejected a relative --runtime path. The tool now resolves supplied paths before recording hashes; repeat the probe before treating the complete run as qualified. This is not a runtime failure or a claimed full pass.

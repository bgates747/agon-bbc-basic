# Superseded ABI fixture

The first direct probe passed its checks through the final character output,
but failed to preserve MOS caller registers around the entire probe. Returning
to MOS caused repeated restarts and an invalid return code. This was a probe
entry/exit bug, not an accepted runtime result. The corrected probe saves and
restores the same caller registers as generated programs and passes in 1.016s.
The saved source and native log preserve the failing run.

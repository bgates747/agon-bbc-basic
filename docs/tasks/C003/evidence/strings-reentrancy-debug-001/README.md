# Consecutive compilation stale binding

FNvariable used a FOR loop from zero to cvnum%-1. At cvnum%=0 BBC still runs
the body once, comparing a stale name from the previous compilation. Matching
that first name returned an unregistered binding, producing undefined $bind0.
A fresh one-program probe succeeds, confirming dependence on prior state.
The corrected WHILE search honors an empty binding table. Numeric and string
suites gain consecutive programs with the same first name. This also fixes
the scalar baseline; it is a compiler correction, not a BBC semantic change.

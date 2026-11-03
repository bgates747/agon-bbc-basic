Manual tests: sources/oracles copied from completed C006 qualification.
No manual Console8 pass is claimed by staging.

00-smoke
01-numeric
02-loops
03-functions
04-local
05-arrays
06-indirection
07-data
08-files
09-errors
10-undefined-label
11-eval-rejected

Follow each subdirectory readme. For numeric/array checks compare exact
text, including scientific notation. Source errors intentionally test
the reference LOCAL/handler behavior, not an improved error unwind.
The compiler reports no intermediate progress. Hardware timing is not
qualified per case; use the following prior aggregate only as context:
R01 automated remaining19 compile/run stages took506.254 host seconds,
including transfers/keyboard/listener overhead. This is not CPU time
or a promised Console8 duration. Wait for Wrote and actual MOS return.
If a small compile/run remains unclear after several minutes, retain
the observed state/error and report it; do not mark the case passed.

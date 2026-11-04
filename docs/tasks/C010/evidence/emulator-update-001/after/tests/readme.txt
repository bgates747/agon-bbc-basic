Manual tests: previously qualified sources and expected outputs.
Copying this package does not establish a test pass on your machine.

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
qualified per case. Wait for Wrote and actual MOS return.
If a small compile/run remains unclear after several minutes, retain
the observed state/error and report it; do not mark the case passed.

12-mandelbrot: follow native-readme.txt in that directory.
Command parity is qualified; rendered/human acceptance remains pending.

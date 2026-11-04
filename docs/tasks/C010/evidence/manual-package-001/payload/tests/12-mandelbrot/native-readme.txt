Unchanged Mandelbrot by P. Mainwaring, March1990 (see source comments).
Automated native/reference graphics commands match for the complete program.
Rendered/human and physical results for this compiler version are pending.

Start at the package root. To run the supplied native program:
  LOAD tests/12-mandelbrot/mandelbrot-c010.bin
  RUN .

Expected: MODE8, the Mandelbrot drawing in four passes, then a key wait.
Press Space when the drawing is complete. MODE1 is restored and MOS returns.
Compare the drawing with the same source under the reference interpreter.
Do not press Escape as a completion key; it intentionally raises Escape.

To compile it yourself, start at the package root:
  LOAD compiler.bin
  CD tests/12-mandelbrot
  RUN .
Enter mandelbrot.bas, then a fresh destination such as built-c010.bin.
Wait for Wrote and actual return to MOS, then:
  LOAD built-c010.bin
  RUN .
Use CD ../.. to return to the package root afterward.

Record the compiler hash/version, observed drawing, key wait, final mode
and return. No elapsed-time or performance acceptance is implied.

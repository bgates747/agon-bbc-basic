03-functions

Start in the package root. At MOS:
  LOAD compiler.bin
  CD tests/03-functions
  RUN .

At Source file: enter source.bas
At Output file: enter built.bin
Wait for Wrote built.bin and return to MOS, then:
  LOAD built.bin
  RUN .

Expected program output:
15:7

The program must return to MOS.
Read expected.txt without saving if comparing onscreen.

No intermediate compiler progress is printed. Compare visible output
and actual return, not just a delivered command. See ../readme.txt
for duration/observation limits. No automatic timing/pass assertion.
After finishing, CD ../.. returns from this test to the package root.

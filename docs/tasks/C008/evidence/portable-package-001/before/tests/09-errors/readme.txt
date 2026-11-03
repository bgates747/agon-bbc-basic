09-errors

At MOS:
  CD /mystuff/basic-compiled/tests/09-errors
  LOAD /mystuff/basic-compiled/compiler.bin
  RUN .

At Source file: enter source.bas
At Output file: enter built.bin
Wait for Wrote built.bin and return to MOS, then:
  LOAD built.bin
  RUN .

Expected program output:
100:100:99
recovery

The program must return to MOS.
Read expected.txt without saving if comparing onscreen.
The recovery diagnostic is intentional.100:100:99 preserves
the reference handler/LOCAL state; recovery is its error text.

No intermediate compiler progress is printed. Compare visible output
and actual return, not just a delivered command. See ../readme.txt
for duration/observation limits. No automatic timing/pass assertion.

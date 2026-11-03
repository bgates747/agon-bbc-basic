05-arrays

At MOS:
  CD /mystuff/basic-compiled/tests/05-arrays
  LOAD /mystuff/basic-compiled/compiler.bin
  RUN .

At Source file: enter source.bas
At Output file: enter built.bin
Wait for Wrote built.bin and return to MOS, then:
  LOAD built.bin
  RUN .

Expected program output:
2.14748365E9:array

The program must return to MOS.
Read expected.txt without saving if comparing onscreen.

No intermediate compiler progress is printed. Compare visible output
and actual return, not just a delivered command. See ../readme.txt
for duration/observation limits. No automatic timing/pass assertion.

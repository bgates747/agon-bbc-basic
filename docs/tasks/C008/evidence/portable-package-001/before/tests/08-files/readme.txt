08-files

At MOS:
  CD /mystuff/basic-compiled/tests/08-files
  LOAD /mystuff/basic-compiled/compiler.bin
  RUN .

At Source file: enter source.bas
At Output file: enter built.bin
Wait for Wrote built.bin and return to MOS, then:
  LOAD built.bin
  RUN .

Expected program output:
255:116:0

The program must return to MOS.
Read expected.txt without saving if comparing onscreen.
The program creates/overwrites only native-test.dat in this directory.
Its exact five expected bytes are FF 74 65 78 74.

No intermediate compiler progress is printed. Compare visible output
and actual return, not just a delivered command. See ../readme.txt
for duration/observation limits. No automatic timing/pass assertion.

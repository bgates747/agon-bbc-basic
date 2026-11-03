11-eval-rejected

At MOS:
  CD /mystuff/basic-compiled/tests/11-eval-rejected
  LOAD /mystuff/basic-compiled/compiler.bin
  RUN .

At Source file: enter source.bas
At Output file: enter preserve.dat

Expected diagnostic contains:
EVAL is deliberately unsupported

There must be no Wrote message. Return to MOS is expected.
The existing42-byte preserve.dat must remain unchanged:
Native rejection preserves previous output
It is text, not an executable. Do not LOAD/RUN it.
Inspect it with the bundled editor without saving, or
compare bytes from Oryx after the card is mounted there.

No intermediate compiler progress is printed. Compare visible output
and actual return, not just a delivered command. See ../readme.txt
for duration/observation limits. No automatic timing/pass assertion.

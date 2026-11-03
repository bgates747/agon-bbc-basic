10-undefined-label

Start in the package root. At MOS:
  LOAD compiler.bin
  CD tests/10-undefined-label
  RUN .

At Source file: enter source.bas
At Output file: enter preserve.dat

Expected diagnostic contains:
Undefined target @missing

There must be no Wrote message. Return to MOS is expected.
The existing42-byte preserve.dat must remain unchanged:
Native rejection preserves previous output
It is text, not an executable. Do not LOAD/RUN it.
Inspect it with the bundled editor without saving, or
compare bytes on your computer with the card mounted.

No intermediate compiler progress is printed. Compare visible output
and actual return, not just a delivered command. See ../readme.txt
for duration/observation limits. No automatic timing/pass assertion.
After finishing, CD ../.. returns from this test to the package root.

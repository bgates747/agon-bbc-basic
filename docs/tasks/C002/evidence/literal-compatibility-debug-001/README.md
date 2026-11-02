# Compatibility correction: diagnostic mismatch

The first direct-source run matched 53 packed values and five reference reader
errors, but native error text said `Too big` while actual REPORT$ said
`Number too big`. The arithmetic package comments had been mistaken for the
interpreter message table. This run failed compatibility qualification.
The correction also audits the other numeric messages against MAIN.Z80 and
actual reference errors; no mismatch in this record is accepted as a pass.

# Initial literal experiment failure

The first prototype failed six of its first twelve packed-value checks. These
files preserve that failed compiler and observed case records, not qualified
source or a second maintained implementation.

1. A nested single-line IF/ELSE in the workspace carry append did not implement
   the intended inner conditional. It appended zero limbs without a carry,
   breaking normalised lengths and subsequent comparisons. Examples included
   `1.0` becoming packed `0000004080` and `0.1` becoming `0000000081`.
2. Replaced that statement with a separate carry procedure using an early
   guard. The same twelve cases then passed packed-byte/native-output checks,
   independent runtime linking and repeat compilation in 18.689 seconds.
3. A later harness setup exceeded the reference interpreter's own source-line
   limit when quoting a long source literal inside a wrapper. Split reader
   strings into short concatenated lines. This was oracle setup, not a
   mathematical/compiler correction. No passing report is claimed for that
   interrupted setup; final qualification reruns the affected batch.
4. Probing a reader overflow also exposed an oracle error-handler mistake:
   LOCAL ERROR saved the handler, but a returning procedure needed ON ERROR
   LOCAL to restore its procedure frame. Adopted the established repository
   conformance-test pattern and reran the affected cases. Neither issue altered
   the reference interpreter or numeric runtime.
5. The reference tokenizer rejected the exploratory crunched form `1E2EOR1`
   after printing 100. Retained that source/log, then used conventional spaces
   after scientific literals in word-operator comparisons. Ordinary `1EOR2`,
   `1.EOR2` and `1.0EOR2` remain direct source-compatible tests. No general
   keyword-crunching compatibility is claimed.

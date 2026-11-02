# Superseded limit fixture order

Both limit diagnostics compiled as expected and the example compiled. The
shared output harness repeats the first program to check determinism, so a
rejected first fixture compared its preserved sentinel against an executable
from a prior run. Reordered the successful example first, then repeated this
small batch. No compiler or runtime change was needed; this failed harness
assertion is not a passing execution result.

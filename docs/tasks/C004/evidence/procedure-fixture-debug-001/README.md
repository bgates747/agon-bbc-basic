# Procedure fixture scope correction

The first native fixture tried a global GOTO to a label physically in a procedure
scope after DEF PROC. Compilation correctly rejected the cross-scope target.
The corrected fixture terminates its main program with END and packages its
identical procedure body separately in the reference oracle, allowing the host
reference harness to print its completion marker. No compiler source changed.
This failed fixture is not counted as a qualification pass.

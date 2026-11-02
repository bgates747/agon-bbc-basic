# Reference suite isolation correction

The constants-only C002 runner reused one BASIC variable namespace between
reference programs. A later `fresh=fresh+1` observed an earlier case and printed
2, while a freshly loaded native program correctly printed 1. The C003 runner
now explicitly clears dynamic variables and zeroes A%–Z% before each reference
program. The source under test is unchanged. This run is not a passing report.

# Expanded compiler baseline timeout

The old 45-second compile guard expired after case 26 with normal progress and
expected diagnostics. The expanded BBC compiler needs a longer qualification
budget. The runner now accepts an explicit compile timeout; no target behavior
or acceptance expectation is relaxed. Compiler hash is the qualified
`7de07d887b68cd13442474b1c0c4e26668c7054c927b5fc93aa2ff4f00ecbbd7`.

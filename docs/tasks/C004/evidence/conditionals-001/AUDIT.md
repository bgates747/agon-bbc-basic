# Conditional reference and native design

Conditional code uses the reference's integer conversion and branch selection.
The reference-only oracle confirms that an outer false inline IF selects the
first ELSE even when it textually belongs to another IF. This behavior is
preserved rather than replaced with another language's dangling-ELSE rules.

1. `include/bbc-ez80/EXEC.Z80` IF/IFNOT/IFTHEN/MELSE establish the paths.
   EXPRI invokes SFIX then TEST examines all four integer bytes: positive and
   negative fractions between -1 and 1 are false; out-of-range conversion errors
   still occur. The compiler calls the qualified selector38 then ORs four bytes.
2. Inline false branches select the first unquoted ELSE before REM/end-of-line.
   True execution encountering ELSE skips the remainder of that physical line.
   Colon-separated statements stay in their selected arm. Quoted ELSE and REM
   text do not introduce an arm. All pending inline false labels resolve at the
   first ELSE, with an unconditional jump over the remaining line for true paths.
3. THEN followed by a conventional line target emits a native GOTO fixup. ELSE
   accepts the same target form. Named targets use explicit GOTO/GOSUB. Omitted
   THEN with an inline statement is admitted. THEN at physical line end opens a
   multiline conditional; ELSE starts its optional alternative and ENDIF closes.
4. The BBC source parser retains a bounded32-entry multiline stack and per-line
   inline false labels, with native jump addresses resolved through existing
   fixups. Block ELSE/ENDIF must start their physical statement line. Opening
   a multiline IF inside an inline IF is clearly rejected in this tranche.
   Invalid nesting is diagnosed before opening the output file.
5. No numeric runtime, representation, vendor routine, license or string runtime
   changes are needed. Unselected code contains no variable creation, arithmetic
   calls or literal-error execution. No interpreter state or entry address is
   linked. Source compile errors remain compile-time errors even in skipped arms.
6. `oracle.bas`, `oracle.log` and `oracle.py` retain actual reference probes on
   the authorized Pi5 CLI fixture. Automated evidence is separate from hardware
   validation. This source audit is preparatory; successful qualification and
   promotion must be recorded in C004.md before live behavior changes.

# Compiler development — 2026-11-01

The compiler now emits native numeric VDU expressions, standard unary math
functions and default numeric PRINT using the qualified BBC arithmetic runtime.
Packed arithmetic and exact output comparisons pass in the Pi5 CLI emulator.
The Author rejected the decimal converter's deliberate reader improvements.
The corrected C002 baseline is accepted for the development checkpoint;
the exact-conversion experiment remains historical research only.
Scalar numeric variables are now promoted with reference-compatible creation,
storage and assignment. Mutable strings and self-hosting remain incomplete;
accepted testing is required
before promotion to main.

The later C007 search establishes a curated testing/benchmark source catalogue
and measurement contract. It adds no compiler behavior or measured speedup.

## Checkpoint and C001 promotion

1. The Author requested the existing work be committed and pushed before the
   next tranche. Inspected all pending files, checked the retained compiler
   input hash and committed the bootstrap, task structure and evidence as
   `a45a15f` on `codex/native-bbc-compiler`. Pushed that branch to the Author's
   origin repository and established tracking before new implementation work.
2. The checkout had no Git author identity. Used the existing identity from
   the canonical `agon-dev-env` repository for the commit via command-scoped
   configuration; no global/repository identity was changed.
3. **C001 completed:** promoted the compiler, sample, assembly oracle and test
   harness to `compiler/`, with no competing maintained experimental source.
   The compiler hash stayed unchanged. Only harness root-path resolution
   changed. Repeat qualification passed 39 cases and 15 native executions in
   13.041 seconds; evidence is in
   [promotion-001](tasks/C001/evidence/promotion-001/results.json).
4. Updated the handoff, runbook, specification/matrix and task record. Removed
   C001 from the TODO, recording promotion as the closure rationale. This does
   not claim human graphical or physical hardware validation.

## C002 numeric runtime tranche

1. Refined C002 before implementation to isolate a runtime adapter and qualify
   its ABI; source-language expressions remain later work under the same ID.
   Selected the exact local BASIC V math package to match the reference rather
   than mixing it with Dean's older package. Retained its license/source
   unchanged in the task silo. See [C002](tasks/C002.md),
   [ABI](tasks/C002/ABI.md) and [provenance](../compiler/runtime/vendor/PROVENANCE.md).
2. Standalone assembly/linking exposed UEXT/UEXTA macro dependencies and two
   undeclared sparse stack helpers in addition to the three declared imports.
   Supplied explicit bytewise helpers; the standalone numeric object has zero
   unresolved symbols and totals 3812 bytes, including the whole package.
3. Implemented the in-place five-byte numeric adapter, error/selector boundary
   and native test probe. The real interpreter creates packed values and
   expected bytes; Python does not implement BBC arithmetic. The probe dirties
   register upper bytes and checks status flags, SP/index preservation,
   operand aliasing, adjacent canaries and unchanged buffers.
4. Initial differential qualification passed 253 cases. Additional exact
   precision fixtures exposed two errors in the fixture assumptions: exponent
   bias and IEEE-style ties-to-even. Corrected them after checking FONE/ODD;
   the runtime code did not change. The package rounds tested halfway additions
   to an odd low significand bit. Both 2^32+1 and 2^32+3 round to 2^32+2.
5. The reference interpreter's decimal constant `4294967296.0` was observed as
   `FA FF FF 7F 9F`, differing from the exact multiplication construction
   `00 00 00 00 A0`. Retained the failed fixture observations and source under
   C002 evidence; future compiler literal handling must address this
   explicitly instead of blindly reproducing a reference parser defect.
6. Final qualification passed **257 cases**, including four explicit byte
   anchors, with **zero numeric or ABI mismatches**. Duration was **15.574
   seconds**, excluding profile provisioning; unlimited emulation supplies no
   hardware performance claim. Retained
   [results](tasks/C002/evidence/qualification-001/results.json), raw oracle
   fixture, case descriptions, reference/native logs and source/environment
   identities in the task's evidence directory.
7. **C002 remains open:** experimental adapter qualification does not enable
   numeric compiler syntax. Literal/expression parsing, numeric emission and
   relocatable runtime integration remain in the authoritative TODO. No
   numeric code was promoted, interpreter source modified, graphical emulator
   launched or physical hardware deployed.

The initial checkpoint is pushed. At the end of that tranche, new promotion
and C002 work remained uncommitted for review; the initial commit request
covered the earlier dirt.

## C007 search task requested

1. The Author requested a curated search for testing and benchmark programs,
   particularly branch/dispatch/call/lookup/I/O workloads that expose overhead
   beyond shared numeric routines. Created [C007](tasks/C007.md) and its TODO
   entry before starting the search.
2. The Author explicitly requested all current dirt be committed and pushed
   before executing C007. The checkpoint includes the completed C001 promotion,
   C002 runtime qualification and the newly defined search task. Search results
   are recorded below, after that checkpoint.

## C007 search completed

1. Committed and pushed the complete pre-search tree as
   `ccd09af856f2745add0b150c6f7b3efd51e992e9` on
   `codex/native-bbc-compiler`. The checkpoint included C007's definition;
   substantive search followed the successful push.
2. Inspected local tests and primary external sources. Retained a catalogue of
   three correctness groups, thirteen performance candidates and three mixed
   applications, with explicit source-inspection versus execution status.
   [compiler/TESTING.md](../compiler/TESTING.md) provides the permanent entry;
   the detailed [catalogue](tasks/C007/CATALOG.md) remains in the task silo.
3. Preferred established sources are bench64's individual control/call/string/
   array/numeric cases and BBC-specific ClockSp kernels. BBCSDL timing exposes
   dispatch/name-lookup work but needs substantial adaptation. Local CASE,
   stress, LOCAL/string and file regressions provide smaller seeds. The compiler
   and bounded Life are realistic mixed workloads; CPU Mandelbrot supplies a
   numeric-heavy control. No complete performance candidate compiles today.
4. Recorded 27 pinned local source identities and verified exact Git blobs for
   eleven external source/license files. Final checks resolved 62 local links,
   parsed both inspection tools/provenance files and passed `git diff --check`.
   Rendered four tokenised originals with
   the task-local inspection aid; it validates framing, not dialect equivalence.
   No external BASIC source was vendored. Downloads/listings remain ignored.
5. Recorded licensing evidence and uncertainty. Bench64 is CC BY-SA 4.0 and
   disallows speed-oriented changes in official comparisons. Matrix Brandy's
   repository GPL text does not by itself settle historical ClockSp provenance.
   Original/adapted versions must stay distinguishable.
6. The [measurement contract](tasks/C007/MEASUREMENT.md) requires equal validated
   work, exact BBC numeric semantics, deterministic inputs, raw target ticks,
   adequate duration/repeats and separate compute/API/device results. Existing
   progress output, constant-foldable expressions and historical relative-MHz
   displays must not be mistaken for clean CPU measurements.
7. **C007 search complete:** removed its unfinished-work entry with these
   deliverables/evidence as the technical closure rationale. Gaps are documented
   as findings, not a competing implementation checklist. No new compiler
   feature, benchmark adaptation, emulator deployment or performance run was
   begun. New research/documents remain uncommitted for the Author's review;
   the requested pre-search checkpoint is already pushed.

## C002 native expression integration and development promotion

1. At the Author's request, committed all C007 dirt as `227b620`. Automatic
   approval review initially rejected the push pending an exact destination;
   the Author authorised the origin and then corrected the proposed `compiled`
   branch to the existing development workflow. Inspected local/remote state,
   removed the never-pushed local `compiled` branch and pushed `227b620` to
   `origin/codex/native-bbc-compiler`. Main remains unchanged. Future promotion
   to main requires accepted testing.
2. Refined the next C002 tranche before implementation. Oryx is down for
   maintenance; all emulator work used the current Pi5's existing canonical
   headless CLI fixture. No Oryx connection, graphical review or hardware
   deployment occurred. The original 39-case/15-execution bootstrap passed
   before new code, in 13.130 seconds.
3. Implemented BBC BASIC parsing/emission for numeric VDU expressions and
   standalone runtime integration. Preserved the inspected evaluator's
   left-associated power and tight unary binding. Whole decimal/zero-fraction
   literals and signed hex patterns retain standard numeric representations;
   general fractions/exponents, numeric PRINT, variables and functions remain
   clear exclusions. The observed 2^32 reader defect is intentionally corrected.
4. Qualified assembly packaging at two independent addresses, then compared
   every emitted numeric template against GNU linking. Integration caught and
   fixed a hex-template loader assumption and a high-bit hex conversion boundary.
   Kept the old numeric adapter/vendor unchanged; new literal/unary helpers
   bring the complete template to 3854 bytes with 375 internal relocations.
5. Full experiment passed **84 cases / 67 native executions / 17 rejections**,
   using 58 BASIC reference expressions and 66 independently linked emitted
   images. Covered precision, overflow, native errors, GOSUB error exit, eager
   evaluation, diagnostics, destination preservation and deterministic repeats.
   Seven bounded batches totalled **330.787 seconds**, excluding provisioning;
   these are host qualification durations, not physical Agon timing. Retained
   [summary and raw evidence](tasks/C002/evidence/expressions-001/summary.json).
6. Promoted the exact tested compiler and assembly/runtime build inputs into
   `compiler/`, with unchanged BBC source hash
   `4095e9e61e953a84b2f257717a6642f4609df49a57a15bee5ffd0d84de8f03d2`.
   The frozen evidence compiler is historical, not a second maintained source.
   Adjusted test source locations, DATA restore and three obsolete VDU rejection
   fixtures. Live baseline qualification passes **39 cases / 15 native
   executions** in **21.735 seconds**, retaining the complete assembly golden.
   From the promoted locations, repeated 24 targeted expression cases (19
   native executions / five rejections) in 89.409 seconds and all 257 numeric
   ABI cases with zero mismatches in 7.839 seconds. Retained
   [promotion evidence](tasks/C002/evidence/expressions-promotion-001/summary.json).
7. Updated the specification/matrix, handoff, runtime runbook and C002/TODO.
   C002 remains open for broader literals, numeric formatting/functions and
   semantic coverage. New changes remain uncommitted for Author review; the
   pre-tranche checkpoint is pushed and main is untouched.

## C002 standard math functions and numeric output

1. At the Author's request, committed all previous dirt as `b1b708c` and pushed
   it to `https://github.com/bgates747/agon-bbc-basic.git` on the existing
   `codex/native-bbc-compiler` branch before starting this tranche. Main remains
   `2998edd4ceb6030d6840cb4e3d587e75d94dc44c`. Refined the scope and acceptance
   in [C002](tasks/C002.md) before implementation. Oryx remains unavailable;
   all automated work used the Pi5's existing canonical CLI fixture.
2. Added ABS/ACS/ASN/ATN/COS/DEG/EXP/INT/LN/LOG/NOT/RAD/SGN/SIN/SQR/TAN and PI
   to the BBC compiler, with the reference's tight item binding. PRINT now
   accepts numeric expressions mixed with string literals using semicolons,
   default G9 output, initial ten-character numeric fields and the reference's
   padding/newline rules. General fractional/exponent source literals, variables,
   source VAL/STR$, @% assignment and other PRINT formatting remain excluded.
3. Expanded the assembly adapter's unary selector boundary and added a separate
   STR formatter bridge, respecting its format/output pointer ABI rather than
   treating it as a binary numeric operation. No vendor math or interpreter
   source was changed. Explicit NUL termination and full ADL pointer subtraction
   avoid the interpreter's page-aligned ACCS assumption; PRINT owns 32 bytes of
   synchronous scratch. The combined runtime totals 4028 bytes/380 relocations
   with no unresolved symbols; independent links at &41000/&47000 match.
4. Initial qualification passed **449 packed numeric/ABI cases** in **17.578
   seconds**, **45 formatter cases** in **2.037 seconds**, **22 integration
   programs** (14 native/eight rejected, including 58 legacy arithmetic
   observations) in **121.758 seconds**, and the **39-case/15-execution**
   baseline in **22.532 seconds**. Two selected legacy batches passed 24 more
   cases in **8.145/41.568 seconds**. Fixed a reporting-only relative-path bug
   and reran those batches; target arithmetic did not change.
   Retained [initial source, oracles and logs](tasks/C002/evidence/output-001/summary.json).
5. Formatter qualification includes exact packed minimum/maximum BBC floats,
   integer boundaries and exponents; the output buffer begins at page offset
   251 and crosses a page boundary. The probe checks NUL/length/canaries,
   readonly input, flags and IX/IY/SP preservation. Actual BASIC supplies all
   numeric/formatting expectations; Python only orchestrates and compares.
   Integration compares complete output transcripts and independently links
   each emitted runtime. Numeric errors, GOSUB exit and unsupported syntax are
   covered. These durations are host qualification evidence, not benchmarks.
6. Promoted the exact qualified compiler and runtime helpers from C002/output
   into the single live `compiler/` source tree, retaining historical snapshots
   in evidence. Compiler SHA-256 is
   `fa57cc43b08ee279e42fef3fbe78e549a9c6ecbfcf4eea65778e49788643aa41`.
   Regenerated DATA preserves those bytes. Added the tested
   [numbers example](../compiler/examples/numbers.bas). The formatter probe and
   all qualification harnesses remain task-owned.
7. Live-location checks passed **449 numeric cases** in **17.447 seconds**,
   **45 formatter cases** in **2.036 seconds**, the **39-case/15-execution**
   baseline in **22.534 seconds**, and **18 output programs** (10 native/eight
   rejected, with the new demonstration and `--skip-legacy`) in **62.599
   seconds**. Deterministic repeats, independent runtime links and the original
   complete literal-only assembly golden pass. Retained
   [promotion evidence](tasks/C002/evidence/output-promotion-001/summary.json).
8. Updated the specification/matrix, reference dependencies, runbooks, handoff
   and sole TODO. C002 remains open for general fractional/exponent literals
   and broader numeric semantic coverage; C003–C006 remain unstarted. All new
   tranche changes remain uncommitted for Author review. No Oryx connection,
   graphical emulator review, hardware deployment or performance run occurred.
9. Final review resolved 71 local document links, parsed six Python tools and
   the retained JSON, checked all 544 ordered BASIC source lines against the
   255-byte limit, confirmed byte-identical promotion and unchanged vendor
   math/license, and passed `git diff --check`. Removed redundant identical
   assembly include paths and strengthened the baseline EVAL diagnostic check;
   repeated the 39-case baseline in **22.532 seconds** and all 449 numeric
   cases in **17.549 seconds**. Final reports/tool hashes are retained in
   promotion evidence. These orchestration edits do not change target bytes.

## C002 decimal literals

1. The Author requested another checkpoint before the next tranche. Committed
   all numeric-output dirt as `7f45af9` and pushed it to the authorised origin
   on `codex/native-bbc-compiler`. Main remains untouched. Refined the decimal
   tranche in [C002](tasks/C002.md) before implementation; Oryx was not contacted.
2. Implemented fraction/scientific atoms, leading/trailing decimal points and
   E/e with bounded signed exponents in the BBC BASIC compiler. Exact integer
   numerator/denominator workspace produces 32 significand bits and an explicit
   odd-LSB rounding decision. Output remains standard BBC numeric records;
   neither Python nor a copied assembly parser implements this conversion.
3. Preserved the reference's integer/float typing where applicable, canonical
   zero and underflow flush. Literal overflow, malformed exponents and capacity
   bounds fail at compile time before output is opened. EOR remains a word
   operator boundary. [LITERALS.md](tasks/C002/LITERALS.md) owns the detailed
   grammar, limits, algorithm and deliberate reader corrections.
4. Final-source qualification passes **174 accepted literals / 16 rejections**
   with no packed mismatch, matching native output and independently linked
   runtime images. This includes 110 exact binary/midpoint fixtures generated
   independently by BASIC decimal digit-string arithmetic. Retained all 104
   differences from the truncating/scaling reference reader; these stress
   fixtures are not a representative failure-rate sample. Five batches took
   **574.475 seconds**, excluding **145.081 seconds** for fixture generation.
   Four batches repeat deterministically; the supplemental 66-case batch is
   explicitly single-pass. See [qualification evidence](tasks/C002/evidence/literals-001/summary.json).
5. Broader output qualification passes **24 programs / 16 native executions /
   eight rejections**, including 58 legacy arithmetic observations, in
   **157.554 seconds**. Native numeric functions, semicolon formatting,
   scientific/operator binding, ordinary crunched EOR, errors, source rejection,
   destination preservation and repeat determinism still pass.
6. Corrected an initial nested IF/ELSE carry-append error in the prototype.
   Oracle setup also needed short source-string chunks, ON ERROR LOCAL for
   procedure error recovery and conventional spacing after scientific literals
   in word-operator comparisons. Retained [failed-source/debug evidence](tasks/C002/evidence/literals-debug-001/README.md)
   and [preliminary reports](tasks/C002/evidence/literals-preliminary-001/summary.json).
   Final-source qualification supersedes those preliminary runs. The runner
   now snapshots compiler bytes and rejects edits during a run.
7. Promoted exactly the tested compiler into `compiler/compiler.bas`, SHA-256
   `bea645170420bc6ce60bb648dbc5a919ac5bdd56f437ca785719e8e262ff3d31`.
   Only the independent fixture generator remains in the experiment directory.
   Regenerated DATA stays byte-identical; the 4028-byte/380-relocation runtime
   and vendor source/license remain unchanged. Live baseline qualification
   passes **39 cases / 15 native executions** in **23.641 seconds**, retaining
   deterministic output and the complete assembly golden.
8. Live rechecks also pass **26 targeted expressions** (nine native/17 rejected)
   in **54.504 seconds**, including source diagnostics, numeric error exits in
   GOSUB and direct decimal/scientific VDU truncation. Repeated **12 boundary
   literals** in **30.167 seconds** with matching packed/native output,
   independent links and deterministic recompilation. Retained
   [live-location evidence](tasks/C002/evidence/literals-promotion-001/summary.json).
9. **C002 initial numeric baseline complete:** its bounded acceptance criteria
   now cover storage/ABI, arithmetic, expressions, default formatting and general
   decimal atoms. Removed its TODO entry and recorded these results as the
   technical closure rationale. The compatibility matrix retains limits and
   exclusions; C003–C006 remain unstarted. Updated the specification, reference
   audit, handoff and runbooks. New work remains uncommitted for Author review;
   main is untouched. No graphical/hardware validation or performance benchmark
   occurred. All automated work used the Pi5; Oryx remains unavailable.
10. Final static checks parsed four changed Python tools and 28 retained JSON
    files, resolved 81 local document links, and verified all 620 ordered BBC
    source lines against the 255-byte limit. Confirmed byte-identical promotion,
    unchanged runtime/vendor/license, the pushed `7f45af9` checkpoint and
    untouched main refs. `git diff --check` passes. No competing experimental
    compiler remains outside frozen evidence.

## C002 reopened: reference behavior and separate interpreter research

1. The Author rejected deliberate improvements to BBC BASIC output: execution
   speed is the only intended observable runtime difference for supported
   conventional programs. Reopened C002 before correction and strengthened the
   specification/handoff. Earlier exact-decimal closure and qualification remain
   historical, explicitly superseded by this policy.
2. The Author separately authorized keeping interpreter improvement ideas.
   Added [research findings](../compiler/INTERPRETER-FINDINGS.md), including
   `4294967296.0` versus arithmetic construction, pinned reader provenance and
   links to the frozen exact-converter experiment. Its 104 stress differences
   are candidates for assessment, not 104 proven bugs or approved compiler
   divergences. No upstream interpreter patch or submission was made.
3. Restored numeric reading through bootstrap BASIC's VAL after scanning the
   original atom in BBC BASIC. It shares CON/NUMBER with the direct-source
   reader; compiled applications still contain packed values and standalone
   runtime code. Native self-hosting will need source VAL's string-pointer
   interface; that later implementation is not claimed here. Reader errors
   become native errors only when executed. Withdrawn lowercase-e grammar and
   independent exponent limits are not silently retained as extensions.
4. Removed both earlier 2^32 oracle substitutions and compare identical source
   in the reference/compiled output suite. Direct-source checks also exposed
   incorrect emitted numeric messages copied from MATH comments. Actual BASIC
   reports `Number too big`, `-ve root` and `Exponent range`; corrected those
   messages and retained the failed run in
   [debug evidence](tasks/C002/evidence/literal-compatibility-debug-001/README.md).
5. Corrected literal qualification passes **180 literals**, comprising **170
   exact packed-value matches** and **ten reference error matches**, plus **eight
   unsupported-source rejections** preserving existing output. Both batches
   repeat deterministically and independently linked runtimes match. Durations
   are **61.998/85.406 seconds**, **147.404 total**, using the previous BASIC-
   generated stress inputs as spellings rather than exact-value expectations.
   [Evidence](tasks/C002/evidence/literal-compatibility-001/summary.json) retains
   compiler/tool snapshots, original-source oracles, fixture bytes and logs.
6. The corrected output suite passes **28 programs** (**20 native/eight
   rejected**, including **58 prior arithmetic observations**) in **148.288
   seconds**. Actual reference REPORT text supplies numeric error expectations;
   the native fixture also preserves unreachable literal overflow. Targeted
   expression regressions pass **26 cases** (**nine native/17 rejected**) in
   **51.214 seconds**. Recompilation is deterministic and independent runtime
   links match. Retained both reports and logs in the compatibility evidence.
   Output qualification compares program/REPORT text, not interpreter prompts.
7. Final-source baseline passes **39 cases/15 native executions** in **23.037
   seconds**, including the complete assembly golden and deterministic repeat.
   Compiler SHA-256 is
   `9a33abb5ffd4e9f6818d22c611842d9ac3bd606aa386bbc2bc7a370d68c0e33a`.
   Runtime DATA, adapter/formatter assembly and vendor math/license match HEAD;
   existing numeric/formatter qualification is retained without rerunning
   unchanged code. Frozen new evidence includes tool/source snapshots and a
   file hash manifest. C002 remains open for review and C003 unstarted. Updated
   normative documents; changes remain uncommitted. No Oryx, graphical/hardware
   validation or benchmark performance measurement occurred.

## Corrected C002 development checkpoint accepted

1. The Author explicitly requested commit/push after the compatibility correction
   and research separation, then continuation to the next tranche. Accepted the
   corrected initial C002 scope on the development branch and removed its review
   entry from TODO. Existing evidence retains its original historical status;
   this permission does not assert graphical/hardware validation or main acceptance.
2. C003 is next: refine and qualify scalar numeric bindings before mutable
   strings, following the interpreter's existing behavior rather than inventing
   default initialisation or assignment semantics. Oryx remains unavailable.

## C003 scalar numeric tranche begins

1. Committed all corrected C002 work and retained research as `b20c377` and
   pushed to the Author's origin on `codex/native-bbc-compiler`. Refined the
   [C003 scope](tasks/C003.md) before implementation. Main is unchanged.
2. Audited reference variable creation, lookup and byte/four-byte/five-byte
   storage. Assignment creates a missing destination before evaluating the
   RHS; ordinary undefined reads fail, while A%–Z% are predefined. Unsuffixed
   storage retains the numeric variant rather than forcing floating point.
   These behaviors define the experiment; no interpreter improvements apply.
3. Implemented the C003 prototype in BBC BASIC: plain/LET scalar assignments,
   case/suffix-specific names, runtime existence, static A%–Z%, SFIX stores and
   one/four/five-byte payloads. Native byte copies and flag checks are emitted
   by BBC BASIC; the arithmetic/runtime template and vendor files are unchanged.
   Names that would conflict with unsupported keyword/pseudo-variable syntax
   are rejected instead of silently becoming language extensions.
4. Qualification corrected three assumptions/implementation mistakes, retaining
   their failed evidence: the reference rejects SFIX of the floating negative
   integer boundary; an early function result with an active FOR frame produced
   `Not in a FN`; and reusing the constants-only reference namespace leaked a
   variable between scalar programs. The revised predicate completes its loops,
   and the scalar reference suite resets dynamic variables and A%–Z% per case.
   Added the conversion observation to interpreter research without changing it.
5. Prototype qualification passes **26 programs** (**14 native/12 rejected**)
   in **169.295 seconds**, plus **20 exact physical payloads**, existence flags,
   an unreachable undefined binding and unchanged-image guards in **44.231
   seconds**. BBC supplies byte expectations; MOS SAVE retrieves native memory.
   Runtime images match independent GNU links and repeat compilation matches.
   [Initial evidence](tasks/C003/evidence/scalars-001/summary.json) retains source,
   fixtures, maps, binary snapshots and logs; failed attempts remain separate.
6. Promoted byte-identical source to the single live compiler, SHA-256
   `7de07d887b68cd13442474b1c0c4e26668c7054c927b5fc93aa2ff4f00ecbbd7`.
   Removed the maintained prototype, added `compiler/examples/variables.bas`
   and updated the specification, matrix, reference audit, handoff and TODO.
   C003 remains unfinished for mutable strings; no activation features began.
7. Live qualification passes the **39-case/15-execution** baseline in **47.362
   seconds** with its full assembly golden, **27 scalar programs** (**15 native/
   12 rejected**) including the example in **118.424 seconds**, and the same
   **20 physical payloads** in **22.663 seconds**. Host duration varies; these
   are not performance benchmarks. The obsolete 45-second baseline compile guard
   expired during ordinary progress, so the runner gained an explicit compile
   timeout. Updated obsolete numeric-variable rejection fixtures to strings/arrays
   while retaining their rejection and output-preservation coverage.
8. Broader live regressions pass **28 numeric-output programs** (**20 native/
   eight rejected**, including **58 earlier arithmetic observations**) in
   **156.036 seconds**, and **26 targeted expressions** (**nine native/17
   rejected**) in **53.916 seconds**. Independent runtime links, output/error
   transcripts and deterministic repeats pass. [Live evidence](tasks/C003/evidence/scalars-promotion-001/summary.json)
   includes all reports, exact source/tool snapshots and hash manifests.
9. Static verification confirms byte-identical promotion, valid source-line
   order/length, unchanged numeric DATA/runtime/vendor/license, Python/JSON
   parsing, valid document links and clean whitespace. The original checkpoint
   remains pushed at `b20c377`; all C003 tranche changes remain uncommitted for
   Author review. C003 stays in TODO for strings; main is unchanged. All
   automated work used the Pi5, with no Oryx, graphical/hardware validation or
   benchmark performance measurement.

## Scalar development checkpoint accepted

1. The Author requested commit/push and continuation after the scalar tranche.
   Accepted that checkpoint on the development branch, with all qualification
   and historical failed evidence retained. C003 remains in TODO for strings;
   human/hardware validation and main promotion remain separate.
2. Scalar checkpoint `4577673` was pushed to the Author's origin. Staging
   exposed that C003 lacked a build-directory ignore rule, so disposable build
   copies entered that checkpoint. A follow-up removes them from version control
   without deleting local outputs, adds a general task build ignore, and keeps
   the selected evidence/manifests under `evidence/`.

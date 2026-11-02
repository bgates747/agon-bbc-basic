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

## C003 mutable string core begins

1. Pushed scalar support as `4577673` and its task-build cleanup as `c9f0b5f`.
   Refined C003's string scope before implementation. Audited length/capacity/
   pointer storage, copied assignment, capacity reuse/tail growth, CHR$ and LEN.
   Existing interpreter entry points depend on ACCS/FREE/HIMEM and cannot be
   called unchanged from standalone code.
2. The initial core uses private length-prefixed expression buffers and an
   allocator context, preserving logical contents and value-copy semantics.
   Its workspace has an explicit per-binding bound for this no-LOCAL tranche.
   Numeric math/vendor bytes remain unchanged; further string functions and
   activation features remain outside this tranche. No interpreter improvement
   is adopted and no Oryx connection is made.
3. Completed the scalar checkpoint evidence in `58feb04`: four selected binary
   snapshots had matched the local manifests but were excluded by the global
   binary ignore. Explicitly tracked those selected snapshots, leaving generated
   build outputs ignored. Their hashes and original reports are unchanged.
4. String smoke qualification caught an empty opcode-prefix emission bug and
   review caught incomplete 24-bit BC clearing. Full qualification then exposed
   a pre-existing scalar reentrancy bug: FOR 0 TO -1 still compared one stale
   binding after resetting the count. Switched lookup to WHILE and added paired
   same-first-name compilations to numeric/string suites. All failed records
   remain task-owned evidence, not passing qualification.
5. Prototype qualification passes **23 programs** (**14 native/nine rejected**)
   in **88.088 seconds**. The same-source oracle preserves LEN/CHR$ binding,
   copied ownership, empty/max-length contents, undefined reads and grouped
   error order. Determinism and independently linked runtime checks pass.
6. A raw-memory probe passes **15 string bindings**, an uncreated descriptor
   and a four-byte LEN result in **53.404 seconds**: exact reference contents,
   independent blocks, descriptor bounds and unchanged image/heap guards.
   The direct ABI probe passes in **1.016 seconds**, including upper-BC poison,
   IX/IY/SP, page-crossing descriptors, zero/255 inline records, unchanged
   concatenation overflow and allocation failure. Its initial fixture forgot
   whole-program MOS register preservation; that failed run is retained and
   the fixture correction does not change the qualified runtime.
7. Froze [prototype evidence](tasks/C003/evidence/strings-001/summary.json), then
   promoted byte-identical compiler/runtime to `compiler/compiler.bas` and
   `compiler/runtime/strings.s`. Promoted the assembly packer with path changes
   only. Numeric DATA/vendor/assembly/license remain unchanged; numeric
   regeneration now preserves string DATA. Both packers reproduce the compiler
   exactly. Historical prototypes remain evidence, not maintained forks.
8. Added the [string contract](tasks/C003/STRINGS.md), example and updates to
   specification, compatibility, reference audit, handoff and TODO. Slicing,
   comparison and VAL/STR$ remain C003; activation/LOCAL remain C004. Live-location
   checks run sequentially on the Pi5. New tranche changes remain uncommitted;
   no Oryx, graphical/hardware qualification or benchmark is claimed.
9. Live rechecks pass the **39-case/15-execution** baseline in **27.761s**,
   **23 string programs** in **93.371s**, **15 string bindings plus guards** in
   **53.419s**, the ABI repeat in **1.017s** and expanded alias/full-failure-state
   checks in **1.015s**. The example and two explicit string-limit rejections
   pass in **27.974s**. The initial limit fixture order violated the shared
   runner's first-success repeat convention; its failed assertion is retained,
   and reordering the fixtures required no compiler/runtime change.
10. Numeric regressions pass **29 scalar programs** in **128.957s**, **28 prior
    output programs** (58 earlier arithmetic observations) in **176.706s**, and
    expression batches of **12** and **26** in **71.224s** and **60.208s**.
    An ad-hoc archival script selected the parent expression build path after
    the first passing batch; corrected the copy from batch-000 without changing
    or rerunning results. [Live evidence](tasks/C003/evidence/strings-promotion-001/summary.json)
    retains reports, sources, logs, binary snapshots and a complete manifest.
11. Final checks verify byte-identical compiler/runtime promotion, both DATA
    sections, unchanged numeric library/vendor/license, source line limits,
    Python/JSON parsing, document links and manifest inclusion under normal Git
    staging. HEAD/upstream remain `58feb04`, main remains `2998edd`. New string
    work stays uncommitted for review; C003 remains in TODO for broader strings.

## String core development checkpoint accepted

1. The Author explicitly requested commit/push and continuation into C003
   slicing and comparisons. Accepted the qualified mutable string core for a
   development checkpoint, retaining all source, successful and failed evidence.
   Main remains unchanged; graphical/hardware acceptance is not asserted.

## C003 slicing and comparison tranche begins

1. Pushed qualified string core as `be0f299` before new work. Refined the next
   C003 tranche before coding: expression slicing and six string comparisons,
   with typed expression results. VAL/STR$ and slice assignments stay outside
   this tranche; no activation work starts. Oryx remains unavailable.
2. Reference audit finds that slice indices/counts use only the low byte after
   signed SFIX. Omitted LEFT$ drops the final byte; omitted RIGHT$ selects one
   final byte; MID$ start zero retains the full string. These are compatibility
   requirements, not opportunities to change BASIC's behavior. SCP0 compares
   unsigned bytes and then lengths. Runtime adaptations use private buffers
   rather than ACCS/page alignment or interpreter expression/stack entries.
3. Implemented private-buffer LEFT/RIGHT/MID and unsigned lexicographic ordering
   as a 105-byte addition to the unchanged 264-byte string core. The numeric
   runtime and allocator remain unchanged. The first smoke compile exposed an
   inline nested-IF dispatch ambiguity; replaced it with an explicit helper.
   The corrected mixed slice/comparison smoke passes in 33.284s.
4. The first full suite compiled all accepted sources, then stopped on an
   incorrect expected diagnostic for a rejected slice-assignment target. That
   incomplete run is retained separately. Corrected the fixture and preserved
   the prior string-specific recursion accounting: numeric expression frames
   and all items count toward the shared 32-entry budget; string expression
   frames are not charged twice. Added a deep previously admitted string case
   before repeating. No language behavior is inferred from test expectations.
5. Prototype qualification passes **36 programs** (**25 native/11 rejected**)
   in **277.395s**, with actual BASIC transcripts, ordered errors, independent
   links and determinism. A native ABI probe passes in **1.016s**, including
   0/255 lengths, unsigned/prefix ordering, read-only operands, zero-count moves,
   poisoned upper BC, guards and IX/IY/SP preservation.
6. Raw qualification passes **23 string bindings**, an uncreated descriptor and
   packed integer results in **86.461s**, with exact reference contents, distinct
   ownership, bounds and no unexpected writes. Heap use is 1574/24576 bytes and
   23034 bytes after FREE remain untouched. A copy script initially selected
   transcript-only cases.json for this raw probe; corrected the archival file
   list without repeating or changing the passing run. The baseline passes
   **39 cases/15 native executions** plus its complete assembly golden in
   **29.518s**. [Prototype evidence](tasks/C003/evidence/slices-001/summary.json)
   retains sources, reports, snapshots and logs.
7. Promoted exact tested compiler/runtime to their single live paths; compiler
   SHA-256 `09e736f210007086a5c4645e4e96e14a717f28f340acbe1860c170bf19dcfbc0`.
   Runtime size is 369 bytes, preserving the old 264-byte prefix. Numeric
   DATA/assembly/vendor/license remain unchanged. Removed maintained prototype
   compiler/runtime/packer copies, retained task-owned qualification tools and
   froze historical source. Both live packers reproduce the promoted compiler.
8. Updated specification, matrix, reference audit, runtime/reader guides,
   handoff, C003 contract and TODO. Live validation uses sequential Pi5 CLI
   runs. No Oryx, graphical/hardware review or performance benchmark is claimed;
   new tranche work remains uncommitted pending review.
9. Live checks pass the **39-case/15-execution** baseline in **29.361s**, the
   selected mixed integration in **33.787s**, the new and old native ABI probes
   in **1.016s** each, and **23 raw string bindings** plus guards in **85.953s**.
   The old **23 string programs** pass in **99.288s**; the example and both
   buffer/nesting limits pass in **31.882s**.
10. Numeric regressions pass **29 scalar programs** in **137.337s**, **28 output
    programs** (58 earlier arithmetic observations) in **191.359s**, and expression
    batches of **12** and **26** in **75.989s** and **64.386s**. A failed output
    attempt expected the old diagnostic for ABS("x"); the new parser correctly
    rejected the string argument. Retained that attempt, corrected only the
    expected diagnostic and repeated. No compiler/runtime or valid output changed.
11. Review added a focused same-source check for PRINT beginning directly with
    a quoted-literal comparison, plus fields, arithmetic/functions and a slice
    count reading its original target. It passes in **30.774s** and becomes the
    maintained suite's 37th case. The earlier complete 36-case prototype result
    remains distinct from selected live rechecks. [Live evidence](tasks/C003/evidence/slices-promotion-001/summary.json)
    retains exact source/tools, scripts, reports, logs, bytes and manifests.
12. Final verification checks source order/loader limits, byte-identical
    promotion and DATA regeneration, unchanged numeric library/vendor/license
    and old string core, Python/JSON, links and manifest inclusion. HEAD/origin
    remain `be0f299`, main is unchanged, and the new tranche stays uncommitted.
    C003 remains in TODO for remaining string functions/conversions and slice
    assignment; no Oryx, benchmark or graphical/hardware qualification occurred.

## C003 conversion tranche started

The Author's “go” authorizes the next bounded implementation: VAL, STR$ (G9 and
hex) and ASC. The slicing/comparison changes remain uncommitted. Audited
EVAL.Z80 VAL/STRS/HEXSTR/ASC and MATH.Z80 VAL/CON/NUMBER/SIGNQ/FPP/STR. The numeric
package already provides decimal conversion; the compiler will use that exact
code with private buffers rather than implementing a replacement parser.
The C003 brief records scope and qualification before implementation. Search,
repetition, mutable @% and slice assignment remain outside this tranche.

## C003 conversions qualified and promoted

The prototype passes 29 programs (18 native/11 rejected) in 201.849s,
14 string bindings plus 22 raw numeric records in 65.521s, the native ABI probe
in 1.016s and the 39-case/15-execution baseline in 30.454s. VAL executes unchanged
FPP selector 36; STR$ calls the existing G9 formatter, STR$~ adapts HEXSTR, and
ASC is emitted directly. The compiler remains BBC BASIC. Vendor math/license,
the numeric pointer adapter and the string runtime are unchanged.

The broad run exposed a fixture distinction: OSLOAD_TXT2 removes raw control
bytes even inside quoted text. Tests now construct TAB with CHR$(9), and the
compiler clearly rejects raw quoted control bytes pending loader normalization.
A stale longer MOS SAVE target also required fixture cleanup before a shorter
memory capture. Failed fixture and timeout attempts are retained separately.

Promoted byte-identical compiler SHA-256
`49621eebb9dadc8701b782aa72eb88035d4300d2b8150041d7f88301923caf7c`
and expression runtime to their live locations; the mixed example is also
promoted. No maintained compiler fork remains. Numeric DATA now embeds 4460
bytes/387 relocations and regenerates exactly, preserving string DATA. Live
checks follow; no new commit, benchmark, Oryx contact or hardware review is claimed.

## C003 conversion live checks completed

The exact live source passes baseline39/15 (30.453s), conversion example
(34.183s), ABI (1.016s), 14-string/22-numeric memory probe (65.113s), selected
slices (35.985s), and string example/limits (33.881s). Numeric regression passes
449 ABI cases (17.574s), 45 formatter cases (2.036s), 28 output programs with
58 arithmetic observations (205.400s), and 12 expressions (81.334s). Independent
links, determinism and the complete baseline assembly golden pass.

The output batch needed a 360-second guard after its old 180-second guard
expired during progress. That failed attempt is retained separately; the shared
output harness default is now calibrated to 360 seconds. Compiler/runtime code
was unchanged for the repeat. Both DATA packers reproduce the exact promoted
source. Full prototype and selected live scopes remain distinguished in their
manifests/summaries. C003 stays active for INSTR/STRING$, other required string
functions and slice assignment. All new work remains uncommitted for review.

Final checks confirm 828 ordered loader-safe BBC lines, byte-identical promotion,
matching numeric/string DATA, unchanged adapter/vendor/license/string runtime and
reference interpreter, valid source/tool/document formats, and 418 prior manifest
members. Removed an ignored Python cache from the evidence before rebuilding its
manifest; archived evidence is stageable. HEAD/upstream remain be0f299, main
2998edd. New work remains uncommitted and no Oryx/hardware/benchmark claim is made.

## Slice/conversion checkpoint authorized

The Author explicitly requested committing/pushing all dirt before continuing.
Verified all 516 C003 evidence manifest members and clean whitespace. The
qualified slicing/comparison and conversion work is accepted for a development
checkpoint on codex/native-bbc-compiler; main and human/hardware acceptance
remain separate. The next bounded C003 tranche is INSTR and STRING$.

## Search/repetition tranche started

Committed/pushed the approved slicing/conversion checkpoint as c55c951 to the
Author's origin on codex/native-bbc-compiler. The worktree was clean before
starting INSTR and STRING$ under C003. The task brief records scope and
acceptance before implementation. Auditing EVAL.Z80 INSTR/SEARCH/STRING;
slice assignment stays in the following tranche. Oryx remains unavailable.

## INSTR/STRING$ qualified and promoted

The full prototype passes 30 programs (19 native/11 rejected) in 264.246s,
12 string/16 numeric raw records in 69.551s, the native ABI in 1.016s, and the
39-case/15-execution baseline in 31.901s. Actual BASIC confirms empty-needle
zero, byte-wrapped starts/counts, left-to-right errors and count-zero string
evaluation. Native buffers and guards match, with 558/13312 heap bytes used.

Promoted exact compiler SHA-256
`bb2b91cc644f5d8e73841f73a60e93e13f70bdfeacf7ebbc56a0492f0eb61155`
and strings.s to the live paths, plus the tested mixed example. The runtime
adds 164 bytes/two relocations to the unchanged 369-byte prefix. Both DATA
packers reproduce the source; numeric runtime/vendor/license remain unchanged.
No maintained compiler fork remains. Updated task/behavior documents and old
unsupported STRING$ fixtures (now INKEY$). Selected live checks follow; no
Oryx contact, benchmark, graphical/hardware validation or new commit is claimed.

## Emulator work suspended by the Author

Selected live INSTR/STRING$ checks pass baseline39/15 (31.685s), mixed example
(38.525s), ABI (1.016s), and 12-string/16-numeric raw storage (69.805s).
The old string suite had obsolete VAL/STR$ rejection fixtures, now converted to
positive reference cases; its failed expectation check is retained separately.

The Author then prohibited further emulator work on the Pi5 for the night.
Stopped the corrected string run with SIGINT (exit 130) and launched no further
emulator. Remaining live strings/slices/limits/ABI/conversion/expression checks
are deferred in C003/TODO, not counted as passes. Only source/documentation and
static verification continue. The checkpoint c55c951 is pushed; new search/
repetition work remains uncommitted and is not ready for full live acceptance.

## Pi5 emulator work reauthorized; approval stops waived

The Author clarified that Pi5 emulator work is allowed, and authorized proceeding
to the end of the remaining TODO without earlier approval stops. Resume the
interrupted string regression and remaining live checks. Continue qualified
implementation/checkpoints through C003–C006; keep physical/human test evidence
truthful and separate. Oryx remains unavailable. The earlier interruption
record is retained as chronology, not the current restriction.

## Search/repetition live qualification completed

After the Author reauthorized Pi5 emulator work, the corrected string suite
passes 23 programs (16 native/seven rejected) in 123.258s. Selected slices pass
in 37.507s; string example/limits in 35.799s; core/slice ABI in 1.016s/1.017s;
conversion smoke in 35.472s; and 12 numeric expressions in 83.182s. Earlier
baseline/mixed/ABI/raw passes remain valid. Exact source/runtime bytes did not
change during this repeat. Full prototype and selected live scopes, the stale
fixture and the temporary interruption remain separately indexed. Checkpoint
this qualified tranche under the Author's approval waiver, then implement the
C003 slice-assignment scope already recorded before coding.

## Slice-assignment implementation started

Checkpoint 0094ab0 (qualified INSTR/STRING$) is pushed to the Author's development
branch. The pre-code C003 brief and slice-store/AUDIT.md define exact statement
range rules. The prototype now emits LEFT$/RIGHT$/MID$ assignment, checking target
existence before arguments/RHS. A 90-byte native adaptation changes owned bytes
without resizing or allocating. The original 533-byte runtime prefix and both
existing relocations are unchanged. The five-statement mixed smoke matches
BASIC in 31.171s; full differential/native-memory qualification is in progress.

## Slice assignment qualified and promoted

Full prototype qualification passes 27 programs (19 native/eight rejected) in
316.143s, native ABI in 1.016s, 11-string/three-integer raw storage in 41.674s,
and baseline39/15 in 31.445s. Descriptor/ownership/bounds and no-allocation
checks pass; heap use is798/12288 with11522 guard bytes untouched.
Promoted exact source SHA928a46a060fa8b72dbbbc40484561c67b6736ba5cf69eaa7ced932e5409a8617
and runtime plus tested mixed example. The runtime adds90 bytes to the exact
533-byte prefix; both original relocations and numeric runtime/vendor/license
are unchanged. Both DATA packers reproduce the source. Live rechecks finish
before closing C003 and moving through C004–C006 under the Author's waiver.

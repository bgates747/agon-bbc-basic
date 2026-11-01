# Compiler development — 2026-11-01

The compiler now emits native numeric VDU expressions, standard unary math
functions and default numeric PRINT using the qualified BBC arithmetic runtime.
Packed arithmetic and exact output comparisons pass in the Pi5 CLI emulator.
General fractional/exponent literals, variables and self-hosting remain
incomplete; accepted testing is required before promotion to main.

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

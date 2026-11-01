# Compiler development — 2026-11-01

The compiler now emits native numeric VDU expressions using the qualified BBC
arithmetic runtime. Its 84-case integration suite passed before promotion to
the development tree. General literals, formatting, variables and self-hosting
remain incomplete; accepted testing is required before promotion to main.

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

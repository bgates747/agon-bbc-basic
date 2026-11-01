# Compiler development — 2026-11-01

The tested bootstrap was promoted into the live compiler tree, and an isolated
numeric runtime now passes byte-level comparisons with BASIC V. This establishes
a calling interface for arithmetic; compiler numeric expressions and self-hosting
remain unimplemented.

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
   [ABI](tasks/C002/ABI.md) and [provenance](tasks/C002/vendor/PROVENANCE.md).
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
   will be recorded after that checkpoint.

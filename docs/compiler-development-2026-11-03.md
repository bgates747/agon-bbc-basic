# Compiler development — 2026-11-03

The compact compiler now completes source layout inside executable RAM, but its
mandatory initialization storage cannot fit beside that executable. Retain the
measured layout and reduce private storage/code further; no native compiler or
self-hosting result exists yet. Pi5 automated CLI work is authorized; Oryx stays
offline and no physical test is implied.

## Actual compact-source layout and allocation bound

Exact2f81c6fb completes layout339291 bytes, body265236 (prior body390190), with
2078 symbols/213 definitions/254 bindings. Private heap limitA7F00 leaves86437
bytes. Handwritten inventory of its exact typed DIM shapes and pinned assembled
templates gives112761 mandatory payload bytes before array headers, owned string
contents and allocation overhead: a26324-byte minimum deficit. It cannot initialize.
After phase2 begins, deliberately stop only the owned CLI rather than spend two
further passes writing that unusable image. Controller1366.536s is a partial-run
measurement, not successful compile time. Original output remains unchanged.
compact-source-001 retains raw failure/log/source/provenance and an explicit
layout/disposition/bound record. No output pass, native initialization or native
compiler generation is claimed.

## Private zero-tail qualification

Prepared14e56cee stores465 initialized control bytes and streams the unchanged
8192-byte zero tail. Template storage saves8192 and source text19104 bytes;
actual native fit is not inferred. Start nine actual-reference/native cases,
requiring complete output identity with2f81c6fb. All runtime capacity, public
numeric/string semantics and original control-image bytes remain unchanged.

Zero-tail14e56cee passes nine native programs118.267s against actual BBC outputs,
repeat/GNU and all nine complete2f81c6fb images. Freeze zero-tail-frontend-001.
Refine bounded private symbol packing (three-byte addresses/two-byte sorted
indices) and sparse reusable numbered-target pages in COMPACTION.md before
implementation. Accepted source-program numbers/types and capacities do not change.

## Packed private tables and sparse target pages

Prepared6597a0df has2067 lines/219 distinct definitions. It keeps4096 symbols,
storing addresses in exact three-byte cells and sorted indices in two-byte cells
(12288 payload bytes saved). A64-pointer table owns reusable256-byte target
pages, preserving separate branch/DATA domains through65279. Pages allocate and
zero on first write and clear/reuse on subsequent compilations; maximum page
payload16384 bytes, pointer payload256. Static zero-page mandatory payload is
76153 bytes before headers/string contents and future page allocations.

The first nine-source attempt produces all nine images identical to2f81c6fb,
but the host-only BBC map observer accesses the removed saddr% array and fails
at540. Freeze packed-map-observer-failure-001, excluding stale native/results.
Change the observer to call the actual BBC getter for packed candidates; it
still never computes source addresses in Python. Unchanged6597a0df then passes
nine actual-reference/native programs123.659s, repeat, GNU standard/complete
compact links and all nine complete-image comparisons (packed-frontend-002).
A prepared actual-reference/native fixture uses the exact six private BBC helper
routines, all4096 cells with guards, all64 target pages,2047/2048 and65279 bits,
branch/DATA separation and repeated clears/reuse. This helper test is active;
no helper-capacity, actual fit or native compiler result is claimed yet.

packed-helpers-001 passes262.754s: actual BBC and actual native execution of the
exact six new helpers plus FNlineref exercise all4096 address/index cells with
four canaries, all64 pages,2047/2048/65279, domain separation, clear/rewrite and
pointer reuse. Deterministic output and GNU NUM/STR/complete compact module pass;
complete control/ACT/MEM/ERR runtimes, bridges, entry, arena and heap context also
independently match. This is native helper behavior, not a native compiler image.

Numbered-target first oracle used line0, which the pinned text loader executes
immediately during loading (OSEDIT/LNZERO selects XEQ), before later targets
exist. Retain the failed reference-only attempt; no compiler/native phase ran.
Clarify this existing compiler-label syntax boundary in SPEC/COMPAT/findings.
Positive conventional targets2047/2048/65279 and combined branch/DATA labels now
match two fresh BASIC oracles; separate compiler-zero-label fixture prints2.
Two undefined top-line targets reject before output. packed-targets-002 passes
five cases/three native58.636s, repeat and GNU numeric links. Full packed
baseline39/15 also passes56.360s including GNU golden and repeat. These are
controller durations, not Agon speed benchmarks. C005 source errors/capacity and
actual native fit remain open; the next source probe adds BBC-only observations
of allocated target pages and private string lengths after layout, preserving
its exact target source and keeping host instrumentation separate.

## Isolated promotion packaging rehearsal

Push packed checkpoint4575516 and start exact packed-source-001 with BBC-only
page/string observations. Separately stage the future source/runtime/tool tree
under C005/build; live source stays7cac4bba. Add a private control-prefix package
while retaining the full independently linked image, preserve following64000
DATA when repacking errors, and prepare the394-byte adapter at its future live
paths. All nine packages rebuild identical complete runtime bytes, combined
regeneration exactly reproduces6597a0df, and each individual repacker preserves
that full source. Extended rehearsal also preserves the old7cac4bba compiler
through the modified control/error packers. promotion-preparation-002 retains
both rehearsal identities, exact staged changes, source and module data. No live
promotion, emulator change or actual native fit is implied by packaging success.

Packed exact-source phase1 completes324275 bytes/body268243,2094 symbols/
219 routines/254 bindings. BBC observations report7 target pages,13948 symbol
string bytes and5473 other metadata-string bytes. Mandatory payload76153 plus
1792 pages plus19421 observed string bytes totals97366, against101453 private
bytes available:4087 remain before headers/scalars/allocation overhead. This is
a lower-bound comparison, not fit proof. Continue actual validation/output;
no native compiler exists at this point. Exact target source is unchanged.

## Machine-image validator preparation

Before native compiler execution, check_compiler_image.py reuses independent
complete standard runtime/entry/arena checks and identifies the unique full
394-byte compact module by GNU PIC equality. Seven external entries anchor to
independent NUM/MEM/ACT exports; two pool ranges/initial zeros, four error-wrapper
ranges and compact/STR adjacency receive explicit checks. The wrapper ranges
are not a semantic proof; native differential regressions remain required.
image-validator-001 passes the existing native helper image and rejects separate
one-byte internal-PIC, numeric-entry and zero-pool corruptions for the intended
assertions. Corruptions are never executed. This uses no BASIC parsing/address
calculation on the host. Packed-source-001 validation continues independently;
no actual compiler image or native fit result is yet claimed.

## Controller termination during validation

packed-source-001 controller exits143/SIGTERM before a normal result is written;
its last logged state is validation phase2 after physical2000. No BBC diagnostic,
completed validation or output pass is reported. Origin of termination is not
established. Preserve raw console, exact source/driver/script, measured layout
bound and explicit interrupted disposition; previous output remains unchanged.
Do not count this as a successful compiler, memory failure or native fit result.

The resource controller now mirrors actual SOURCE progress onto stdout, records
SIGTERM promptly and retains normal failure metadata when it can unwind. Start
packed-source-002 through a live tee and poll the tool session itself regularly.
Target6597a0df and the entire BBC driver are byte-identical to the interrupted
run; only host orchestration changes. The new signal path is prepared, not a
claimed tested interruption recovery. Native compiler generation remains open.

Apply early input/stage persistence, host-only liveness messages and SIGTERM
recording to the prepared C006 bootstrap controller too. Syntax checks pass;
normal and interrupted generation paths are not yet exercised. These changes
never edit the BBC target/source/main or substitute a source compiler.

Prepare one native self-source/RAM preflight mode in C006 bootstrap.py, accepting
only a completed source/image-matched C005 resource run. It uses the normal
native UI and exact byte comparison, explicitly records that no unmodified
interpreted main stage ran, and does not replace the full default generation
chain. Syntax checks pass; actual native execution is still pending image output.

## First complete compiler image and Olimex coordination

packed-source-002 completes all three BBC passes in3911.701 controller seconds,
same exact6597a0df source/5f365395 driver and324275-byte layout. Image SHA
299a31190c380541a73ed9eb144a303fa37abccc4f3c3e0ad47f99f1538122c0 passes
independent full runtime/entry/heap/arena and compact PIC/bridge/pool/placement
checks. Retain image, logs and storage lower bound. Start C006
packed-native-preflight-001 through normal native filename prompts; no native
self-compilation result is yet claimed. This does not replace the default full
generation chain.

The Author directs consultation with Extender for Olimex time, file transfers
and remote CLI access. Send the request to Extender2026-10-13Sol and record
canonical mailbox2026-11-03_02-31-54_bbc-basic_bbc-olimex-access-request-one.
Read the shared physical-bench lease protocol and staged-transfer decision.
No lease, target access, reset, flash, deployment or physical result yet exists.

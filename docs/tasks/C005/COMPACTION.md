# Native compiler size and private storage closure

The exact source now reaches the real Agon executable boundary. Streaming removes
per-reference output storage, but cannot make an oversized compiler executable or
its tables fit. Reduce generated code and bounded private state while preserving
BBC values, side-effect order, errors and output. This is C005 resource work;
C006 still requires a functioning native compiler and generation evidence.

## Measured starting point

1. Exact508a74f2 completes its source-body layout at390190 bytes, with1376 symbols.
   Its final runtime/DATA emission reaches458752 bytes and rejects at physical
   2182,column67. Final counters1972 symbols,208 definitions,248 bindings. The
   prior output is preserved; no executable is generated. Actual controller time
   1322.639s; source, host driver, pins, progress and result are retained in
   `evidence/stream-source-002`. No native fit or unlimited-RAM result is inferred.
2. Private arrays also need space beyond code. The first three symbol arrays
   request4096*(5+4+4)=53248 element bytes, and referenced-line bitsets16384 bytes.
   Other arrays/templates/string contents and the32768-byte activation arena add
   to that demand. These are representation-based bounds, not measured native
   allocations. The earlier fixed256-byte string-element assumption is withdrawn:
   actual string-array elements are five-byte descriptors plus owned contents.

## Private table widths

1. Keep source program integers32-bit, numeric variants40-bit and ordinary string
   descriptors. Use existing BBC byte arrays only for private fields whose full
   admitted range fits0..255; retain wider fields and signed sentinels.
2. Formal binding indices par:0..255; staged argument kinds:0/1; staged argument
   slot indices:0..31; formal counts:0..16; PROC/FN kinds:0/1; variable payload
   sizes:1/3/4/5; remembered array arities:0..16; return-owner indices:0..255.
   The existing binding, temporary, argument, dimension and definition guards
   establish those bounds before the corresponding writes.
3. Changing these eight arrays from % to & saves19968 element bytes in a native
   compiler, without changing any public BASIC representation. Preserve source
   positions and compile outputs. Qualify fresh reference/native behavior,
   complete old-image identity and boundary metadata before promotion.

## Code reduction boundary

1. Repeated register setup, binding copies, numeric operation adapters, array
   calls, activation calls and source-line marks dominate emitted instruction
   sequences. A native CALL may share that setup in a small runtime adapter and
   carry fixed operands immediately after the CALL, as the existing numeric
   literal adapter does. Control flow remains actual eZ80 calls/jumps; do not
   introduce a BASIC token parser, bytecode execution loop or interpreter engine.
2. Preserve the existing reference arithmetic/conversion entries. In particular,
   any shared integer-store adapter must call the same SFIX entry before copying
   the four-byte payload, preserving failure ordering and destination state.
3. Specify each adapter's input fields, consumed return-address bytes, registers,
   flags, stack balance, relocation/bridge slots and error transfer before use.
   Independent native ABI probes must cover guards and boundaries; actual BBC
   differential programs must cover arithmetic, LOCAL/FN caller prefixes, arrays,
   source errors and output preservation. Changed code sizes require fresh fit
   measurements; no predicted saving is a test result.
4. Compacting zero-filled runtime-template DATA is also a possible private-source
   storage change, provided loaders/emitters reconstruct the exact old template bytes and
   packers/GNU links prove identity. It does not authorize changing user DATA.

The task record and dated log own results and promotion. This contract records
implementation boundaries, not a second unfinished-work list.

## Private byte-table and adapter results

Candidate558c39a9 changes only those eight array suffixes. Four complete old
images remain identical in smoke54.599s. The first boundary fixture accidentally
exceeded the existing expression-depth cap; its failed/compile-only artifacts
are retained, without a native-pass claim. The corrected five-source cohort
passes340.239s: four native executions, formal binding255, return owner255 /
256 definitions, staged slot31 through shallow nested calls,257 rejection,
repeat and GNU numeric links. Mixed numeric/byte/string PROC arguments, LOCAL,
recursion, slices and string-FN consumers also pass two-program86.522s scope,
with fresh actual BBC outputs and GNU numeric/string links. Full baseline follows.

The separate compact/runtime.s module is394 bytes /29 internal relocations,
with13 native entries and13 external fields. GNU links at&42000/&48000 match
rebasing. Native ABI21 passes with real unchanged NUM and explicit MEM/ACT
observation stubs; no frontend integration is yet claimed. ABI.md records exact
fields, registers, SP, error balance and fixture corrections. Actual pinned BBC
packets, not a Python numeric model, corrected an initially misencoded fractional
test value. The runtime itself did not change during those fixture corrections.

Exact byte-table source558c39a9 also passes baseline39/15 in86.246s with GNU
golden and repeat (`byte-tables-baseline-001`). `compact/maps_harness.py` prepares
a host-only observer that has the actual BBC compiler write its completed label
addresses to a map file. It observes tables rather than compiling source or
calculating addresses on the host. Only its guarded Python preparation has run;
no map-based frontend qualification is claimed yet.

## Prepared BBC adapter integration

`compact/integrated.bas` SHA f8d46de6 has2244 ordered lines,213 distinct routine
names and254 static private identifiers. It replaces numeric literals, adjacent
NUM setup/calls, scalar reads/stores, PROC begin/save/bind and array prefix/address
setup with native calls and fixed operands. Original FOR/DIM register setup and
DIM's HL allocation-context ABI stay intact; the existing err_line ABI also stays.
The additional module has no interpreter state or source execution engine.

Its first two actual-reference/native programs pass54.011s: typed scalars,
fractional SFIX/byte wrapping and numeric/string arrays. Repeat, GNU NUM/STR
links and full compact-module PIC/bridge equality pass. BBC itself emits completed
label maps; Python uses those maps only to verify linked runtime bytes, never to
compile BASIC or calculate program addresses from source. Exact source, maps and
links are frozen in `compact-frontend-smoke-001`. The broader nine-source cohort
is active; no native compiler size/fit is inferred yet.

## Scalar string heap placement corrected

The first f8d46de6 nine-source batch compiles all inputs but fails native mixed
PROC values/restoration. The module's own bytes and bridges match GNU, but its
base&4427B equals the scalar string heap start. STR's non-memory-mode heap is
reserved by aliases without advancing cpc; placing new code after it lets string
assignments overwrite code. `compact-frontend-mixed-failure-001` retains the
actual wrong output, all images/maps and source before correction.

Move the adapter before STR runtime/pools/virtual heap, keeping all later workspace
reservations last. Check adapter end against $sheap and $actbase through the
actual BBC maps. Corrected2f81c6fb passes nine programs/native executions122.399s
with actual reference outputs, repeat, GNU NUM/STR and complete adapter PIC /
bridge equality. This includes mixed numeric/byte/string PROC restoration,
slot31, string-only omission and expected division/missing-variable/SFIX/bounds
failures. The full baseline and source-error qualification follow.

## Compact frontend qualification checkpoint

Exact isolated2f81c6fb passes baseline39/15 in87.971s, including deterministic
repeat and GNU golden. Source-error CORE6 passes143.390s and remaining33 pass
549.218s: all39 fresh reference outputs and ERR/ERL match, repeat and independent
runtime/entry links pass. Evidence compact-baseline-001, compact-errors-core-001
and compact-errors-tail-001 preserves exact compiler/source/runtime identities.
Two identical consumer inputs shrink complete executables by98 and325 bytes,
including the394-byte shared adapter; these are size comparisons, not speed
benchmarks. Actual self-source fit is still unproved and live7cac4bba is unchanged.

## Private control-template zero tail

Prepared14e56cee derives from2f81c6fb without changing source-program behavior.
The control runtime remains8657 bytes with30 relocations and256 typed records;
its465-byte initialized prefix is stored, and its8192-byte all-zero frame tail
is streamed during emission. All relocation operand fields and the numeric
bridge field precede that tail; full-relative relocation values and exported
frame/end addresses retain their original meaning. Layout counts the full image,
validation reads only backed prefix bytes, and output emits the complete image.
The private loader allocates465 rather than8657 raw bytes. Assembly links still
prove the unchanged complete control template at independent bases. No user DATA
format or runtime capacity changes. The generated source is19104 bytes shorter;
this source-text saving is not a measured executable saving or native fit result.
Actual BBC/native image-identity qualification follows the active2f source probe.

## Completed layout and next private-storage boundary

compact-source-001 completes2f81c6fb layout339291 bytes with2078 symbols/213
routines/254 bindings. Its private heap has86437 bytes; storage_bounds.py's
handwritten, source-pinned declaration inventory proves112761 payload bytes
before headers/string contents. The run is deliberately stopped after layout
and beginning validation in1366.536s; old output survives, no image/native
initialization is claimed. Raw interrupted logs and explicit disposition remain.

Zero-tail14e56cee passes all nine real-reference/native cases118.267s, full GNU
adapter/standard checks, repeat and complete image equality with2f81c6fb. Its
minimum private payload bound is104569 bytes; this alone is not a fit proof.

Private symbol addresses are0..B0000 and can use exact three-byte raw cells;
sorted insertion indices are0..4095 and can use exact two-byte raw cells. Keep
4096 entries, sorted lookup/insertion order and all address/layout checks. BBC
getters/setters must operate only inside backed cells; no wide over-read or
24-bit replacement of source-program integer values is permitted. These two
representations save12288 payload bytes before added compiler code is measured.

Referenced numbered targets retain separate branch/DATA sets covering0..65279.
A64-entry pointer table can own256-byte pages, each covering2048 numbers. Allocate
and explicitly zero a page on its first write; a read of an absent page is false.
At every subsequent compile, zero already allocated pages and retain their
pointers for reuse, so repeated compilation cannot leak a new set of pages. Full
occupancy remains bounded at16384 page bytes plus256 pointer bytes; sparse use
saves storage without reducing the accepted numbered-target range. Qualify page
boundaries, top line65279, branch/DATA separation and repeated clearing, complete
image equality, all symbol-capacity guards and actual native fit before promotion.

Packed6597a0df has2067 lines/219 routines. Native execution of the exact private
helpers passes4096-cell/64-page/canary/reuse fixture262.754s, with actual BBC
output and independent complete runtime/entry/adapter checks. Nine ordinary
native integrations pass123.659s and all complete2f images remain identical.
The earlier host map dumper error is frozen as observer-only failure. Five
numbered-target cases/three native58.636s cover2047/2048/65279 and both domains,
plus explicit zero-label behavior and two undefined-target rejections. A failed
zero-line reference loader fixture remains separately recorded; conventional
oracles use positive line numbers. Baseline39/15 passes56.360s, GNU golden/repeat.
Initial zero-page payload lower bound76153 excludes headers/string contents and
later page allocations. Optional BBC-only source-probe observations count actual
pages and string lengths after layout; those lengths remain lower bounds on
native allocation capacity, not an initialization/fit result.

Promotion packaging is rehearsed in an isolated tree: a prepared live compact
packer, control-prefix/full-image selection and error-table suffix preservation
regenerate exact6597a0df. All nine individual packers preserve it, every complete
runtime matches its earlier binary, and changed control/error packers preserve
old7cac4bba too. promotion-preparation-002 retains exact staged tools and results.
This supplies packaging evidence only; live source stays unchanged pending fit
and remaining qualification.

Actual packed-source-001 layout is324275 bytes,2094 symbols/219 routines/254
bindings. Observed pages7, symbol contents13948 bytes and other metadata strings
5473 give97366 mandatory/observed bytes against101453 available, leaving4087
before remaining overhead. This is not native fit proof. The controller later
exits143/SIGTERM during validation, with origin unknown; no output pass/image.
Retain interrupted evidence and restart identical source/driver aspacked-source-002
with live host progress, regular session polling and signal/input recording.

Identical packed-source-002 completes all three passes in3911.701 controller
seconds, producing324275 bytes SHA299a31190c380541a73ed9eb144a303fa37abccc4f3c3e0ad47f99f1538122c0.
Its complete standard runtime/entry/heap/arena checks and compact GNU PIC,
seven independent bridge anchors and explicit pool/wrapper/placement checks
pass. Exact source6597a0df and driver5f365395 are retained with console, image,
controller output and storage inventory. This proves interpreted source
compilation and machine-image structure; native self-source/RAM preflight is
running separately under C006. No physical result or full generation chain is
claimed, and live source remains7cac4bba.

C006 packed-native-preflight-001 completes native self-source compilation through
normal prompts in1983.653 controller seconds, MOS status0. Its entire324275-byte
G1 equals the interpreted resource seed SHA299a31190c380541a73ed9eb144a303fa37abccc4f3c3e0ad47f99f1538122c0.
Exact6597a0df source and source/seed/output/console/controller identities are
retained. Actual native initialization, source metadata/storage and all output
passes fit; the lower-bound estimate is no longer the sole resource evidence.
This preflight did not run unmodified interpreted main and does not replace the
full default four-image chain, native regressions or physical qualification.
No hardware or performance benchmark result is claimed.

Prepare compact/promote.py as a guarded development promotion operation. It
verifies retained manifests for native source preflight, packed baseline/helper/
integration, all39 error cases and large-output/symbol capacity before copying
exact6597a0df plus the rehearsed compact runtime and three packers. It then runs
REPORT/nine module generators and requires unchanged source after each and all
complete module hashes equal the rehearsal. No emulator, Git or hardware action
is inside it. Syntax checks pass; actual promotion awaits pending cohorts.

Packed source-error CORE6 passes149.768s and remaining33 passes585.087s:
all39 fresh reference outputs/ERR/ERL match, deterministic repeat and complete
standard-runtime/entry links pass. packed-errors-core-001/tail-001 retain exact
6597a0df inputs/results. compare_errors.py verifies retained manifests and
identical source/oracle plus every complete emitted image against the earlier
2f81c6fb cohorts; packed-error-equivalence-001 passes all39. These are controller
durations and retained-byte comparisons, not hardware/performance measurements.
Large-output/symbol-capacity qualification is active; live7cac4bba is unchanged.

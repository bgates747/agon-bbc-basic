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
   storage change, provided loaders reconstruct the exact old template bytes and
   packers/GNU links prove identity. It does not authorize changing user DATA.

The task record and dated log own results and promotion. This contract records
implementation boundaries, not a second unfinished-work list.

# Bootstrap resource closure design notes

The current interpreted-host headroom measurement does not prove that the native
compiler can fit beside its own metadata and output. The next actual self-source
probe, after language closure, must measure generated size, symbols, fixups and
RAM. This note records a possible bounded streaming emitter if those measurements
require it; no streaming implementation or size result is claimed.

## Current constraints and proposed boundary

1. The live emitter owns a65536-byte output buffer plus4096 fixup records. Native
   self-compilation must share Agon RAM with the executing compiler, its metadata,
   private string/activation workspace and embedded templates. Enlarging both
   tables blindly is not a resource proof. The prepared DATA frontend statically
   has242 private binding candidates and187 definitions; this is only an inventory.
2. A measured need can justify layout, validation and output passes, all in BBC
   BASIC. Layout builds the symbol/address map without buffering code or storing
   per-reference fixups. Validation resolves all references before the destination
   is opened. Output emits exact bytes directly through BPUT. Reset parser/counters
   deterministically on each pass and verify layout identity.
3. Repeated labels must look up the existing symbol and verify its final address.
   Current helper exports overwrite `csaddr%(csnum%-1)` after PROClabel; they must
   instead use the actual resolved label index. Export aliases, heap endpoints and
   entry trampolines need explicit address definitions so pass validation compares
   final values rather than an intermediate cpc address.
4. Templates need emission-time rebasing and bridge substitution. Current numeric,
   control and activation emitters copy bytes then patch the buffer; control and
   activation also rewind cpc for external bridge operands. A common BBC emitter
   can walk sorted internal relocation offsets and fixed bridge slots and emit
   final24-bit operands directly. Do not use a host compiler or an interpreter
   engine to avoid this work.
5. Preserve transactional compile validation and exact existing executable bytes.
   Check source/output failure paths, malformed programs, repeated compilation,
   symbols/addresses across passes, all template GNU links and representative
   complete old images. Streaming is an implementation/resource change, not a
   BBC language extension or permission to change observable output.
6. Measure the resulting native compiler's actual heap/arena/code limits. If it
   cannot hold its own binding/symbol tables and owned strings, refine storage
   with measured evidence before claiming C005 closure or C006 self-hosting.

## Static numbered-line pressure before the next source probe

The prepared source has1958 numbered lines, exceeding the1024-symbol cap before
counting its emitted control/variable/runtime labels. PROCnumberlabel currently
creates a symbol for every numbered line. This is an explicit static gap, not a
measured native image result. A BBC prescan can collect numeric GOTO/GOSUB targets
and retain addresses only for referenced numbered lines, while still validating
all source numbers/order and named-label duplicates. RESTORE targets remain a
separate DATA address map. Qualify forward/backward/nested branches, missing
lines and unchanged old images; do not silently drop a valid branch target.

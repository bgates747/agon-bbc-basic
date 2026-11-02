# Runtime and tool investigation

Dean Belfield's arithmetic package is the strongest reuse candidate. String,
variable and procedure code is closely coupled to interpreter parsing and
memory state and needs adaptation. C001 extracted no interpreter runtime.
C002 isolated and qualified the newer BASIC V math package. It is now emitted
for numeric VDU, default numeric PRINT and standard unary math functions from
`compiler/runtime/`; other numeric
source features remain partial or unsupported in the compatibility matrix.

## Inspected sources and provenance

1. [Dean Belfield's ADL port](https://github.com/breakintoprogram/agon-bbc-basic-adl/tree/3901c2de520c3e9f96ad6f5f0ad9aaec3663e65f),
   commit `3901c2de520c3e9f96ad6f5f0ad9aaec3663e65f`. Inspected `fpp.asm`,
   `eval.asm`, `exec.asm`, `main.asm`, `ram.asm`, `patch.asm`, `init.asm`,
   `README.md` and `COPYING`. Downloaded into `/tmp/bbc-compiler-reference`;
   the pinned links remain usable when that temporary checkout disappears.
2. This repository's interpreter baseline is
   `2998edd4ceb6030d6840cb4e3d587e75d94dc44c`. Inspected
   `include/bbc-ez80/{MATH,EVAL,EXEC,MAIN,DATA}.Z80`, `src/agon_init.s`,
   `src/agon_os.s`, `config/linker.conf`, `Makefile`, `license.txt` and existing
   conformance tests. This is a newer BASIC V implementation and must not be
   assumed identical to Dean's BASIC IV-derived port.
3. Official local platform references:
   `/Agon/agon-docs/docs/mos/API.md`, `mos/Executables.md`, `Programming.md`
   and `BBC-BASIC-for-Agon.md`. The API requires `RST.LIS` for MOS restart
   handlers. Wide ADL loads/stores transfer three bytes; an address and a BASIC
   integer must have different storage contracts.
4. Examined [agon-ez80asm](https://github.com/AgonPlatform/agon-ez80asm), its
   local README and Makefile, the repository's AgonDev GNU assembly build,
   and Fab's CLI source and build. Dean's original project uses proprietary
   ZDS II project files. AgonDev can build the current interpreter on Linux;
   ez80asm can run natively on Agon. The initial compiler emits binary directly
   to avoid an assembler dependency on the target. GNU assembly is retained
   as an independent opcode/relocation oracle for tests.

## Arithmetic: `fpp.asm`

1. The source defines a 32-bit sign/magnitude normalised mantissa and an
   eight-bit excess-128 exponent for floats; the implied top mantissa bit is
   replaced by the sign. Integer mode is 32-bit signed two's complement with
   exponent byte zero. Preserve its existing packing and conversion routines.
2. `FPP` accepts an operation selector in A. The primary number occupies the
   low 16-bit portions of HL and alternate HL, plus exponent C. The secondary
   number occupies DE and alternate DE, plus exponent B. These are split
   32-bit quantities despite the 24-bit register width in ADL. `DLOAD5` loads
   a packed five-byte operand via IX; `DLOAD5_SPL` reads the package's expanded
   stack representation at offsets 0, 3 and 6 instead.
3. `FPP` saves IY and uses it to recover SP on its internal error path. It
   returns Z and carry clear on success; carry set/NZ and an error number in A
   on failure. Treat the ordinary/alternate arithmetic registers and flags as
   clobbered. The wrapper must save caller-owned index/register state as
   needed and consume the result before another runtime call.
4. The pinned Dean package contains its own numeric helpers and tables and
   declares no `XREF` imports. Its apparent isolation is source-level evidence,
   not proof that arbitrary internal entries are callable. In particular,
   calling an internal arithmetic entry that reaches `ERROR_` without the FPP
   entry frame would restore SP from an invalid IY.
5. The newer local `MATH.Z80` instead declares `STORE5`, `DLOAD5` and `TEST` as
   external imports from execution/evaluation modules. Adapting that version
   requires bringing or replacing those helpers and auditing their register
   and stack assumptions. The versions also differ in operation tables and
   optimisations; copying a selector number from a different version is unsafe.
6. C002's actual standalone link found two additional undeclared dependencies,
   `STORE5_SPL` and `DLOAD5_SPL`, for seven-byte sparse stack layouts. Its
   adapter supplies all five helpers plus required assembly macros; no
   interpreter globals remain unresolved. See the qualified
   [numeric ABI](../docs/tasks/C002/ABI.md) and
   [provenance](runtime/vendor/PROVENANCE.md).
7. Direct byte checks confirm FONE encodes 1.0 with exponent 128 and exact
   halfway addition uses the package's ODD behavior, not IEEE ties-to-even.
   The reference constant reader also stores `4294967296.0` differently from
   `2147483648.0*2`. The compiler must preserve that distinction. Its BBC
   literal scanner delegates conversion to host VAL, which uses the same CON
   path, and copies the exact packed result. Source VAL remains unsupported
   in compiled programs; implementing its string-pointer runtime belongs to
   bootstrap closure. See [literal compatibility](../docs/tasks/C002/LITERALS.md)
   and the separate [interpreter research record](INTERPRETER-FINDINGS.md).

8. Numeric output calls the package's STR entry through a separate pointer
   ABI: IX supplies private format control and DE supplies an output buffer.
   The interpreter's usual numeric pointer adapter cannot supply that contract.
   The new formatter needs neither STAVAR nor the page-aligned ACCS global;
   it calculates length from full ADL pointers and appends NUL explicitly.
   Its private 32-byte scratch serves PRINT only, without string-variable
   ownership or allocation. See [output qualification](../docs/tasks/C002/OUTPUT.md).

## Strings, variables and memory

1. Dean's `LOADN`/`LOAD4` in `eval.asm` use a type code in A and variable
   storage through IX. `STORE`, `STOREI`, `STORE4` and `STORE5` in `exec.asm`
   perform type-sensitive storage and numeric conversion, calling SFIX when
   needed. Their four-byte data paths use byte accesses rather than treating
   one 24-bit register as the complete integer.
2. Dynamic string descriptors hold current length, allocated capacity and a
   three-byte pointer. `LOADS` copies into the page-aligned 256-byte `ACCS`
   accumulator and returns a string marker/length convention. `STACCS` and
   `STORES` consume that convention; `STORES` uses IX, HL, E, alternate HL and
   flags while updating descriptors. Strings are mutable and length-aware,
   with a maximum length of 255, not zero-terminated C strings.
3. `STORES` depends on `FREE`, allocation ordering and `CHECK`. Growing a
   non-tail string in Dean's version may abandon the earlier allocation; the
   source explicitly says there is no garbage collector there. The newer
   local BASIC V version has additional capacity optimisation. A compiler must
   choose and test its own allocation/ownership policy rather than inheriting
   accidental leaks as a calling convention.
4. `CHECK` compares heap end and execution stack with a guard margin and
   jumps into the interpreter error machinery. Dean uses a unified RAM stack;
   this repository also checks its separated system stack using `SPL` and
   `SPL_BOTTOM`. `ram.asm` / `DATA.Z80` supply heap bounds, variable tables,
   accumulator pages, error traps and procedure/function pointers. These
   cannot be left uninitialised in a standalone executable.
5. `GETVAR`, `PUTVAR` and `CREATE` in `main.asm` parse names via IY and depend
   on dynamic variable chains, type encodings and the interpreter heap.
   Compiled symbol resolution can remove this name-search work, while runtime
   binding slots retain the required type and LOCAL behavior. C003 now emits
   scalar byte/four-byte/five-byte payloads with separate existence flags and
   bytewise loads/stores. ASSIGN creates the destination before evaluating its
   RHS; STORE5 preserves the numeric variant. `%`/`&` stores reuse qualified
   SFIX. No interpreter variable lookup, heap globals or fixed entry addresses
   are linked. [Scalar qualification](../docs/tasks/C003/SCALARS.md) includes
   physical-memory comparison and keeps LOCAL explicitly unimplemented.

## Procedures, functions and LOCAL

1. Dean's `FN`/`PROC` at `exec.asm:942` onward parse definitions and arguments,
   maintain `FNPTR`/`PROPTR`, manipulate token pointers and install stack
   markers. These routines enter the interpreter dispatch path, not an
   ordinary native function ABI.
2. `LOCAL_` examines activation markers, calls `GETVAR` and saves prior values.
   `SAVLOC` parses formal variables via IY and manipulates return addresses,
   numeric values, types and string bytes on the stack. The routine documents
   destruction of general registers, index registers, flags and SP. Exit paths
   restore prior bindings rather than merely discarding new local slots.
3. Dean's `FNEND` family and the newer local `RESLOC`/`SAVLOC` are separate
   implementations. Both illustrate the behavior to preserve, not a block to
   copy without its parser, heap, trap and marker dependencies. A compiled
   activation stack needs explicit save/restore records and distinct PROC,
   FN, GOSUB and error-unwind handling.

## MOS and licensing

1. Dean's `patch.asm` adapts BASIC OS calls to MOS/VDP and includes console
   state, file handles, OSBYTE behavior and initialisation. `init.asm` preserves
   the caller stack and registers and installs the MOS header. Most generated
   runtime calls should use documented MOS APIs directly instead of depending
   on undocumented interpreter addresses or its installed interrupt state.
2. Dean's `COPYING` grants use, modification and redistribution under the
   zlib-style terms: retain the notice, do not misrepresent origin, and plainly
   mark altered sources. His README states that his additions use the same
   terms and that other-source material is separately credited. This
   repository's `license.txt` has the equivalent restrictions with its own
   copyright date. Before actually vendoring a routine, retain its precise
   notice and source attribution and record the adaptation. No upstream
   copyright notice has been replaced by the new compiler's files.

Numeric extraction, differential qualification and mutable-runtime design
remain in [TODO.md](../TODO.md).

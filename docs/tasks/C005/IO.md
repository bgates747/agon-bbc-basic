# File and console I/O implementation contract

The native compiler must read source files, write executables and use its actual
interactive filename prompts. This contract audits the pinned interpreter's MOS
bridges before adding standalone I/O; it is not evidence that I/O is implemented.

## Reference audit and dependency boundary

1. EVAL.Z80 OPENIN/OPENOT/OPENUP uses ITEMS (one string item), appends CR and
   calls OSOPEN. `src/agon_os.s` maps modes to read1, write/create-always10 and
   read/write-existing3 using the installed FatFS flag definitions. Verify the
   numeric flag values from the reference includes before coding. Return is the
   MOS handle byte,0 on failure; no new compiler error should replace that value.
2. EXEC.Z80 CHANEL requires `#`, evaluates ITEMI/SFIX and selects the low byte.
   OSBGET/OSBPUT/OSSTAT/OSSHUT call MOS fgetc0C/fputc0D/feof0E/fclose0B directly.
   BGET returns the byte, ignoring carry. EOF is true only when MOS returns1.
   CLOSE discards the MOS result. Preserve channel wrap and invalid-handle
   behavior established by actual probes, rather than inventing Channel errors.
3. Numeric BPUT evaluates channel before the full RHS, then SFIX/low-byte output.
   String BPUT writes its explicit length, including NUL; absent trailing `;`
   adds LF, while numeric output adds none. Arguments and pending values must
   survive RHS FN calls. Direct FN filename carriers require qualification:
   OPEN_ uses the complete DE terminator pointer, unlike BPUTS's length-only path.
4. `include/macros.inc` uses RST.LIL08 for MOS APIs. Preserve the documented
   IX/IY/SP contract explicitly; never call an interpreter entry/global. A
   private256-byte filename buffer can copy up to255 payload bytes plus CR.
   Do not append a terminator beyond a length-prefixed256-byte expression buffer.
5. INPUT LINE's reference path calls VAR before reading, prints `? ` only when
   no explicit prompt suppresses it, and uses MOS editline09 with a256-byte
   buffer and E=1 (clear). OSLINE converts NUL to CR and prints CRLF; full-line
   input stores the entire line. Start with one scalar string destination and
   literal prompt, matching the actual compiler source. Other forms stay explicit.
6. The installed CLI source `agon-cli-emulator/src/main.rs` injects stdin lines
   as VDP key events and CR, separated by a second. This can drive real MOS line
   editing without a fixed-input native compiler wrapper. Qualify the actual
   prompt/input path; do not replace the compiler's main program for C006.

## Qualification before promotion

1. Record actual pinned-BASIC observations for open failure, empty/binary/text
   reads, EOF transition, handle wrap/invalid handles, repeated close, truncation,
   write failure, string output terminators and RHS effects. Preserve backend
   quirks; a local MOS source checkout is an audit aid, not proof of ROM behavior.
2. Compare generated file bytes and console output, with exact fixture/source/MOS
   hashes. Test open/close cleanup and source/output failure preservation. Native
   helper ABI probes must check guards, maximum filenames and register/stack state.
3. Exercise scripted keyboard input through the canonical CLI wrapper and verify
   prompts, empty/maximal strings, line endings and supported error behavior.
   Escape/interactive editing needs its own evidence before a broad claim.

## Standalone helper ABI before implementation

1. All entries preserve IX/IY/SP. AF/BC/DE/HL are volatile; synchronous private
   scratch is allowed. APIs use RST.LIL08; character output uses the already
   qualified RST.LIS10 path. The pinned MOS fputc preserves BC/DE/HL as its
   assembly wrapper explicitly saves them; the bounded string loop depends on
   that API contract. No BASIC parser/global or interpreter entry is called.
2. `io_open`: IX=five-byte numeric destination, IY=read-only length-prefixed
   string, A=FatFS mode1/3/10. Copy into a private256-byte filename buffer and
   append CR. Return handle0..255 as an integer packet, A0/Z/NC. A zero handle
   is an ordinary language result. Preserve input/guards even for length255.
3. `io_get`/`io_eof`: A=low-byte handle, IX=numeric packet. Call MOS directly;
   write a byte integer or -1/0 Boolean (only MOS1 means EOF), exponent0. Return
   A0/Z/NC. `io_close` forwards A; `io_put` forwards A=handle,B=byte. Their
   return is A0/Z/NC; do not invent channel/write errors absent from reference.
4. `io_puts`: A=handle, IY=string, C=append-LF flag0/1. Write exact logical bytes,
   including NUL; skip zero-length transfer and append LF only when requested.
5. `io_input`: IX=256-byte expression buffer. Use a separate256-byte raw line
   buffer with MOS editline09/BC256/E1; copy up to255 bytes and print CRLF.
   Success A0/Z/NC. Escape returns A17/NZ/C after CRLF; caller must leave its
   destination descriptor unchanged. This API does not implement the language
   prompt or variable binding; the BBC frontend owns their evaluation order.

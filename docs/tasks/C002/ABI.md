# Experimental numeric adapter ABI

The adapter operates on BBC BASIC's packed numeric values without requiring a
resident interpreter. It is the qualified interface for the compiler's
numeric runtime, now used by numeric VDU/PRINT expressions and standard math
functions. Formatting has its own pointer interface, described below.

## Entry and value representation

1. Entry symbol: `rt_numeric`, eZ80 ADL mode. A contains an operation selector;
   IX points to the writable left/result value and IY to the right value.
   Both point to valid five-byte records, even for unary conversions.
2. Bytes 0..3 hold the little-endian payload and byte 4 the exponent/type byte.
   Exponent zero denotes a signed 32-bit integer payload, including zero. A
   nonzero exponent denotes the package's BBC floating-point representation:
   sign replacing the implicit leading mantissa bit, 32 significant bits and
   an excess-128 exponent. This is the package's mixed numeric value record;
   it is not a three-byte ADL integer or an IEEE float.
3. On success the adapter writes exactly five result bytes through the original
   IX. A=0, Z=1 and carry=0. On error the original left value is unchanged;
   A is the package error code, Z=0 and carry=1. Unsupported selectors return 1.
4. IX, IY and SP are preserved. Other ordinary/alternate registers and flags
   outside the stated status contract are volatile. The adapter clears upper
   bytes before loading each split arithmetic operand. It has no mutable
   global state; temporary values live on the native stack.
5. The right value is unchanged unless it is exactly the same record as the
   left/result. Exact aliasing (IX=IY) is supported. Partial overlap and
   malformed numeric encodings are outside this initial contract.
6. Entry always goes through `FPP`, whose IY-backed error frame restores its
   internal stack on failure. Calling internal package arithmetic labels
   directly would bypass this protection and is not the public interface.

## Exposed selectors

| Selector | Operation |
| --- | --- |
| 0 | AND |
| 1 | DIV |
| 2 | EOR |
| 3 | MOD |
| 4 | OR |
| 5 | <= |
| 6 | <> |
| 7 | >= |
| 8 | < |
| 9 | = |
| 10 | multiplication |
| 11 | addition |
| 12 | > |
| 13 | subtraction |
| 14 | power |
| 15 | division |
| 16 | ABS |
| 17 | ACS |
| 18 | ASN |
| 19 | ATN |
| 20 | COS |
| 21 | DEG |
| 22 | EXP |
| 23 | INT (floor) |
| 24 | LN |
| 25 | LOG |
| 26 | NOT |
| 27 | RAD |
| 28 | SGN |
| 29 | SIN |
| 30 | SQR |
| 31 | TAN |
| 35 | PI |
| 38 | convert to integer using the package's SFIX semantics |
| 39 | convert to floating point using SFLOAT |

Selectors follow the pinned BASIC V table, not a different release's table.
Unary operations, PI and conversions ignore the value of the required right record. SFIX is qualified
against integer assignment; it must not be substituted for floor-valued INT.
Internal constants 32..34 and other selectors, including VAL/STR pointer
interfaces 36/37, are deliberately rejected. The expanded interface passed
449 packed-result/error/structural comparisons. ABS(INT_MIN) retains the
reference's integer wrap behavior; no extra promotion is silently introduced.

## Formatter and numeric PRINT interfaces

1. `rt_format`: IX points to a read-only five-byte value; IY points to a
   writable, nonoverlapping buffer of at least 32 bytes. Success returns
   A=0/Z/NC, HL=the native 24-bit character count (0..31), with a NUL byte at
   buffer[length]. IX, IY, SP and the numeric input are preserved. Other
   registers are volatile. Error returns A=code/NZ/C; output text/length are
   unspecified, while input/pointer/stack preservation remains the contract.
2. The adapter supplies a private four-byte default G9 control block and sets
   the FPP STR entry's actual IX=format/DE=output pointer arguments. It loads
   the value into split arithmetic registers without invoking the binary-value
   loader on the output buffer. FPP remains the protected entry/error frame.
3. STR's original interpreter caller uses a page-aligned string accumulator
   and treats E as its length. The new adapter computes the full end-pointer
   difference and explicitly appends NUL. It requires neither STAVAR nor ACCS.
   Qualification uses a buffer at page offset 251, text crossing the page,
   exact minimum/maximum float payloads, guard bytes, dirty register upper
   bytes, and pointer/SP/input checks: 45 cases match actual BASIC STR$ bytes.
4. `rt_printnum`: IX points to the value and A supplies the minimum field
   width (compiler emits 0 or 10). It formats through `rt_format` and emits
   padding/text using MOS character output. IX/IY/SP are preserved; A/Z/carry
   follow the same status contract. Other registers are volatile. Its private
   32-byte display buffer is reused by synchronous calls; no interrupt/reentry
   formatting interface is defined. There is no general mutable-string runtime.

## Internal helper and ADL contracts

1. Packed helpers `DLOAD5` and `STORE5` operate only on bytes 0..4; `TEST`
   examines the split 32-bit accumulator. All three are supplied locally.
2. Standalone linking also found two helpers not declared in MATH.Z80's import
   list: `DLOAD5_SPL` and `STORE5_SPL`. These read/write internal sparse stack
   values: low word at bytes 0..1, padding at 2, high word at 3..4, padding at 5,
   exponent at 6. The new load uses byte accesses and zeros register upper
   bytes; the store explicitly zeros both padding bytes.
3. New adapter accesses to values are byte-sized. Probe pointer and SP fields
   reserve exactly three bytes; their wide accesses are annotated `ADL24 OK`.
   The vendor package's dispatch table contains three-byte PTR entries and its
   native stack exchanges operate on three-byte register slots. No two-byte
   memory field is accessed with an unsuffixed wide register instruction in
   the new adapter or probe. Assembly listings are produced by qualification.
4. Minimal assembler macros are PTR, EXTRN, UEXT and UEXTA. A standalone symbol
   check requires zero unresolved symbols in the numeric object; a successful
   link does not depend on EVAL, EXEC, BASIC globals or the interpreter binary.

## Qualification and integration boundary

The BASIC oracle evaluates expressions and dumps its actual packed operand and
result bytes. Python never implements arithmetic, encoding or rounding. The
native probe reads the same operands, checks results/status, and verifies stack,
index pointers, adjacent canaries and the untouched right buffer. It deliberately
loads nonzero upper bytes into both register sets before every call.

Four independently stated expected encodings check precision and ties:

| Expression | Packed result bytes, hexadecimal |
| --- | --- |
| 16777216.0 + 1 | 80 00 00 00 98 |
| 2147483648.0 + 1 | 01 00 00 00 9F |
| (2147483648.0 * 2) + 1 | 01 00 00 00 A0 |
| (2147483648.0 * 2) + 3 | 01 00 00 00 A0 |

Here 1.0 has exponent byte 128, as the package's FONE entry confirms. The
two halfway cases select the odd low significand bit, as its ODD routine
specifies; they are not IEEE ties-to-even rounding. Both evaluate to 2^32+2.
The power-of-two operands avoid the reference parser's observed error reading the
large decimal literal `4294967296.0`; this discrepancy is retained in the task
evidence and is not a numeric behavior the compiler is committed to reproduce.

Comparing with the interpreter qualifies extraction and calling compatibility;
it is not independent mathematical verification of every vendor algorithm.
The numeric package currently occupies 3816 bytes including the expanded adapter/helpers
(the initial binary/conversion adapter package was 3812 bytes).
It includes private entries beyond the exposed interface; no dead-code pruning
has been performed. Numeric code is now included by the development compiler
for numeric expressions. The complete expression/output template is 4028 bytes,
adding literal-copy, unary-minus, formatting and display helpers. Runtime source and retained
notices are in `compiler/runtime/`.

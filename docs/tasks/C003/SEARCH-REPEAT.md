# String search and repetition

INSTR and STRING$ follow the actual BASIC reference, including low-byte
arguments and empty-search behavior. The compiler parses/emits these calls in
BBC BASIC; a small native adaptation operates on its private buffers. The qualified source is now promoted
to compiler/compiler.bas and compiler/runtime/strings.s; C003.md records exact
evidence and promotion. The full prototype suite and selected live checks passed; existing string/numeric regressions pass on the Pi5 CLI. The Author waived previous approval
stops and authorized completing the remaining TODO.

## Audited reference behavior

1. Baseline EVAL.Z80 INSTR/SEARCH (around 1424–1529) evaluates main string,
   needle string, then optional numeric start and SFIX. The start uses its low
   byte: 0 and 1 both select the beginning; otherwise subtract one for the
   zero-based offset. Omitted start selects the beginning. Out-of-range SFIX
   errors still occur when either string is empty.
2. SEARCH compares exact unsigned bytes, including NUL/high bytes, and returns
   the first full match at or after the selected start. INSTR returns an
   ordinary integer position 1..255, or zero. The reference handles overlapping
   candidate matches by restarting after the previous candidate's first byte.
3. Empty needle returns zero in this reference. SEARCH reads its first scratch
   byte, but after finding a candidate its remaining main length is at most
   254. DEC B changes an empty needle's length from zero to 255; CP B therefore
   always rejects the candidate. The adaptation returns zero directly and
   avoids reading an uninitialised byte; this preserves the result rather than
   introducing a modern empty-needle convention. The retained actual-BASIC
   audit confirms empty/maximum/start-boundary examples.
4. STRING/STRIN1 (around 1712–1743) evaluates count and SFIX before its source
   string. Count uses the low byte. It evaluates the string even for count zero,
   then returns empty. Count one copies the value unchanged; an empty source
   remains empty for every valid count. The limit is 255 logical bytes.
5. The reference repeats ACCS bytes until its page-length byte would wrap, then
   errors 19 (String too long). The adaptation prechecks the 16-bit product of
   two unsigned bytes with MLT, before changing the private expression buffer.
   This preserves successful data and error order while keeping failed buffers
   unchanged. Assignment only stores a completed successful expression, so
   original binding contents/ownership remain independent.
6. Parenthesised function arguments are expressions. INSTR returns numeric;
   STRING$ returns string and composes with slicing, conversion, comparison and
   nested functions. No alternative syntax or compound operators are added.

## Native ABI and dependencies

| Entry | IX | IY | A input | Result |
| --- | --- | --- | --- | --- |
| rt_strinstr | Read-only main length-prefixed buffer | Read-only needle buffer | Already-SFIX start low byte | A=integer position 0..255; flags volatile |
| rt_strrepeat | Writable private 256-byte expression buffer | Unused/preserved | Already-SFIX count low byte | A=0/Z/NC, or 19/NZ/C with buffer unchanged |

1. Both preserve IX/IY/SP; AF/BC/DE/HL otherwise volatile. Search operands may
   alias because neither changes. Buffers may cross pages. The source length
   and copy/search counts initialize all 24 bits; no zero-count LDIR/CPIR path
   is admitted. Repetition uses forward overlapping LDIR to extend the original
   pattern through bytes it has just copied, after the size check.
2. Reference interpreter parser stacks, ACCS alignment and ERROR entries are
   replaced with explicit buffers, native status returns and the compiler's
   saved-stack exit. The BBC compiler preserves STRING$'s evaluated count on
   its native stack while evaluating the string; all failures unwind through
   the existing saved-stack path. INSTR reserves an integer result before its
   optional start expression, preserving other pending numeric/string values.
3. The former 369-byte string runtime remains an exact prefix. New code is
   164 bytes; the 533-byte template has two actual internal 24-bit relocations
   (search helper call and overflow branch). The BBC compiler rebases these;
   the packer checks independent GNU links at &42000/&48000. Numeric runtime,
   vendor math and license are unchanged. No interpreter binary is required
   by generated programs.
4. Adaptations are marked in strings.s and retain the repository's zlib-style
   license/provenance. They are not unmodified interpreter entries. The packer
   adds --output for isolated task builds, without compiling BASIC source.

## Reproduction

Use the project Python and run these sequentially through the Pi5 CLI fixture.
Pi5 CLI work is reauthorized; Oryx remains unavailable.
Qualification is separate from graphical/hardware
review, commit approval and main acceptance.

```sh
.venv/bin/python compiler/tools/build_strings_runtime.py --compiler compiler/compiler.bas
.venv/bin/python docs/tasks/C003/tools/test_search_repeat.py --cli /tmp/bbc-compiler-cli-target/release/agon-cli-emulator
.venv/bin/python docs/tasks/C003/tools/test_search_repeat_abi.py --cli /tmp/bbc-compiler-cli-target/release/agon-cli-emulator
.venv/bin/python docs/tasks/C003/tools/test_string_storage.py --search-repeat --cli /tmp/bbc-compiler-cli-target/release/agon-cli-emulator
```

Exact sources, measured durations, evidence and promotion are recorded in
C003.md and the dated development log after qualification. Slice assignment
and remaining facilities stay in the sole TODO; C003 is not complete yet.

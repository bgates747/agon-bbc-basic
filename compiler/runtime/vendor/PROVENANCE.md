# Numeric package provenance

The experiment reuses an unchanged snapshot of the repository's BASIC V math
package and supplies the missing runtime helpers in a separate adapter. The
original license and copyright headers are retained.

1. Source repository baseline: `2998edd4ceb6030d6840cb4e3d587e75d94dc44c`,
   file `include/bbc-ez80/MATH.Z80`. Copy: `MATH.Z80` beside this document.
2. Math SHA-256:
   `1f92ffc352b22051ff77f0a48d206d04012fb5e404c0a70e47d76342ce7aece3`.
   The source's version history identifies FPP 5.1 operation selectors; its
   original Richard Russell copyright notices are unmodified.
3. License: exact copy of root `license.txt` as `LICENSE.txt`. SHA-256:
   `cc8e92d92cf12fb1d04ddae0b573367f14188df5fcd6c7909d36486ff53a108a`.
   Its zlib-style requirements retain the notice, distinguish altered sources
   and prohibit misrepresenting authorship. This copy is not relicensed.
4. The new `../numeric.s` is plainly identified as a wrapper/adaptation.
   `DLOAD5` and TEST derive from the baseline's EVAL.Z80; STORE5 derives from
   EXEC.Z80. Sparse stack helpers derive from DLOAD5_SPL / STORE5_SPL in those
   files, with bytewise loading and explicit upper-byte zeroing. The same
   license covers these adapted routines; the wrapper is not presented as an
   unchanged original interpreter file.
5. Dean Belfield's older standalone package was investigated in C001. This
   experiment selects the newer BASIC V package to match the current reference
   interpreter and avoids mixing helper layouts or operation tables between
   the two implementations.
6. No upstream interpreter source has been edited. On 2026-11-01, the qualified
   adapter, unchanged vendor source/notice and expression helpers moved from
   C002 into `compiler/runtime/`. The BBC compiler now embeds the packaged image
   for its qualified VDU expression subset. Original 257-case ABI evidence and
   the 84-case expression evidence remain under C002. Development-tree
   promotion does not claim human review, main acceptance or hardware testing.
7. The later numeric-output tranche expanded the adapter's admitted unary
   selectors and added a separate STR formatter bridge in
   `../expression_runtime.s`. It retains this exact vendor source and license.
   Expanded qualification covers 449 packed numeric cases and 45 formatter
   cases, plus native output comparisons; see
   [the output record](../../../docs/tasks/C002/OUTPUT.md).
8. C003's string conversions add native bridges to unchanged VAL/STR selectors
   and an explicitly adapted EVAL.Z80 HEXSTR in `../expression_runtime.s`.
   Full pointer lengths and caller-owned buffers replace ACCS's page alignment;
   private NUL-terminated scratch replaces the interpreter's VAL accumulator.
   The same license covers these adaptations. The vendor math/license remain
   byte-identical. See [conversion audit/ABI](../../../docs/tasks/C003/CONVERSIONS.md).

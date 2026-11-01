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
6. No upstream interpreter source has been edited. Numeric experiments are
   confined to C002; promotion has not yet occurred.

# C006 offline self-source work inspection

The exact compiler performs substantial repeated source and table work, so a
quiet console cannot establish a hang. This inspection also cannot establish
that the physical invocation is progressing. It uses frozen source and completed
reports only; no extra emulator/hardware run or active-fixture change occurs.

## Concrete source paths

1. Source SHA6597a0df is111810 bytes/2067 LF-terminated lines. BASIC lines
   1080–1098 perform one signature scan and three compilation passes.
   Each pass's runtime generation calls PROCdatatable when READ/DATA is used
   (3228), and that procedure reopens and traverses the complete source
   (18112–18130). The compiler source itself uses READ/DATA for its embedded
   runtimes. A successful self-source compile therefore makes seven complete
   traversals, visiting782670 source bytes. This is a reviewed path count,
   not a measured progress indicator or duration.
2. PROCreadline (1370–1446) tests EOF, calls BGET once per source byte, and
   builds line$ with line$+CHR$(b%). The concatenation helper appends its RHS
   into an expression buffer; loading/storing mutable strings additionally
   moves their contents. Across the frozen lines, the sum of successive
   completed prefix lengths is4152435 per traversal,29067045 across seven.
   These are logical prefix-length tallies, not executed copy/instruction counts
   or an assumption that concatenation recopies the whole LHS internally.
3. FNsymbol (2500–2550) uses binary search. Creating a symbol in phase1 still
   shifts the packed two-byte sorted index one byte at a time (19214).
   The completed emulator self-source has2094 symbols. The pessimistic bound
   when every insertion shifts all preceding entries is2094*2093=4382742
   byte-assignment iterations. Actual insertion order/shifts were not measured;
   this is an upper bound, not evidence that those moves happened on hardware.
4. Procedure/FN lookup (FNprocfind,13110–13150) scans the entire routine table;
   variable lookup (FNvariable,6100–6120) similarly scans the binding table.
   The completed emulator self-source contains219 routines/254 bindings. These
   loops do not exit when a match is first found. Counts per actual physical
   invocation are not known.
5. Output opens only for phase3 (1096). PROCbytes hex-decodes pairs and emits
   byte writes (2760–2830); template/blob/zero paths contain explicit byte loops
   (19310,19412,19428). PROCword24 uses one three-byte string write (19223).
   The complete output is324275 bytes. This does not establish whether the
   physical invocation has reached emission, nor the actual number/duration
   of MOS calls. The final Wrote line is printed only after PROCcompile returns.

## Evidence limits

1. The retained complete self-source reports/controller logs contain output
   identities and host durations, without executed instruction/cycle counts.
   Unlimited-speed emulator durations cannot calibrate physical execution.
2. `self_source_work.py` reproducibly calculates file/prefix counts and the
   index-move bound from frozen source plus the retained2094-symbol result.
   It is ordinary host file analysis; it neither parses nor compiles BASIC and
   supplies no BBC numeric oracle. It does not measure CPU activity.
3. No source/runtime optimization follows from this review. The live compiler,
   firmware and active fixture remain unchanged. The5400s failure and original
   reader's7200s limit retain their documented meaning; only an actual correlated
   late return permits the original result retrieval and cleanup.

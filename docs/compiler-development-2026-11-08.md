# Compiler development — November 8, 2026

The Author's pinned firmware is now the default for future qualification.
Release firmware bytes/checksums and current candidate identities were audited;
no mandatory API/firmware exception was found by inspection. No runtime pass,
installed-state proof, flash operation or new workload is claimed.

1. C012 brief committed/pushed9255326 before starting the audit, as requested.
   Configured authenticated release access recovered the VDPlet metadata after
   unauthenticated404. Release VDPlet binary1100304/b004570b matches SHA256SUMS;
   RC3 release ZIP matches its checksum and extracted100879/d7a51147 matches the
   Author's exact MOS pin. Release metadata and source hashes are retained.
2. All53 manual package files and11 benchmark files are accounted for with
   payload hashes checked; live source70d3c5c6/image40e4ae06 remain unchanged.
   Reference, editor, Mandelbrot and C011 source/helper identities are retained.
3. RC3 preserves used synchronous MOS functions, sysvars and control-terminated
   filenames; VDPlet retains graphics/mode replies. Async25h migration affects
   old42h/43h clients; CBAS does not use those extensions. Clock scale, display,
   keyboard and actual program behavior still need target qualification.
4. Initial verifier development mapped mode_sha256 to the wrong source file;
   it stopped before retained results/target operations. Correct vdu.h mapping
   passes. The full report is C012/REPORT.md; exact run is evidence/audit-001.
5. Current firmware guidance and C011 template are updated; no frozen historical
   cohort or delivered SD payload is rewritten. Old text-only automated tooling
   cannot be reported as qualification of these defaults. C008/C011 retain actual
   testing; C012 inspection scope is complete and removed from TODO. No firmware
   exception, new test/custody request, emulator operation or main promotion.

# Search inspection tools

These tools retain source identities and aid inspection. They neither compile
BASIC nor run benchmarks. Use the project Python environment from the repository
root.

1. Recreate the pinned local inventory:

   ```bash
   .venv/bin/python docs/tasks/C007/tools/inventory_local.py
   ```

   It reads committed blobs at `ccd09af`, checks that local files still match,
   and records hashes/origins in `evidence/local-inventory.json`. A later source
   change should fail that assertion; do not rewrite historical evidence to
   make a changed candidate appear unchanged.
2. Inspect downloaded original tokenised sources:

   ```bash
   .venv/bin/python docs/tasks/C007/tools/inspect_tokenized.py \
     acorn docs/tasks/C007/build/ClockSp
   .venv/bin/python docs/tasks/C007/tools/inspect_tokenized.py \
     russell docs/tasks/C007/build/timing.bbc
   ```

   Fetch exact revisions/paths from `evidence/external-sources.json`, using
   base64 transfer for binary files. Check byte length, SHA-256 and Git blob
   hash before inspection. C007 verified all eleven external file identities
   against the pinned repository trees. No external source is checked in.
3. The listing aid validates record lengths/terminators for Acorn and Russell
   layouts. Keywords come from the local interpreter table; dialect-specific
   tokens remain explicit markers. Encoded branch line numbers are markers too.
   It preserves quoted/REM text for inspection but is not a complete tokenizer,
   detokenizer or runnable source conversion. All rendered lines may have line
   number zero in an original Russell file. Never feed these listings to the
   compiler as an allegedly equivalent program.
4. Four actual files were rendered successfully: Matrix Brandy ClockSp,
   BBCSDL timing, Hanoi and sorttest. No BASIC execution occurred. Keep original
   downloads and listings under ignored `build/`, and retain upstream notices
   if subsequently adopting code.

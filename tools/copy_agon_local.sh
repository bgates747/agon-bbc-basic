#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="../eZ80-for-rc-basic/src/"
DEST_DIR="./include/bbc-ez80"

FILES=(
  ASMB.Z80
  DATA.Z80
  EVAL.Z80
  EXEC.Z80
  MAIN.Z80
  MATH.Z80
  TOKENIDS.Z80
)

echo "Creating destination directory: $DEST_DIR"
mkdir -p "$DEST_DIR"

echo "Downloading files..."
for file in "${FILES[@]}"; do
    echo "  -> $file"
    cp "$SRC_DIR/$file" "$DEST_DIR/$file"
done

echo "Done. Files saved to $DEST_DIR"

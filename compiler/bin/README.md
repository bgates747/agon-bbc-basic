# Qualified development native compiler

This is the BBC-written compiler compiled from compiler/compiler.bas. It contains its runtime and runs directly under Agon MOS in eZ80 ADL mode; an installed BASIC interpreter or assembler is not required.

If the compiler directory is copied to the card as /compiler, use:

```text
LOAD /compiler/bin/compiler.bin
RUN .
```

Enter the plain-text source and a different destination filename at the prompts. Load and run the emitted program normally from MOS. To rebuild the compiler, supply /compiler/compiler.bas and a fresh output filename, then compare it with this image.

This development build supports the documented subset in [the compatibility matrix](../COMPATIBILITY.md). It is not a full BBC BASIC implementation. The original timeout/resumption and physical qualification records remain explicit in [C006](../../docs/tasks/C006.md); no human optical or performance acceptance is claimed.

The executable includes the preserved BBC BASIC V math package and marked standalone adaptations. Original authorship, notices and exact source origins are retained in [runtime provenance](../runtime/vendor/PROVENANCE.md) and [LICENSE.txt](LICENSE.txt).

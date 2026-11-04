BBC BASIC native compiler - manual hardware qualification
========================================================

This directory contains the standalone development compiler and a text editor.
You can write, compile and run supported BASIC programs entirely on the Agon.
No BASIC interpreter, assembler or host Python is needed for that workflow.

Install this directory wherever you choose on your Agon SD card. The directory
containing this readme is the package root. Before following the examples,
change to your chosen installation directory at the MOS prompt. All filenames
and test-directory paths below are relative to that root or the stated current
test directory; no particular installation path is required.

1. TRY THE STARTER

At the MOS prompt, enter these commands separately:

  LOAD compiler.bin
  RUN .

At Source file: enter hello.bas
At Output file: enter hello.bin
Wait for Wrote hello.bin and the MOS prompt. Then enter:

  LOAD hello.bin
  RUN .

Expected output:

  native compiler

It should return to MOS normally. This starter is the previously qualified
smoke-test source. Files staged on the card do not establish a manual pass.

2. CREATE OR EDIT YOUR OWN PROGRAM

The bundled nano.bin is Lennart Benschop's Agon text editor, not GNU nano.
It is a moslet built for &B0000, so use this exact load/run sequence:

  LOAD nano.bin &B0000
  RUN &B0000 myprog.bas

Enter, for example:

  PRINT "Hello from my program"
  END

Ctrl-O saves (follow its filename prompt); Ctrl-X exits. Ctrl-G shows help.
Cursor keys move normally. It may switch to an 80-column screen mode.
Keep editor lines at253 characters or fewer. It writes plain text with CRLF,
which the compiler accepts. Existing saves may create an editor backup file.

Alternatively, edit myprog.bas on the mounted card from your computer using
your preferred plain-text editor. Use ASCII source and uppercase keywords;
do not save tokenised BASIC or a document format. Line numbers are optional.
The compiler itself permits255-byte source lines; use an editor that preserves
those longer lines if needed.

After leaving the editor, LOAD compiler.bin and RUN . again. Supply myprog.bas
and myprog.bin at its two prompts. After Wrote myprog.bin and MOS return:

  LOAD myprog.bin
  RUN .

Always use a different input and output filename. Loading a generated program
replaces the compiler in user memory, so reload compiler.bin to compile again.
Reload nano.bin at&B0000 before another editing session as well.

3. LANGUAGE COVERAGE

This is a self-hosting compiler for a documented BBC BASIC subset. It is not
complete BBC BASIC. Read compatibility.md for exact supported forms and limits.
MODE, GCOL, PLOT and bare numeric GET support their documented forms.
Other graphics/sound statements, RND, CASE, numeric INPUT,
OSCLI, RUN/CHAIN, inline assembly and EVAL are not supported by this compiler.
MOS LOAD/RUN commands above are operating-system commands, not BASIC syntax.
Rejections are compiler diagnostics, not permission to run a stale output file.
Wait for a Wrote message before loading a newly compiled program.

4. MANUAL TEST DIRECTORIES

tests/readme.txt indexes twelve small tests and the Mandelbrot program.
Those twelve subdirectories have source.bas, expected.txt and readme.txt
with commands. Outputs you compile are kept in that test directory. Nothing autoruns.
The file-I/O test creates/overwrites only its own native-test.dat.
The rejection tests use a supplied preserve.dat sentinel; do not execute it.

An earlier compiler version passed automated and physical checks of these
small sources. This version has fresh automated checks; its physical and
human qualification remain pending. See compiler-provenance.json.
For your own checks, record the test name, visible output, return to MOS,
and any error or keyboard/display problem. They are not performance benchmarks.
If progress/return is unclear, record what happened rather than retrying blindly.

5. COMPILER SOURCE AND IDENTITIES

compiler.bas is the exact BBC source of compiler.bin, supplied for inspection
and optional self-rebuild. compiler-provenance.json identifies its qualification.
Rebuilding the compiler is optional and not a quick smoke test. Use a fresh
output name, for example self-new.bin. An earlier compiler version took
about99 minutes to observed completion in physical Agon qualification; your system's duration may differ.
There is no intermediate compiler progress display. That observation is not a
benchmark or a promised duration. Keep the supplied compiler.bas unchanged when
checking reproducibility; save your compiler experiments under a different name.

This compiler is 327205 bytes, SHA256:
40e4ae06730b6735696f5f07962efd10e6c9cfbdc44a81b65dd6e9ce1c82355a

manifest.json lists only supplied package files, not your later programs/results.
compiler-license.txt preserves the compiler/runtime notice; nano-license.txt
preserves the editor's MIT notice. editor.txt records its upstream origin and
the documented controls. No firmware installation is required by this package;
it uses your existing MOS/VDP. No firmware or startup file is supplied or changed.

For unchanged Mandelbrot source and its supplied native program, read
tests/12-mandelbrot/native-readme.txt. The twelve earlier tests remain.
Compiler provenance separates this version from earlier physical tests.

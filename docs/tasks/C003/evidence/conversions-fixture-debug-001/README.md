# Conversion fixture findings

The first broad suite compiled all 28 programs and executed all 18 native
programs. Its final comparison found one mismatch: a raw tab inside a quoted
VAL argument. All other native transcripts matched their BASIC expectations.
This is not accepted full-suite qualification.

1. Agon's src/agon_os.s OSLOAD_TXT2 drops bytes below ASCII 32 anywhere in a
   loaded text line, including strings. Thus the reference saw "12" while the
   compiler saw TAB+"12". Constructing the tab with CHR$(9) tests VAL's runtime
   semantics with identical values. Raw source control bytes in quoted literals
   are now rejected explicitly until loader normalization is qualified.
2. The early storage attempt's native execution returned status zero, but the
   memory capture retained a longer previous capture's tail: 35087 bytes instead
   of 24636. The fixture now removes its old MOS SAVE destination before capture.
   This was a capture-length assertion, not an accepted storage pass.
3. The separate native conversion ABI probe passed in 1.016 seconds against
   the unchanged runtime bytes. The final prototype will repeat all probes.

# Slice assignment reference audit

Statement slices update existing bytes without changing length or allocation.
Their range rules differ from expression slices; copy the reference encoding
rather than imposing modern bounds/clamping behavior.

1. EXEC.Z80 GETSTR calls GETVAR, rejects missing bindings before any argument
   expression, and requires a scalar string type. It saves a descriptor address,
   not its current length/pointer. MIDSL1 evaluates RHS before loading those
   fields, so a future FN that changes the target must affect the actual store.
2. LEFT defaults to L=0,H=255 (all but last); RIGHT defaults to L=255,H=255
   (rightmost one byte). Explicit count zero encodes L=1,H=0 (no operation).
   Other counts become H=L+count-1 modulo 256; on carry H is capped to254,
   except L=255 retains its wrapped marker. Counts are byte values after SFIX.
3. MID sets L=start-low-byte-1 modulo256,H=254, then applies the same optional
   count encoding. L=255 means rightmost H+2 bytes modulo256, bounded by RHS
   length; this makes MID start0 omitted-count a no-op, but start0 with explicit
   nonzero count act like RIGHT. H=255 with L!=255 means all but last. Thus
   MID$(s$,2,255) has the all-but-last marker, not a simple saturating end.
4. SUBSL reads B=target length,C=RHS length,DE=target pointer. Rightmost mode
   uses min(requested count,RHS length), then starts at max(B-that,0). Other
   modes validate L<B, bound H by B-1, and copy min(H-L+1,C). No bytes beyond
   existing length are written. Empty/count-zero paths must not invoke LDIR0.
5. Adapt these byte operations to IX=descriptor,IY=RHS length-prefixed buffer,
   H/L=range markers. Preserve IX/IY/SP; read full 24-bit target pointers and
   initialise upper offset/count bits. Do not assume page-aligned ACCS. RHS is
   privately copied before mutation, so self-referential source is stable.

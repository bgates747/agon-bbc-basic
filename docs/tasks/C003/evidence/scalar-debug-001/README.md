# Scalar prototype keyword-check failure

The prototype returned a function result while a FOR frame was active; the
bootstrap interpreter reported `Not in a FN`. Preserve this failed compiler and
log. The corrected predicate records a result, completes its loops and returns
afterwards. Lowercase/underscore initial characters bypass the uppercase keyword
table. This is a compiler implementation correction, not a language change.

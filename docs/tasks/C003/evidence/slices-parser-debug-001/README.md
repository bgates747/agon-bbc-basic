# Initial typed-item dispatch failure

The first smoke compile failed at the end of a numeric slice argument. An
inline nested IF/ELSE in typed item dispatch entered numeric word parsing after
an already completed item. Replaced the ambiguous nested branch with an
explicit helper and early return. This record is a failed compile, not a pass.

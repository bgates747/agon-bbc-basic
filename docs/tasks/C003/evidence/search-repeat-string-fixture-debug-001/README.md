# Older string fixture correction

The suite expected VAL and STR$ rejection even after their earlier promotion.
The compiler correctly compiled both sources. The fixture now compares these
two programs positively against BASIC, retaining 23 total programs (16 native/
7 rejected). Compiler/runtime bytes did not change. This failed expectation
check is retained separately and is not counted as passing qualification.

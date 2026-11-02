# Reference qualification correction

The first scalar suite incorrectly classified assigning the floating expression
`n=-2147483648:big%=n` as successful. Actual BASIC reports `Number too big`.
The case moves to the error group; the success group uses the integer bit pattern
`&80000000`. This records a reference observation, not permission to fix it.
No native qualification ran in this failed attempt.

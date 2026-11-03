# Invalid depth fixture retained

Compilation reaches all five inputs and repeat, then the controller rejects
case2 because its deeply parenthesised expression exceeds the admitted32-level
expression limit. It never reaches the native phase, GNU links or result report.
Cases0,1,4 compile, case3 rejects the257-definition cap, and repeat is emitted.
No overall pass or native execution is claimed. The fixture will use shallow
nested calls to reach argument slot31 independently of expression depth.

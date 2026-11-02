# String core prototype qualification

This frozen BBC prototype passed 23 programs (14 native executions, nine
compile-time rejections), deterministic repeat and independent numeric/string
runtime links. The direct ABI probe checks poisoned upper BC, index/stack
preservation, empty/null descriptors, inline lengths zero/255, unchanged
overflow and allocator-failure state, and a cross-page descriptor.

Binary snapshots use `.dat` to retain exact bytes under the repository ignore
rules. JSON hashes keep their original build paths. Storage evidence includes 15 reference-matched string bindings, an uncreated
descriptor, a LEN integer result and unchanged-image/heap guards. No hardware or graphical human validation is claimed.

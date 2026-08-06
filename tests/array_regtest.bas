10 DIM a$(4), b$(4)
20 a$() = "Zero", "one", "two", "three", "four"
30 b$() = a$()
40 IF b$(0)<>"Zero" THEN PRINT "FAIL 0": END
50 IF b$(1)<>"one" THEN PRINT "FAIL 1": END
60 IF b$(2)<>"two" THEN PRINT "FAIL 2": END
70 IF b$(3)<>"three" THEN PRINT "FAIL 3": END
80 IF b$(4)<>"four" THEN PRINT "FAIL 4": END
90 PRINT "PASS"


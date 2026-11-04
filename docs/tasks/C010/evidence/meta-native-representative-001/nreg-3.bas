x%=7:PRINT ;FNsum(5);":";x%:END
DEF FNsum(n%):LOCAL x%:x%=n%:IF n%<=1 THEN =1
=n%+FNsum(n%-1)

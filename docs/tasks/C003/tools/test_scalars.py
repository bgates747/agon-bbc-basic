"""Qualify scalar bindings through actual BBC compiler/reference/native output."""

import importlib.util
import sys
from pathlib import Path

TASK = Path(__file__).resolve().parents[1]
ROOT = TASK.parents[2]


def programs():
    groups = [
        ['a=1:PRINT ;a:a=a+2:PRINT ;a', 'LET b%=7/2:PRINT ;b%',
         'b%=-7/2:PRINT ;b%', 'byte&=-1:PRINT ;byte&', 'byte&=321:PRINT ;byte&'],
        ['PRINT ;A%;":";Z%', 'fresh=fresh+1:PRINT ;fresh',
         'fresh%=fresh%+2:PRINT ;fresh%', 'fresh&=fresh&+3:PRINT ;fresh&'],
        ['upper=1:UPPER=2:upper%=3:upper&=4:PRINT ;upper;":";UPPER;":";upper%;":";upper&',
         '_test9=5:COUNTtotal=6:PIvalue=7:PRINT ;_test9;":";COUNTtotal;":";PIvalue'],
        ['value=1/3:copy=value:PRINT ;value;":";copy;":";(value=copy)',
         'value=4294967296.0:PRINT ;value',
         'big%=&80000000:PRINT ;big%', 'big%=&7FFFFFFF:PRINT ;big%',
         'n=&80000000:big%=n:PRINT ;big%',
         'byte&=-1.5:PRINT ;byte&'],
    ]
    result=[dict(source="\n".join(g)+"\n",reference=True,status=0) for g in groups]
    result += [dict(source=s,reference=True,reference_error=True,status=1) for s in [
        'PRINT ;not_created\n',
        'PRINT ;a%\n',
        'PRINT ;missing&\n',
        'x%=2147483648\n',
        'n=-2147483648:big%=n\n',
        'x&=2147483648\n',
        'fresh=fresh+1:PRINT ;fresh:PRINT ;other\n',
    ]]
    result += [dict(source=s,expected=e,status=st) for s,e,st in [
        ('GOTO @after\nvalue=1\n@after:PRINT ;value\n','No such variable\n',1),
        ('GOSUB @sub:PRINT ;shared:END\n@sub:shared=5:RETURN\n','5\n',0),
        ('x=1:GOSUB @sub:PRINT ;x:END\n@sub:x=x+1:RETURN\n','2\n',0),
    ]]
    result += [dict(source=s,diagnostic=d) for s,d in [
        ('text$(0)="x"\n','Arrays and function calls'),
        ('a%(0)=1\n','Arrays and function calls'),
        ('a%%=1\n','Unsupported numeric suffix'),
        ('x+=1\n','Expected ='),
        ('x?0=1\n','Variable indirection'),
        ('LOCAL x\n','Unsupported statement LOCAL'),
        ('RUN=1\n','Unsupported statement RUN'),
        ('SQRname=1\n','Unsupported statement SQRname'),
        ('PRINT SQRname\n','Unsupported numeric item SQRname'),
        ('LET PI=1\n','Unsupported variable name PI'),
        ('x='+('('*20)+'1'+(')'*20)+'\n','Expression nesting exceeds'),
        (''.join(f'v{i}=0\n' for i in range(129)),'Scalar variable limit exceeds 128'),
    ]]
    result.append(dict(source=(ROOT/"compiler/examples/variables.bas").read_text(),reference=True,status=0))
    result += [dict(source=f'reused={value}:PRINT ;reused\n',reference=True,status=0) for value in (1,2)]
    return result


if __name__ == "__main__":
    spec=importlib.util.spec_from_file_location("output_harness",ROOT/"docs/tasks/C002/tools/test_output.py")
    output=importlib.util.module_from_spec(spec)
    spec.loader.exec_module(output)
    output.TASK=TASK
    output.programs=programs
    sys.argv.append("--isolate-reference")
    output.main()

"""Small static fixture checks and synthetic log-contract tests; no BASIC execution."""
from pathlib import Path
import csv,importlib.util,io,json,re,tempfile
TASK=Path(__file__).resolve().parent

def module(name):
    spec=importlib.util.spec_from_file_location(name,TASK/(name+'.py'))
    m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m

def rejected(call):
    try:call()
    except (AssertionError,ValueError):return
    raise AssertionError('Invalid fixture log was accepted')

def main():
    prepare=module('prepare');analyse=module('analyse')
    text=prepare.number((TASK/'fixture/suite.source').read_text())
    lines=text.splitlines();byline={int(s.split(' ',1)[0]):s.split(' ',1)[1] for s in lines}
    assert len(byline)==len(lines) and max(byline)<=65279
    assert max(map(len,lines))<=255 and '{' not in text and '}' not in text
    target=int(re.search(r'RESTORE (\d+):READ',text)[1])
    assert byline[target].startswith('DATA '),'RESTORE must target actual DATA'
    for target in re.findall(r'(?:GOSUB|GOTO) (\d+)',text):assert int(target) in byline
    data=[s[5:] for s in byline.values() if s.startswith('DATA ')][:-1]
    fields=next(csv.reader([','.join(data)]))
    assert len(fields)==84 and len(set(fields[::2]))==42
    bases=list(map(int,fields[1::2]));assert max(bases)*1000<2**31
    definitions=re.findall(r'DEF (PROC\w+|FN\w+\$?)',text)
    assert len(set(definitions))==len(definitions) and len(definitions)<256
    for name in ['suite.source','checks.bas']:
        src=(TASK/'fixture'/name).read_text()
        assert all(len(s)<=255 for s in src.splitlines())
        assert not re.search(r'\b(TIME|CALL|USR|EVAL|RND|OSCLI)\b',src),'Unsupported fixture feature'
    checks=(TASK/'fixture/checks.bas').read_text().splitlines()
    nums=[int(s.split(' ',1)[0]) for s in checks]
    assert nums==sorted(set(nums))
    with tempfile.TemporaryDirectory(prefix='c011-contract-') as tmp:
        paths=[]
        for engine in ['ref','native']:
            p=Path(tmp)/(engine+'.csv');rows=[['C011','1',engine,'2','2','1','5'],['CLOCK','123456','2','400']]
            for i in range(6):
                rows.append(['S','2',str(i),'10000','7FFFFF00','300','400','10000:0000000000:'])
            rows.append(['DONE']);buf=io.StringIO();csv.writer(buf,lineterminator='\n').writerows(rows);p.write_text(buf.getvalue());paths.append(p)
        ref,native=map(analyse.load,paths)
        result=analyse.compare(ref,native);assert result['equal_recorded_results']
        assert result['cases'][0]['precise_pair_candidate']
        broken=dict(native);broken['samples']=dict(native['samples'])
        broken['samples'][2,1]=dict(broken['samples'][2,1],state='9999:0000000000:')
        rejected(lambda:analyse.compare(ref,broken))
        broken['samples'][2,1]=dict(broken['samples'][2,1],state='10000:0000000000:',n=1)
        rejected(lambda:analyse.compare(ref,broken))
        p=paths[1];original=p.read_text()
        p.write_text(original.replace('DONE\n',''));rejected(lambda:analyse.load(p))
        p.write_text(original.replace(',300,400,',',300,401,'));rejected(lambda:analyse.load(p))
        rejected(lambda:analyse.validate_known(30,1000,'45:0000000000:414C50484142455441'))
        analyse.validate_known(30,1000,'46:0000000000:414C50484142455441')
    print(json.dumps(dict(static_only=True,basic_lines=len(lines),max_line_bytes=max(map(len,lines)),routine_definitions=len(definitions),cases=42,
        checks=['line limits and numbering','DATA targets','branch targets','unique signatures','no unsupported selected tokens',
                'synthetic valid paired log','mismatched state rejected','unequal work rejected','incomplete log rejected','wrong delta rejected','independent count oracle'],
        no_basic_execution=True,no_emulator=True)))

if __name__=='__main__':main()

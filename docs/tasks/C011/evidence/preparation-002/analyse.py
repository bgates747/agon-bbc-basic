"""Validate C011 paired target logs before reporting per-case throughput.

No target execution and no implementation of BBC numeric arithmetic. Packed
numeric results are compared as opaque bytes, not decoded/recomputed in Python.
"""
import argparse,csv,hashlib,json,statistics
from pathlib import Path


def load(path):
    rows=list(csv.reader(path.read_text().splitlines()))
    assert rows and len(rows[0])==7 and rows[0][:2]==['C011','1'],'Wrong log version'
    _,_,engine,first,last,scale,reps=rows[0]
    assert engine in ('ref','native')
    first,last,scale,reps=map(int,(first,last,scale,reps))
    assert 1<=first<=last<=42 and 1<=scale<=1000 and 1<=reps<=20
    assert rows[-1]==['DONE'],'Incomplete log'
    clocks=[r for r in rows if r[0]=='CLOCK']
    assert len(clocks)==1 and len(clocks[0])==4
    gran=int(clocks[0][2]);assert gran>0
    samples={}
    for row in rows[1:-1]:
        if row[0]=='CLOCK':continue
        assert row[0]=='S' and len(row)==8,'Unknown/malformed sample'
        _,case,sample,n,start,end,ticks,state=row
        case,sample,n=map(int,(case,sample,n))
        start,end,ticks=[int(v,16) for v in (start,end,ticks)]
        assert first<=case<=last and 0<=sample<=reps and n>0 and ticks>=0
        assert 0<=start<2**31 and 0<=end<2**31
        assert ticks==(end-start)%(2**31),'Bad elapsed ticks'
        assert (case,sample) not in samples,'Duplicate sample'
        parts=state.split(':')
        assert len(parts)==3 and len(parts[1])==10 and len(parts[2])%2==0
        int(parts[0]);bytes.fromhex(parts[1]);bytes.fromhex(parts[2])
        samples[case,sample]=dict(n=n,ticks=ticks,state=state)
    assert set(samples)=={(k,s) for k in range(first,last+1) for s in range(reps+1)},'Missing samples'
    return dict(engine=engine,first=first,last=last,scale=scale,reps=reps,gran=gran,samples=samples)


def validate_known(case,n,state):
    acc,packed,string=state.split(':');acc=int(acc)
    expected={1:n+1,2:n,4:n%256,5:n//4*3,6:n,7:n,8:n,9:n,10:n,11:n,
              13:n*8,23:2016+n,24:2016+n,29:32,30:46,31:2016,
              35:32640*(n//256),36:32640*(n//256),39:7,40:7,41:7,42:7}
    if case in expected:assert acc==expected[case],f'Independent integer/count oracle case {case}'
    if case in (32,33,34):
        hist=bytes.fromhex(string)
        assert len(hist)==33 and sum(hist)==16,'Mandelbrot histogram'
        assert acc==n*sum(i*c for i,c in enumerate(hist)),'Mandelbrot iteration total'
    strings={12:b'abcdefghijklmnop!',27:b'abcdefghijklmnopxy\0',
             28:b'XYc123ghijmnZZ',30:b'ALPHABETA'}
    if case in strings:assert bytes.fromhex(string)==strings[case],f'String oracle case {case}'


def compare(ref,native):
    assert ref['engine']=='ref' and native['engine']=='native','Engine order'
    assert all(ref[k]==native[k] for k in ['first','last','scale','reps']),'Unequal run settings'
    results=[]
    for case in range(ref['first'],ref['last']+1):
        states=set()
        for sample in range(ref['reps']+1):
            a,b=ref['samples'][case,sample],native['samples'][case,sample]
            assert a['n']==b['n'],f'Unequal work case {case}'
            assert a['state']==b['state'],f'Result mismatch case {case}, sample {sample}'
            states.add(a['state'])
            validate_known(case,a['n'],a['state'])
        assert len(states)==1,f'Nondeterministic result case {case}'
        a=[ref['samples'][case,s]['ticks'] for s in range(1,ref['reps']+1)]
        b=[native['samples'][case,s]['ticks'] for s in range(1,ref['reps']+1)]
        am,bm=statistics.median(a),statistics.median(b)
        valid=ref['reps']>=5 and min(a+b)>=1000 and case not in (37,38)
        results.append(dict(case=case,n=ref['samples'][case,0]['n'],
            reference_cs=a,native_cs=b,reference_median_cs=am,native_median_cs=bm,
            reference_range_cs=[min(a),max(a)],native_range_cs=[min(b),max(b)],
            median_ratio=am/bm if bm else None,
            precise_pair_candidate=valid,
            external_output_validation_required=case in (37,38),
            note='Confirm configuration/order, source/image identities and clock before any performance claim'))
    return dict(schema='C011-comparison-v1',equal_recorded_results=True,
        target_configuration_verified=False,measured_speedup_claim=False,cases=results)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('reference',type=Path);parser.add_argument('native',type=Path)
    args=parser.parse_args()
    result=compare(load(args.reference),load(args.native))
    result['inputs']={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in [args.reference,args.native]}
    print(json.dumps(result,indent=2))

if __name__=='__main__':main()

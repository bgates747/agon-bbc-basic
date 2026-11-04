"""Prepare numbered BBC fixture and tiny MOS clock helper; never compile BASIC."""
from pathlib import Path
import argparse,hashlib,json,re,shutil,subprocess
TASK=Path(__file__).resolve().parent
ROOT=TASK.parents[2]
BUILD=TASK/'build/console8-001'
TOOL=Path('/Agon/agondev/release/bin')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()

def number(source):
    lines=source.splitlines()
    targets={line[10:]:10*(i+2) for i,line in enumerate(lines) if line.startswith('REM LABEL ')}
    result=[]
    for i,line in enumerate(lines):
        line=re.sub(r'\{([a-z_]+)\}',lambda m:str(targets[m[1]]),line)
        text=f'{10*(i+1)} {line}'
        assert len(text.encode('ascii'))<=255,(i,text)
        result.append(text)
    assert len(result)*10<=65279
    return '\n'.join(result)+'\n'

def main():
    global BUILD
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--name',default='console8-002')
    args=parser.parse_args()
    assert re.fullmatch(r'[a-z0-9-]+',args.name)
    BUILD=TASK/'build'/args.name
    BUILD.mkdir(parents=True,exist_ok=False)
    (BUILD/'suite.bas').write_text(number((TASK/'fixture/suite.source').read_text()))
    shutil.copyfile(TASK/'fixture/checks.bas',BUILD/'checks.bas')
    shutil.copyfile(TASK/'readme.txt',BUILD/'readme.txt')
    shutil.copyfile(TASK/'COVERAGE.md',BUILD/'coverage.md')
    shutil.copyfile(TASK/'run-info.txt',BUILD/'run-info.txt')
    shutil.copyfile(TASK/'analyse.py',BUILD/'analyse.py')
    shutil.copyfile(ROOT/'license.txt',BUILD/'LICENSE.txt')
    assert sha(ROOT/'bin/basic.bin')=='a1ae6d381d9861abbc5d87550c683827499d5a8cbe1de49fd9dfa3687382653d'
    shutil.copyfile(ROOT/'bin/basic.bin',BUILD/'reference.bin')
    # Four megabytes of fixed input cover the maximum admitted file-read count.
    (BUILD/'input.dat').write_bytes(bytes(range(256))*16000)
    obj=BUILD/'clock.o'
    subprocess.run([str(TOOL/'ez80-none-elf-as'),'-march=ez80+full',f'-al={BUILD}/clock.lst','-o',str(obj),str(TASK/'clock.s')],check=True)
    subprocess.run([str(TOOL/'ez80-none-elf-ld'),'-Ttext=0x40000','-e','start','--oformat=binary','-o',str(BUILD/'clock.bin'),str(obj)],check=True)
    subprocess.run([str(TOOL/'ez80-none-elf-objdump'),'-dr',str(obj)],check=True,stdout=(BUILD/'clock.dis').open('w'))
    helper=(BUILD/'clock.bin').read_bytes()
    assert helper[64:69]==b'MOS\0\1'
    provenance={'schema':'C011-fixture-v1','status':'prepared; no target execution',
      'compiler_sha256':'40e4ae06730b6735696f5f07962efd10e6c9cfbdc44a81b65dd6e9ce1c82355a',
      'reference_sha256':sha(BUILD/'reference.bin'),'native_suite_provided':False,
      'timer':'MOS sysvar_time, read only; observed granularity required',
      'files':{p.name:dict(bytes=p.stat().st_size,sha256=sha(p)) for p in sorted(BUILD.iterdir()) if p.suffix not in ['.o','.lst','.dis']}}
    (BUILD/'manifest.json').write_text(json.dumps(provenance,indent=2)+'\n')
    print(json.dumps(dict(package=str(BUILD),files=len(provenance['files']),helper_bytes=len(helper))))

if __name__=='__main__':main()

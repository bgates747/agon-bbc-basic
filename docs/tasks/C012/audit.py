"""Finite offline release/hash and candidate inventory audit; never execute targets."""
from pathlib import Path
import hashlib,json,shutil
TASK=Path(__file__).resolve().parent
ROOT=TASK.parents[2]
R=TASK/'build/releases';E=TASK/'evidence/audit-001'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()

def main():
    assert not (E/'results.json').exists(),'Preserve completed audit'
    sums={line.split(None,1)[1].strip():line.split()[0] for line in (R/'SHA256SUMS').read_text().splitlines()}
    verified={}
    for n,h in sums.items():
        if (R/n).is_file():assert sha(R/n)==h;verified[n]=h
    archive=R/'3.1.0_uart0_rc_3.zip'
    assert sha(archive)==(R/'3.1.0_uart0_rc_3.zip.sha256').read_text().split()[0]
    mos=R/'mos/mos-rc3.bin'
    assert mos.stat().st_size==100879 and sha(mos)=='d7a51147f3381cd68d56f3fbe4605434a897dfae1b049269afeba09ec2b7eb50'
    vdp=R/'vdp-vdplet-0.1.2-alpha.bin'
    assert vdp.stat().st_size==1100304 and sha(vdp)=='b004570b607b45bbd6e87a3c704b65b23d3221981db3aac6cf2578aa22d766e3'
    package=ROOT/'docs/tasks/C010/evidence/manual-package-001/payload'
    p=json.loads((package/'manifest.json').read_text())
    for n,h in p['files'].items():assert sha(package/n)==h
    bench=ROOT/'docs/tasks/C011/build/console8-004'
    b=json.loads((bench/'manifest.json').read_text())
    for n,m in b['files'].items():assert sha(bench/n)==m['sha256']
    candidates={}
    for n,pth in {'compiler-source':ROOT/'compiler/compiler.bas','compiler-native':ROOT/'compiler/bin/compiler.bin',
        'reference-interpreter':ROOT/'bin/basic.bin','nano-editor':package/'nano.bin',
        'mandelbrot-source':package/'tests/12-mandelbrot/mandelbrot.bas',
        'mandelbrot-native':package/'tests/12-mandelbrot/mandelbrot-c010.bin',
        'manual-package-manifest':package/'manifest.json','benchmark-package-manifest':bench/'manifest.json',
        'benchmark-suite':bench/'suite.bas','benchmark-checks':bench/'checks.bas','clock-helper':bench/'clock.bin'}.items():
        candidates[n]=dict(bytes=pth.stat().st_size,sha256=sha(pth))
    assert candidates['compiler-native']['sha256']=='40e4ae06730b6735696f5f07962efd10e6c9cfbdc44a81b65dd6e9ce1c82355a'
    assert candidates['compiler-source']['sha256']=='70d3c5c6f4da44cf865c36c3f4edef143b9e37c662097067a5e6ceac414c300e'
    sources={}
    files=['src/mos_api.asm','src/mos_api.inc','src/globals.asm','src/interrupts.asm','src/vdp_protocol.asm','src/mos_file.c','src/mos.c']
    for n in files:sources['rc3/'+n]=sha(R/'mos/source'/n)
    fs=json.loads((R/'firmware-source.json').read_text());vdpsrc=Path(fs['source'])/'video'
    for n,key in [('vdu_stream_processor.h','processor_sha256'),('vdu.h','mode_sha256')]:
        assert sha(vdpsrc/n)==fs[key],n
    for n in ['vdu.h','vdu_sys.h','vdu_stream_processor.h','agon_screen.h']:
        sources['vdplet-release/'+n]=sha(vdpsrc/n)
    asm=(R/'mos/source/src/mos_api.asm').read_text()
    for n in ['sysvars','editline','fopen','fclose','fgetc','fputc','feof']:
        assert 'mos_api_'+n in asm
    for n in ['vdp-release.json','mos-release.json','SHA256SUMS','release-manifest.json','firmware-source.json','verification.json','3.1.0_uart0_rc_3.zip.sha256']:
        shutil.copyfile(R/n,E/n)
    shutil.copyfile('/Agon/mystuff/agon-extender/docs/olimex-firmware-standard.json',E/'olimex-standard-snapshot.json')
    result=dict(task_freeze='92553266d37dc1881d28b9d3f746d327a3290786',
        firmware_verified=dict(vdp_bytes=vdp.stat().st_size,vdp_sha256=sha(vdp),mos_bytes=mos.stat().st_size,mos_sha256=sha(mos),mos_zip_sha256=sha(archive),downloaded_vdp_checksum_entries=verified),
        candidates=candidates,manual_payload_files_checked=len(p['files']),benchmark_payload_files_checked=len(b['files']),
        inspected_source_hashes=sources,no_target_execution=True,no_emulator=True,no_flash=True,
        disposition='No mandatory firmware exception identified by source/API inspection; runtime qualification on defaults remains pending')
    (E/'results.json').write_text(json.dumps(result,indent=2)+'\n')
    shutil.copyfile(__file__,E/'audit.py')
    (E/'evidence-manifest.json').write_text(json.dumps({f.name:sha(f) for f in sorted(E.iterdir()) if f.name!='evidence-manifest.json'},indent=2)+'\n')
    print(json.dumps(result,indent=2))

if __name__=='__main__':main()

"""Check BBC line ordering and loader limits before emulation."""
from pathlib import Path
import sys
p=Path(sys.argv[1]);lines=p.read_text().splitlines();ids=[int(s.split()[0]) for s in lines]
assert ids==sorted(set(ids))
assert max(len(s.split(' ',1)[1]) for s in lines)<=255
print(f'{len(lines)} ordered loader-safe lines')

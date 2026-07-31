import json, re, sys
from collections import Counter
AUTH = re.compile(r"auth|api.?key|x-.*-token|x-.*-secret", re.I)
d = json.load(open(sys.argv[1], encoding='utf-8'))
c = Counter()
for e in d['log']['entries']:
    for side in ('request', 'response'):
        for h in e[side].get('headers', []):
            n = h['name']
            if n.lower() in ('cookie', 'set-cookie'):
                continue
            if AUTH.search(n):
                c[side + ':' + n + ' = ' + h['value'][:60]] += 1
print(sys.argv[1])
for k, v in c.most_common():
    print(f'  {v:3d}  {k}')

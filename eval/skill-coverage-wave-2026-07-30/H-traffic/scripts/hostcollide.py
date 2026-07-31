import json, re, sys
from collections import defaultdict
def path_of(url):
    m = re.match(r"^[a-zA-Z]+://[^/]+([^?]*)", url)
    return m.group(1) if m else url
def host_of(url):
    m = re.match(r"^[a-zA-Z]+://([^/]+)", url)
    return m.group(1) if m else '?'
for p in sys.argv[1:]:
    d = json.load(open(p, encoding='utf-8'))
    sig = defaultdict(set)
    for e in d['log']['entries']:
        u = e['request']['url']
        q = tuple(sorted(x['name'] for x in e['request'].get('queryString', [])))
        sig[(e['request']['method'], path_of(u), q)].add(host_of(u))
    print(p)
    coll = {k: v for k, v in sig.items() if len(v) > 1}
    print('  signatures:', len(sig), '| signatures merging >1 host:', len(coll))
    for k, v in coll.items():
        print('   COLLISION', k, sorted(v))

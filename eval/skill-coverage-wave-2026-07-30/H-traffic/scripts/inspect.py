import json, sys, base64, re
p = sys.argv[1]
d = json.load(open(p, encoding='utf-8'))
es = d['log']['entries']
print("== HAR:", p, "entries:", len(es))
for e in es:
    req, res = e['request'], e['response']
    pd = (req.get('postData') or {}).get('text')
    cookies_req = [h['value'] for h in req.get('headers', []) if h['name'].lower() == 'cookie']
    setc = [h['value'] for h in res.get('headers', []) if h['name'].lower() == 'set-cookie']
    if pd or cookies_req or setc:
        print('---')
        print(req['method'], req['url'][:110], '->', res['status'], 'time=%.1fms' % e.get('time', -1))
        if pd:
            print('  POSTBODY:', pd[:300])
        for c in cookies_req:
            print('  REQ Cookie:', c[:200])
        for c in setc:
            print('  RES Set-Cookie:', c[:200])

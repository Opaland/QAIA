import json, re, sys
from collections import Counter
PHONE = re.compile(r"(?<!\d)(\+?\d[\d .-]{7,16}\d)(?!\d)")
CARD = re.compile(r"\d{13,19}")
EMAIL = re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}")
def luhn(ds):
    t=0; p=len(ds)%2
    for i,ch in enumerate(ds):
        d=int(ch)
        if i%2==p:
            d*=2
            if d>9: d-=9
        t+=d
    return t%10==0
d=json.load(open(sys.argv[1],encoding='utf-8'))
by=Counter(); ex=[]
for e in d['log']['entries']:
    c=e['response'].get('content') or {}
    txt=c.get('text'); mt=c.get('mimeType') or ''
    if not txt: continue
    n=len(PHONE.findall(txt))
    cards=[x for x in CARD.findall(txt) if luhn(x)]
    em=EMAIL.findall(txt)
    if n or cards or em:
        by[mt]+=n
        ex.append((e['request']['url'][-55:], mt, c.get('encoding'), n, len(cards), em[:2], cards[:1]))
print(sys.argv[1])
print("phone-regex hits per response mimeType:", dict(by))
for r in ex[:12]:
    print("  ", r)

# generated.snapshot — US-EVAL-010

Baseline for regeneration-mode edit detection (sha256, first 12 hex chars, per scenario block;
computed for real over `testbooks/vehicle-location-bola.feature` via a Python `hashlib.sha256` pass
on each scenario's own tag+body text, not estimated — see command below).

```
python - <<'EOF'
import hashlib, re
text = open("testbooks/vehicle-location-bola.feature", encoding="utf-8").read()
blocks = re.split(r'(?=  @QAIA-US-EVAL-010-\d+)', text)
for b in blocks:
    m = re.match(r'  (@QAIA-US-EVAL-010-\d+)', b)
    if m: print(m.group(1), hashlib.sha256(b.strip().encode('utf-8')).hexdigest()[:12])
EOF
```

| Scenario ID | Hash |
|---|---|
| QAIA-US-EVAL-010-001 | `c6d6d6bcaeea` |
| QAIA-US-EVAL-010-002 | `1a2578b24b8c` |
| QAIA-US-EVAL-010-003 | `9023966c5a5e` |
| QAIA-US-EVAL-010-004 | `88e8a74da464` |
| QAIA-US-EVAL-010-005 | `40e435d9b5ba` |

## Duplicate scan (D19)

Searched the repo's committed `.feature` files (`Grep` for `crapi|vehicle.*location|BOLA`, glob
`**/*.feature`, whole repo): **no existing `.feature` file** touches crAPI, the vehicle-location
endpoint, or a BOLA-shaped scenario — no reuse candidate found, all 5 blocks are original to this
run.

## Skill evaluation — `testbook-generate` (`plugins/qaia-core/skills/testbook-generate/SKILL.md`)

See separate evaluator pass (spawned after this checkpoint).

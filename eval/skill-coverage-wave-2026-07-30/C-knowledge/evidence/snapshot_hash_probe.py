"""Real probe: can the per-scenario hashes in generated.snapshot.md be reproduced?

`feedback` SKILL.md step 1 offers a non-interactive branch: "diff the edited `.feature`
files against the generated version if both exist". The only machine-readable "generated
version" that exists for US-EVAL-009 is `state/generated.snapshot.md`, which carries
"sha256, first 12 hex chars, per scenario block".

testbook-generate SKILL.md line 38 says only "scenario IDs + content hash per scenario" —
no algorithm, no block boundary, no newline/whitespace normalization. This script tries a
grid of plausible definitions and reports which (if any) reproduces the recorded digest.
No result is asserted unless it is printed by an actual run.
"""

import hashlib
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
FEATURE = ROOT / "eval/skill-eval-campaign-2026-07-29/US-EVAL-009-octoperf-petstore/testbooks/octoperf-petstore-cart.feature"
SNAPSHOT = ROOT / "eval/skill-eval-campaign-2026-07-29/US-EVAL-009-octoperf-petstore/state/generated.snapshot.md"


def load_expected():
    expected = {}
    for line in SNAPSHOT.read_text(encoding="utf-8").splitlines():
        m = re.match(r"\|\s*(QAIA-[\w-]+)\s*\|\s*`([0-9a-f]+)`\s*\|", line)
        if m:
            expected[m.group(1)] = m.group(2)
    return expected


def split_blocks(raw):
    """Split the feature file into scenario blocks keyed by @QAIA-... tag."""
    lines = raw.splitlines()
    blocks, current, cid = {}, [], None
    for line in lines:
        m = re.search(r"@(QAIA-[\w-]+)", line)
        if m and line.strip().startswith("@"):
            if cid:
                blocks[cid] = current
            cid, current = m.group(1), [line]
        elif cid is not None:
            current.append(line)
    if cid:
        blocks[cid] = current
    return {k: [l for l in v] for k, v in blocks.items()}


def variants(block_lines):
    """Plausible content definitions for one scenario block."""
    full = "\n".join(block_lines).rstrip()
    no_tags = "\n".join(l for l in block_lines if not l.strip().startswith("@")).strip()
    no_comments = "\n".join(
        l for l in block_lines if not l.strip().startswith("#")
    ).rstrip()
    body_only = "\n".join(
        l for l in block_lines
        if not l.strip().startswith("@") and not l.strip().startswith("#")
    ).strip()
    stripped = "\n".join(l.strip() for l in block_lines if l.strip())
    return {
        "full_block_lf": full,
        "full_block_lf_nl": full + "\n",
        "full_block_crlf": full.replace("\n", "\r\n"),
        "no_tag_lines": no_tags,
        "no_comment_lines": no_comments,
        "body_only": body_only,
        "all_lines_stripped": stripped,
    }


def main():
    if not FEATURE.exists():
        print(f"BLOCKED: feature file not found: {FEATURE}")
        return 2
    expected = load_expected()
    blocks = split_blocks(FEATURE.read_text(encoding="utf-8"))
    print(f"feature: {FEATURE}")
    print(f"snapshot: {SNAPSHOT}")
    print(f"scenarios in snapshot: {len(expected)} | blocks parsed from feature: {len(blocks)}")
    print()
    any_match = False
    for sid, exp in expected.items():
        block = blocks.get(sid)
        if block is None:
            print(f"{sid}: NO BLOCK PARSED")
            continue
        results = []
        for name, content in variants(block).items():
            digest = hashlib.sha256(content.encode("utf-8")).hexdigest()[:12]
            hit = digest == exp
            any_match = any_match or hit
            results.append(f"    {name:22s} -> {digest} {'*** MATCH ***' if hit else ''}")
        print(f"{sid}: expected {exp}")
        print("\n".join(results))
    print()
    print("ANY VARIANT REPRODUCED A RECORDED DIGEST:", any_match)
    return 0


if __name__ == "__main__":
    sys.exit(main())

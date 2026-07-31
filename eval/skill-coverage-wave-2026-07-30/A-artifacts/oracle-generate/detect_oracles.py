#!/usr/bin/env python3
"""oracle-generate step 1, executed for real on US-EVAL-009.

"Detect standardized domains in 01-extraction.md / 03-design.md. For each, name the
applicable oracle." (plugins/qaia-core/skills/oracle-generate/SKILL.md, Steps 1)
Triggers are the literal ones of the SKILL.md domain-trigger table.

Also checks the provenance rule of Steps 3: every @oracle:<std>-tagged scenario must
carry a `# oracle: <ref>` comment.
"""
import os, re, sys

TRIGGERS = {
    "Luhn (ISO/IEC 7812)":      r"\bcard\b|\bPAN\b|payment number",
    "ISO 8601":                 r"\bdate\b|\bdeadline\b|\bexpiry\b",
    "RFC 5322":                 r"email address|\bemail\b",
    "HTTP semantics (RFC 9110)": r"\bHTTP\b|\bREST\b|status code",
    "ISO 4217":                 r"currency|\bUSD\b|\bEUR\b|\$\d",
    "ISO 3166":                 r"country code",
    "IBAN (ISO 13616)":         r"\bIBAN\b|bank account",
}


def main(base):
    for name in ("01-extraction.md", "03-design.md"):
        path = os.path.join(base, "state", name)
        text = open(path, encoding="utf-8").read()
        print(f"=== {name} ===")
        for oracle, pattern in TRIGGERS.items():
            hits = re.findall(pattern, text, re.I)
            if hits:
                sample = sorted({h.strip() for h in hits})[:6]
                print(f"  TRIGGERED  {oracle:28s} n={len(hits):3d} e.g. {sample}")
            else:
                print(f"  -          {oracle:28s} n=0")

    feat = os.path.join(base, "testbooks", "octoperf-petstore-cart.feature")
    lines = open(feat, encoding="utf-8").read().splitlines()
    print("\n=== Steps-3 provenance check on the existing book ===")
    for i, ln in enumerate(lines):
        for tag in re.findall(r"@oracle:\S+", ln):
            block = []
            j = i + 1
            while j < len(lines) and not re.match(r"\s*Scenario", lines[j]):
                block.append(lines[j]); j += 1
            has_comment = any(re.match(r"\s*# oracle:", b) for b in block)
            print(f"  line {i+1}: {tag} -> `# oracle: <ref>` comment present: {has_comment}")
            if not has_comment:
                print(f"    comments actually attached: "
                      f"{[b.strip() for b in block if b.strip().startswith('#')]}")


if __name__ == "__main__":
    main(sys.argv[1])

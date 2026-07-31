# Probe: does structural_score.py's #27 fabrication sniffer catch the *integer* amounts
# ("$360", "$790", "1150") that scenario QAIA-US-EVAL-008-005 asserts but that appear
# nowhere in the source US? testbook-score/SKILL.md line 40 claims "amount" literals are sniffed.
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "tools"))
from structural_score import TECH_LITERAL_RE

for lit in ["$360", "$790", "1150", "360 USD", "12.50 EUR", "1150.00 USD", "https://x.com"]:
    print(repr(lit), "->", TECH_LITERAL_RE.findall(lit))

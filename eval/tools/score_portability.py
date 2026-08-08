# -*- coding: utf-8 -*-
"""Verdict objectif sur les sorties du test de portabilite #84.

On mesure ce qui est verifiable sans juger le style :
  - la sortie est-elle un .feature VALIDE (meme linter que la CI) ?
  - a-t-elle fallu la nettoyer (bloc de code englobant) -- ce qui est deja un ecart ?
  - combien de scenarios, combien d'identifiants stables @QAIA-, combien de drapeaux
    @low-confidence et de questions ouvertes.
"""
import io
import os
import re
import subprocess
import sys

ROOT = sys.argv[1]
LINTRC = os.path.abspath(".gherkin-lintrc")

FENCE = re.compile(r"^\s*```(?:gherkin|feature)?\s*$", re.M)


def clean(text):
    """Retire un eventuel bloc de code englobant. Le fait d'avoir a le faire est un constat."""
    if not FENCE.search(text):
        return text, False
    parts = FENCE.split(text)
    body = max(parts, key=len)
    return body.strip() + "\n", True


def lint(path):
    try:
        p = subprocess.run(["npx", "--yes", "gherkin-lint@4.2.4", "-c", LINTRC, path],
                           capture_output=True, text=True, shell=True, timeout=180)
        return p.returncode, (p.stdout or "") + (p.stderr or "")
    except Exception as e:
        return None, str(e)


print("%-6s %-13s %-9s %-8s %-6s %-6s %-6s %s" %
      ("bras", "modele", "nettoye", "lint", "scen", "@QAIA", "@low-c", "premiere erreur"))
print("-" * 108)

for arm in ("A", "B"):
    d = os.path.join(ROOT, arm)
    if not os.path.isdir(d):
        continue
    for name in sorted(os.listdir(d)):
        if not name.endswith(".txt"):
            continue
        model = name[:-4]
        raw = io.open(os.path.join(d, name), encoding="utf-8", errors="replace").read()
        body, stripped = clean(raw)
        fpath = os.path.join(d, "%s.feature" % model)
        io.open(fpath, "w", encoding="utf-8", newline="\n").write(body)
        code, out = lint(fpath)
        # compter AUSSI les mots-cles francais : un fichier en francais avec en-tete
        #  passe le linter, et ne pas le compter produisait un « OK, 0
        # scenario » -- un faux vert de mon propre instrument.
        scen = len(re.findall(r"^\s*(?:Scenario(?: Outline)?|Scénario(?: ?:? ?Plan)?):", body, re.M))
        fr = bool(re.search(r"^\s*(?:Scénario|Fonctionnalité|Étant donné|Etant donné)", body, re.M))
        ids = len(re.findall(r"@QAIA-[A-Za-z0-9-]+", body))
        lowc = len(re.findall(r"@low-confidence", body))
        first = ""
        if code != 0:
            for l in out.split("\n"):
                if "expected:" in l or "error" in l.lower():
                    first = re.sub(r"\s+", " ", l.strip())[:44]
                    break
        # un fichier sans scenario n'est pas un succes, quoi qu'en dise le linter
        # Un fichier qui LINT n'est pas un fichier CONFORME. Trois exigences explicites de la
        # skill s'ajoutent au parseur : au moins un scenario, des identifiants stables, et des
        # mots-cles anglais. Mon instrument a du etre resserre TROIS fois -- mesurer coute plus
        # cher que corriger, encore une fois.
        verdict = "OK" if (code == 0 and scen > 0 and ids > 0 and not fr) else "ECHEC"
        note = first
        if code == 0 and scen == 0:
            note = "lint OK mais AUCUN scenario"
        if ids == 0:
            note = (note + " | " if note else "") + "AUCUN identifiant @QAIA-"
        if fr:
            note = (note + " | " if note else "") + "mots-cles FRANCAIS"
        print("%-6s %-13s %-9s %-8s %-6d %-6d %-6d %s" %
              (arm, model, "oui" if stripped else "non", verdict, scen, ids, lowc, note))

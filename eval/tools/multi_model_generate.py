#!/usr/bin/env python3
"""Send the SAME prompt to all 3 free providers (not a fallback chain — a genuine
side-by-side comparison) and save each raw response to its own file.

Maintainer eval tooling only (lives in eval/, like second_judge.py) — tests whether QAIA's
skill instructions (portable, 100% Markdown, D29) generalize across LLM backends, not just
Claude. Never shipped to installers.

Usage: python3 multi_model_generate.py --file prompt.txt --outdir results/
"""
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from second_judge import load_dotenv, PROVIDERS  # single source of truth for the provider list

def main():
    load_dotenv()
    args = sys.argv[1:]
    prompt_path = args[args.index("--file") + 1]
    outdir = args[args.index("--outdir") + 1] if "--outdir" in args else "."
    os.makedirs(outdir, exist_ok=True)
    prompt = open(prompt_path, encoding="utf-8").read()

    for name, env_var, fn in PROVIDERS:
        key = os.environ.get(env_var)
        if not key:
            print(f"{name}: skipped (no {env_var})")
            continue
        try:
            text = fn(prompt, key)
            out_path = os.path.join(outdir, f"{name}.txt")
            with open(out_path, "w", encoding="utf-8") as f:
                f.write(text)
            print(f"{name}: OK -> {out_path} ({len(text)} chars)")
        except Exception as e:
            print(f"{name}: FAILED ({e})")

if __name__ == "__main__":
    main()

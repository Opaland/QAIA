#!/usr/bin/env python3
"""Second-judge LLM caller with a free-tier fallback chain (maintainer eval tooling).

NOT shipped to installers (lives in eval/, like structural_score.py) — QAIA's shipped
skills never depend on an API key (D29, "100% skill, zero API key"). This is purely a
second, independent judge for the maintainer's own harness, to cross-check the primary
Claude judge and reduce judge-monoculture risk (the current judge is always Claude judging
Claude's own output family).

Fallback order: Gemini -> Groq -> Hugging Face (Inference Providers router). Each provider
is skipped if its key/token is absent from .env; a request that errors or is rate-limited
falls through to the next provider rather than failing the whole call.

Honesty note: the Gemini request shape below is implemented from current docs but has not
been exercised against a live key at the time of writing (no GEMINI_API_KEY configured yet).
Groq and Gemini both fall back to HF automatically if they fail, so the chain still works
end-to-end on HF alone. Re-verify the Gemini shape against https://ai.google.dev before
trusting it beyond a smoke test.

Usage: python3 second_judge.py "<prompt text>"
       python3 second_judge.py --file prompt.txt
       echo "<prompt>" | python3 second_judge.py
"""
import sys, os, json, urllib.request, urllib.error

def load_dotenv(path=".env"):
    if not os.path.exists(path):
        return
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, _, v = line.partition("=")
            k, v = k.strip(), v.strip()
            if k and k not in os.environ:
                os.environ[k] = v

def _post_json(url, headers, body, timeout=90):
    # 90s default: a short judge call finishes in a few seconds, but a full test-book
    # generation prompt can run long on some providers (Gemini timed out at 30s on a
    # generation-scale prompt, succeeded at 90-120s) — found by running it, not guessed.
    # default urllib User-Agent gets 403'd by some providers' WAFs (confirmed on HF's
    # router — curl with identical auth/body succeeded, bare urllib did not).
    headers = {**headers, "User-Agent": "qaia-eval-second-judge/0.1"}
    req = urllib.request.Request(
        url, data=json.dumps(body).encode("utf-8"), headers=headers, method="POST"
    )
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return json.loads(resp.read().decode("utf-8"))

def call_gemini(prompt, api_key):
    # Endpoint/request shape confirmed live (200 OK). Response shape corrected from a real
    # call: NOT a flat "output_text" field (that was a docs-summary artifact, wrong) — the
    # real reply is the last "model_output" step's content text inside "steps": [...].
    url = "https://generativelanguage.googleapis.com/v1beta/interactions"
    headers = {"x-goog-api-key": api_key, "Content-Type": "application/json"}
    body = {"model": "gemini-3.6-flash", "input": prompt}
    data = _post_json(url, headers, body)
    for step in reversed(data.get("steps", [])):
        if step.get("type") == "model_output":
            for part in step.get("content", []):
                if part.get("type") == "text" and part.get("text"):
                    return part["text"]
    raise RuntimeError(f"Gemini: no model_output text step in response: {data}")

def call_groq(prompt, api_key):
    # OpenAI-compatible chat completions.
    url = "https://api.groq.com/openai/v1/chat/completions"
    headers = {"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"}
    body = {"model": "llama-3.3-70b-versatile", "messages": [{"role": "user", "content": prompt}]}
    data = _post_json(url, headers, body)
    return data["choices"][0]["message"]["content"]

def call_hf(prompt, token):
    # HF Inference Providers, OpenAI-compatible router (verified against current docs).
    url = "https://router.huggingface.co/v1/chat/completions"
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    body = {"model": "openai/gpt-oss-120b:fastest", "messages": [{"role": "user", "content": prompt}]}
    data = _post_json(url, headers, body)
    return data["choices"][0]["message"]["content"]

def call_mistral(prompt, api_key):
    # OpenAI-compatible chat completions.
    url = "https://api.mistral.ai/v1/chat/completions"
    headers = {"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"}
    body = {"model": "mistral-small-latest", "messages": [{"role": "user", "content": prompt}]}
    data = _post_json(url, headers, body)
    return data["choices"][0]["message"]["content"]

def call_cerebras(prompt, api_key):
    # OpenAI-compatible chat completions. Same underlying model family as HF's gpt-oss-120b
    # leg but a different inference host — a good check for host-level (not just model-level)
    # variance. STATUS: confirmed via a live GET /v1/models call that this model is listed for
    # the configured key, but every model on that key (gemma-4-31b, gpt-oss-120b, zai-glm-4.7)
    # returns 402 Payment Required — an account-level activation issue, not a code bug (the
    # error body points at "your billing tab"). Falls through cleanly if left unresolved.
    url = "https://api.cerebras.ai/v1/chat/completions"
    headers = {"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"}
    body = {"model": "gpt-oss-120b", "messages": [{"role": "user", "content": prompt}]}
    data = _post_json(url, headers, body)
    return data["choices"][0]["message"]["content"]

PROVIDERS = [
    ("gemini", "GEMINI_API_KEY", call_gemini),
    ("groq", "GROQ_API_KEY", call_groq),
    ("huggingface", "HF_TOKEN", call_hf),
    ("mistral", "MISTRAL_API_KEY", call_mistral),
    ("cerebras", "CEREBRAS_API_KEY", call_cerebras),
]

def judge(prompt):
    errors = []
    for name, env_var, fn in PROVIDERS:
        key = os.environ.get(env_var)
        if not key:
            errors.append(f"{name}: skipped (no {env_var} in .env)")
            continue
        try:
            text = fn(prompt, key)
            return {"provider": name, "response": text, "skipped_or_failed": errors}
        except (urllib.error.HTTPError, urllib.error.URLError, RuntimeError, KeyError, TimeoutError) as e:
            errors.append(f"{name}: failed ({e})")
            continue
    raise RuntimeError("All providers exhausted:\n" + "\n".join(errors))

def main():
    load_dotenv()
    args = sys.argv[1:]
    if args and args[0] == "--file":
        prompt = open(args[1], encoding="utf-8").read()
    elif args:
        prompt = " ".join(args)
    else:
        prompt = sys.stdin.read()
    if not prompt.strip():
        print(__doc__); sys.exit(1)
    result = judge(prompt)
    print(json.dumps(result, ensure_ascii=False, indent=2))

if __name__ == "__main__":
    main()

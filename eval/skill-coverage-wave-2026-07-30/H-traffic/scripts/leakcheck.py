# DELIVERED COPY -- the literal secret values that were actually searched for have been
# replaced by placeholders by the operator before writing this file as evidence.
# The version really executed contained the true values (throwaway demoblaze account
# password / session token / cookie + saucedemo demo credentials).
# Results of the real run are in ../leak-check.txt.
import sys, os
secrets = {
    "b64-password": "<base64 of the throwaway demoblaze password>",
    "plain-password": "<throwaway demoblaze password>",
    "username": "<throwaway demoblaze username qaia_eval_...>",
    "session-token": "<demoblaze tokenp_ session token>",
    "user-cookie": "<demoblaze user cookie uuid>",
    "saucedemo-password": "<saucedemo demo password>",
    "saucedemo-username": "<saucedemo demo username>",
}
targets = sys.argv[1:]
for t in targets:
    data = open(t, encoding="utf-8", errors="replace").read()
    hits = {k: data.count(v) for k, v in secrets.items() if v in data}
    print(f"{t}  size={os.path.getsize(t)}  LEAKS={hits if hits else 'none'}")

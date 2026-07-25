# US-005 — Loyalty points earning & redemption

> Gold set item. Original synthetic content (clean-room), MIT-licensed. Domain: e-commerce/retail, non-medical. Calculation- and boundary-heavy (rounding, tiers, expiry).
> Deliberate ambiguities listed at the bottom for judge reference only.

## User story

**As a** shopper,
**I want** to earn and redeem loyalty points on my orders,
**so that** I am rewarded for repeat purchases.

## Acceptance criteria

1. A member earns 1 point per €1 of the order's eligible amount (shipping and taxes excluded). Points are rounded **down** to the nearest whole point.
2. Members have tiers: `standard` (×1), `silver` (×1.5 from €500 spent in 12 months), `gold` (×2 from €2000 in 12 months). The multiplier applies to earned points.
3. Points expire 12 months after they are earned; expiry runs on a rolling per-earning basis, not per account.
4. At checkout, a member may redeem points at 100 points = €1, capped at 50 % of the order's eligible amount. Redemption consumes the **oldest** points first.
5. Redeemed points that are later refunded (order cancelled) are returned to the account with their **original** expiry date.
6. Points are only earned once an order is `delivered`; a cancelled or returned order earns none (and reverses any provisionally shown).
7. A member downgraded from a tier keeps points already earned at the higher multiplier; only future earnings use the new tier.
8. Every earning, redemption, expiry and reversal is recorded with timestamp and resulting balance.

## Judge reference — planted ambiguities (do not feed to skills)

- AC1 rounding × AC2 multiplier: is rounding-down applied **before** or **after** the tier multiplier? €33 eligible at silver = 33×1.5 = 49.5 → 49, or 33→33×1.5=49.5? Order of operations unspecified — changes the result.
- AC4 cap × AC1 eligible: the 50 % cap is on "eligible amount" — is that pre- or post-any-other-discount? Not specified.
- AC3 × AC5: a refunded redemption returns points "with their original expiry" — but if that date is already **past** at refund time, are they returned already-expired (useless) or given a grace period? Contradiction left open.
- AC2 tier thresholds: "from €500 spent in 12 months" — rolling 12 months or calendar year? And inclusive at exactly €500? Not specified.

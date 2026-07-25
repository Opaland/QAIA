# Source US (thin, as ingested) — SHOP-412

**As a** customer
**I want** to apply a discount code at checkout
**so that** I pay less.

## Acceptance criteria

- **AC1** — A valid discount code reduces the order total by its configured amount.
- **AC2** — An expired or unknown code is rejected with a message.
- **AC3** — The discounted total is shown before payment confirmation.

That is all the story says. Nothing about stacking, per-customer limits, customer
segments, or the interaction with the cart minimum. A generation-from-AC-alone run covers
these three criteria and stops — the recall ceiling described in D38.

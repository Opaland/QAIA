# Application map — checkout & pricing

Where the behavior lives, so conditions can target the right surface.

- **Checkout UI** — `/checkout`: discount field, applied-code chip, live total.
- **Pricing API** — `POST /api/cart/discount { code }` → `200 { total, discount }` |
  `422 { error }` (rejections: `expired`, `unknown`, `code already used`, `cart below minimum`).
- **Admin** — codes configured with amount, validity window, and the project-level
  `checkout.stacking` flag (BR-KB-007).
- **Segment** — customer `segment ∈ { retail, business }` set at account level (BR-KB-011).

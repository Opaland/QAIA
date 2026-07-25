# Application map — RideShare trip & booking surfaces

Where the behavior lives, so conditions can target the right surface.

- **Trip publish (driver)** — `/trips/new`: route, departure time, seats offered, price per seat
  (validated server-side against the BR-KB-301 cost-share cap), optional recurrence pattern.
- **Search & book (passenger)** — `/search` → `POST /api/bookings { tripId, seats }` →
  `200 { bookingId, costShare }` | `422 { error }` (rejections: `seats unavailable`,
  `driver ineligible`, `booking restricted`).
- **Trip detail / cancel** — `/trips/:id`: cancel action available to driver and confirmed
  passengers; routes through BR-KB-302 (grace window, refund vs. penalty) and, for recurring
  trips, BR-KB-305 (per-occurrence vs. whole-series cancellation).
- **Pickup check-in** — mobile app "I'm here" button at the pickup point; absence of check-in
  within the grace window feeds BR-KB-303 (no-show detection).
- **Driver profile / documents** — licence, vehicle, and insurance upload; verification status
  consumed by BR-KB-304 to gate trip publication.
- **Trust & safety admin** — reviews accounts below the publish threshold (BR-KB-306) and
  accounts under a no-show booking restriction (BR-KB-303); can lift or extend restrictions.

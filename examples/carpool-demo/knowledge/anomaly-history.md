# Anomaly history — RideShare

Chronological log of production incidents that revealed an implicit rule or edge case. Entries
promoted to `business-rules.md` reference their rule ID; an unpromoted entry stays open for
correlation with future recurrences (shared contract rule on provenance).

## ANO-09 — passenger repeated no-show blocking a wanted seat
Reported 2026-03-05: a passenger no-showed on two trips within a week without cancelling in
advance. The seat stayed marked "booked" with no automatic consequence, so the driver had no way
to reallocate it and other riders could not book it. **Promoted to BR-KB-303** (3 no-shows / 30
days → 14-day booking restriction). Recurrence count: 2.

## ANO-14 — "cancel series" wiped already-confirmed occurrences
Reported 2026-03-30: a driver cancelling a recurring trip's Monday occurrence via the "cancel
series" button also silently cancelled Tuesday-Friday occurrences that already had confirmed
passengers, with no refund triggered for them. **Promoted to BR-KB-305** (per-occurrence seat
locking; cancelling an occurrence and cancelling the series are distinct explicit actions).

## ANO-21 — price above the cost-share cap accepted without a server check
Reported 2026-04-28: a driver published a trip at €0.35/km/seat, well above the €0.10/km fiscal
rate; the publish form only warned in the UI and let the trip go live anyway. A rider flagged it
as "feels like a taxi, not covoiturage." **Promoted to BR-KB-301** (the cap is enforced
server-side, not just as a UI hint).

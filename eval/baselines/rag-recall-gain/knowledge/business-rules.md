# Business rules — class booking & credits (FitFlow)

One concern per entry, declarative and testable, provenance mandatory (shared contract rule 5).
These are project truths that do not appear in FIT-118's ticket text — they live here so
`istqb-design` step 3d retrieves and applies them instead of guessing (D38 RAG-in-use).

## BR-KB-201 — credit cost varies by time slot
Booking a **standard** class deducts **1 credit**. Booking a **peak-hour** class (weekday,
18:00-20:00 start time) deducts **2 credits** (`booking.peakCreditMultiplier = 2`).
_Provenance: FIT-042 (pricing config), 2026-02-14, decided-by studio ops._

## BR-KB-202 — cancellation cutoff and no-show penalty
Cancelling **4 hours or more** before a class's start time is free (no credit forfeited).
Cancelling **less than 4 hours** before start forfeits **1 credit** (late-cancellation fee). A
**no-show** (booking never cancelled, class occurred, member did not attend) forfeits
**2 credits**. (`booking.cancelCutoffHours = 4`)
_Provenance: FIT-055, 2026-03-02, decided-by studio ops, after member complaints about
last-minute empty spots._

## BR-KB-203 — membership tier credit allowance
Monthly credit allowance by tier: **Basic** = 8 credits/month, no rollover. **Premium** =
20 credits/month, unused credits roll over up to a cap of **10** into the next month (rollover
beyond 10 is forfeited). **Unlimited** = uncapped credits, but capped at **1 active booking per
day** regardless of credits available.
_Provenance: FIT-009 (membership tiers), 2026-01-20, decided-by product. Config-driven — not
inferable from a single booking ticket._

## BR-KB-204 — waitlist promotion
When a booked spot frees up (a cancellation or no-show), the **earliest-joined** waitlisted
member for that class is offered the spot (FIFO by join time). If the class starts **2 hours or
more** away, promotion is **automatic** (the member is auto-booked and notified). If the class
starts **less than 2 hours** away, promotion is **manual**: the member is offered the spot and
has **15 minutes** to confirm before the offer passes to the next waitlisted member.
(`waitlist.autoPromoteCutoffHours = 2`, `waitlist.offerWindowMinutes = 15`)
_Provenance: FIT-061, 2026-04-11, decided-by studio ops._

## BR-KB-205 — repeated no-show restriction
A member who accumulates **3 no-shows within a rolling 30-day window** is placed under a
**7-day booking restriction**: no new bookings may be made until the restriction expires, and
the member receives a warning notification on the triggering no-show.
(`noShow.thresholdCount = 3`, `noShow.windowDays = 30`, `noShow.restrictionDays = 7`)
_Provenance: anomaly ANO-31 (chronic no-shows blocking capacity for paying members who wanted
the spot), 2026-05-06. Promoted from feedback (3 recurrences)._

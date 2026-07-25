# Business rules — trip cost-sharing & booking (RideShare)

One concern per entry, declarative and testable, provenance mandatory (shared contract rule 5).
These are project truths that do not appear in any single ticket — they live here so every test
design retrieves and applies them (D38 RAG-in-use).

## BR-KB-301 — cost-share is capped, never a profit
A driver cannot make a profit from a shared ride: the total cost-share collected from all
passengers cannot exceed the trip's actual cost, computed as round-trip distance (km) × the
official fiscal indemnity rate (`ride.costPerKm`, currently €0.10/km), split evenly across all
occupied seats (driver included). The platform **rejects server-side** any manually-entered
price above this computed cap — a UI warning alone is not sufficient.
_Provenance: RIDE-014, 2026-02-03, decided-by legal (French "covoiturage" non-professional
status: a driver charging above cost-share is requalified as a paid transport service and loses
insurance coverage). Server-side enforcement added after anomaly ANO-21, where a price entered
above the cap was silently accepted by the UI alone._

## BR-KB-302 — cancellation grace window and passenger penalty
Driver cancels a confirmed booking **2 hours or more** before departure
(`booking.driverCancelGraceHours = 2`): passenger refunded in full, no trust-score impact.
Driver cancels **less than 2 hours** before departure: passenger refunded in full **and** the
driver's trust score is decremented by 1 point (repeated late cancellations restrict publishing,
BR-KB-306). Passenger cancels **1 hour or more** before departure
(`booking.passengerCancelGraceHours = 1`): full refund. Passenger cancels **less than 1 hour**
before departure: forfeits 50% of the cost-share to the driver.
_Provenance: RIDE-027, 2026-02-20, decided-by product, after driver complaints about last-minute
cancellations leaving declared seats empty with no compensation._

## BR-KB-303 — no-show detection and booking restriction
A rider (driver or passenger) is marked a **no-show** if they have not confirmed presence at the
agreed pickup point within a **10-minute grace window** after the scheduled departure time
(`pickup.graceMinutes = 10`). Accumulating **3 no-shows within a rolling 30-day window** triggers
an automatic **14-day booking restriction** on the account (cannot publish or book new trips);
the account owner is notified on the triggering no-show and can appeal to support.
_Provenance: anomaly ANO-09 (a passenger repeatedly no-showing, blocking a seat other riders
wanted), 2026-03-05. Promoted from feedback (2 recurrences)._

## BR-KB-304 — driver eligibility to publish trips
To publish a trip as a driver, the account must satisfy **all** of: driving licence held for at
least **2 years** (`driver.minLicenceYears = 2`), vehicle no older than **15 years**
(`driver.maxVehicleAgeYears = 15`), proof of insurance uploaded **and** verified by the platform
(status = `verified`, not merely `pending`), and no active booking restriction (BR-KB-303).
Missing any single condition blocks publication with the specific unmet reason shown to the
driver — not a generic rejection.
_Provenance: RIDE-002 (driver onboarding), 2026-01-15, decided-by trust & safety._

## BR-KB-305 — recurring trips lock seats per calendar date
A recurring trip (e.g. "every weekday, 8:00, same route") publishes **independent seat
availability per calendar date**, not one shared pool: booking Tuesday does not consume a seat on
Wednesday. Cancelling one occurrence never cancels the series. "Cancel the whole series" is a
separate, explicit action that only cancels occurrences **without** a confirmed passenger;
occurrences that already have a confirmed passenger must be cancelled individually, each
triggering BR-KB-302's grace-window logic on its own dates.
_Provenance: RIDE-041, 2026-04-02, decided-by product, after anomaly ANO-14 (cancelling one
Monday occurrence silently cancelled the whole week's already-confirmed bookings)._

## BR-KB-306 — trust score floor restricts publishing
Trust score is the rolling average of a rider's last 20 completed-trip ratings (1-5 scale). A
driver whose trust score falls **below 3.5** (`trust.minScoreToPublish = 3.5`) cannot publish new
trips until a manual trust & safety review clears the account; existing confirmed bookings are
still honored, never auto-cancelled. Passengers are not blocked from booking by their own low
trust score, but a driver sees a low-trust-score warning badge on any pending booking request
from such a passenger before accepting it.
_Provenance: RIDE-058, 2026-05-10, decided-by trust & safety._

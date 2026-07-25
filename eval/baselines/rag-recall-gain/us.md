# Source ticket (as ingested) — FIT-118

*Clean-room, domain: fitness-studio scheduling ("FitFlow"). Deliberately terse — a title plus
a narrative paragraph and loose notes, no numbered acceptance criteria — matching the "ticket
dur" protocol used across the corpus-24 campaign (`eval/goldset-hardened/corpus-24-plan.md`),
so `us-review`'s extraction step has real work to do.*

## FIT-118 — Class booking: confirm, cancel, waitlist

**As a** studio member
**I want** to book a spot in a fitness class and manage my booking
**so that** I know if I'm attending and don't lose a spot I don't need.

Notes (from the ticket description, unedited):
> Members book from the class schedule. Cancelling frees the spot for someone else. If a class
> is full, members can join a waitlist instead. Booking uses membership credits. Login and
> membership management already exist — this ticket is only the booking flow itself.

That is the entire ticket. Nothing about how many credits a class costs, whether cancelling
close to class time still frees the spot for free, what happens on a no-show, or how/when a
waitlisted member gets promoted. Those are exactly the config-driven questions this experiment
targets (D38 recall ceiling).

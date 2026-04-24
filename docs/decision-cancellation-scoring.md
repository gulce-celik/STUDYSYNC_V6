# Decision: Cancellation and Responsibility Scoring

Date: 2026-04-07
Status: Accepted

## Context

We need a consistent and memorable rule set for cancellations and responsibility score changes.
Project sources mention:

- Reward for early cancellation behavior
- Penalties for late cancellation and no-show
- No-refund policy for cancellations close to slot start

## Final Decision

We use a combined policy:

1. **Early cancellation reward**
   - If cancelled **>= 24 hours** before slot start:
   - score change: `+3`

2. **Late cancellation penalty + no-refund**
   - If cancelled **< 1 hour** before slot start:
   - score change: `-5`
   - reservation points: **no refund**

3. **No-show penalty**
   - If user does not complete QR check-in within first 15 minutes:
   - reservation auto-cancelled
   - score change: `-10`
   - reservation points: **no refund**

4. **Normal cancellation zone**
   - If cancelled between 1 hour and 24 hours:
   - score change: `0`
   - points refund policy can be configured later by product/admin

## Why this is consistent

- Encourages responsible early planning (`+3`)
- Discourages last-minute waste (`-5`)
- Strongly penalizes no-show behavior (`-10`)
- Matches project goals: fairness, accountability, and better seat utilization

## Implementation Note

Backend must be the source of truth for these checks. Frontend can show expected outcome labels, but score and refund decisions are finalized only on backend.

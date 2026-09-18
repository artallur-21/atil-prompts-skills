# Elevate HVA Framework — the fixed spec (source of truth)

This is authoritative. Every phase maps back to it. Do not re-derive or "improve" it.

## Scoring

- **5 INPUT HVAs.** Each is closed by exactly ONE build activity (below). Report the score as **X/5**.
  - **PASS = ≥ 3/5.** **GOAL = 5/5.** Always aim for 5/5; 3/5 is the floor, not the target.
- **4 OUTPUT HVAs** — outcomes we track (and use), not force:
  - **GMS ≥ +10%** vs the **pre-Elevate (pre-service) baseline**.
  - **Monthly ad spend ≥ +15% MoM OR ≥ ₹7,500/month, whichever is higher.** Minimum budget is
    ₹7,500/mo. If the seller already spends, raise by **+15% next month** (aim 25%, commit 15%,
    never more than the account needs).
  - **Account TACoS ≥ 10% OR the desired GR-level TACoS, whichever is higher** — monitor/use, don't push.
  - **Account ROAS > 3.5** — maintain by optimizing all campaigns; every NEW campaign targets ≥ 3.5.

## Baselines & window

- **Pre-Elevate baseline** = the account's metrics in the period *before* service start (enrollment).
  Default to the 30 days immediately before `service starts` (confirm the exact window with the
  operator if it matters for a payout decision).
- **Days left / window** = from the org's Elevate enrolment to `service_ends_at` (~60-day window).
  Payout/eligibility is judged at window end.

## ASIN eligibility (apply before advertising ANY ASIN)

An ASIN qualifies to be advertised only if **ALL** hold:

- **rating > 3.5★**, AND
- **≥ 2 units sold in the last 30 days**, AND
- **≥ 1 unit sold in the last 7 days**.

We do **not** store ratings. For the candidate set (top-10-by-GMS) fetch ratings by **crawl** — the
full methodology (what to open, what to extract, per-platform execution, IP hygiene, fallback) is in
[reviews-and-ratings.md](reviews-and-ratings.md). Any ASIN failing any condition = **EXCLUDE** —
flag it, never build for it.

## The 5 input HVAs = 5 build activities

Each HVA is "closed" when its activity is proposed (and, where relevant, approved/executing).

### HVA-1 · SP AUTOMATIC — quality-ASIN discovery
From the **top 10 ASINs by GMS**, take those that are **UNADVERTISED** and **ELIGIBLE** (rating > 3.5
via crawl). Create **one Sponsored Products AUTOMATIC campaign** covering them; target ROAS ≥ 3.5.
Rationale to state: the account has very few keywords and ~no search terms above **5 orders/month**;
the auto campaign **harvests new converting search terms** for later manual promotion.

### HVA-2 · SP MANUAL EXACT — top-2 ASINs, SQP-driven
Take the **top 2 ASINs by sales** (must be ELIGIBLE). For **each**, create a single **SP MANUAL**
campaign: **1 ASIN, 1 ad group, daily budget ₹350, target ~70% budget utilization**. Keywords: pull
the ASIN's **Search Query Performance (SQP)** report; pick the **top 10 queries with high purchase
volume where the ASIN's price is aligned** to that query's market; **verify each is relevant to the
product** (thumb rule) and drop the rest. **EXACT** match; bids = suggested **median** (band
median×0.75 … median×1.25).

### HVA-3 · OUT-OF-BUDGET RULE (SP + SB + SD) — created PAUSED
Rule: over the **last 7 days**, compute each campaign's **ROAS from its cost**. For any campaign with
**ROAS > 3.5**, prevent it from going out of budget (**keep OOB < 20%**) — raise/protect the daily
budget within a cap, with **daily auto-reset** (no compounding). Applies to **all three ad types**
(SP, SB, SD). Created **PAUSED** for operator review.

### HVA-4 · SPONSORED BRANDS VIDEO — spend gate
IF the seller's **last-30-day ad spend > ₹15,000**: propose **one SB VIDEO campaign** (video
converts). If a brand **video asset already exists** → reuse it in a new SBV campaign. If none → task
the seller to provide a video, or flag "ATIL to produce a video". Requires Brand Registry.

### HVA-5 · SPONSORED DISPLAY — VIEWS remarketing
Always propose **one SD views-remarketing campaign, minimum budget ₹100/day**. Framing: sale-period —
viewers convert inside the sale window.

## Optimizations (seller benefit, on top of the 5 HVAs)

Not scored, but they protect ROAS/TACoS and grow the seller: eliminate wasted spend (spend, 0
orders → negatives); harvest converting-but-untargeted terms → EXACT; reallocate bid/budget toward
ROAS ≥ 3.5 winners; step down EXCLUDE-ASIN spend. Keep every change inside the ROAS > 3.5 /
TACoS ≥ 10% guardrail.

## Market-level research (mandatory client discussion points)

Two category keyword lists, always produced in ANALYZE:

- **A) Price-aligned** — top category keywords, high purchase volume, seller's price **fits** → we
  **target** these (this is the source for HVA-2 keywords).
- **B) Price-misfit** — top category keywords, high purchase volume, seller's price **does not fit**
  → **client discussion points** (price/offer conversation). Present them; never silently drop them.

## HVA → activity → "what closes it" quick map

| HVA | Activity | Closed when |
|---|---|---|
| HVA-1 | SP Auto on eligible top-GMS unadvertised ASINs | auto campaign proposed/live |
| HVA-2 | SP Manual Exact ×2 (SQP price-aligned) | both manual campaigns proposed/live |
| HVA-3 | OOB rule (ROAS>3.5 kept <20% OOB, SP+SB+SD) | rule created (paused) / enabled |
| HVA-4 | SB Video (if 30d spend > ₹15k) | SBV proposed (asset sourced) |
| HVA-5 | SD Views remarketing (₹100/day min) | SD campaign proposed/live |

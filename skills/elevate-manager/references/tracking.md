# Phase TRACK — the cohort scorecard & risk radar (the single-command surface)

This is what "Elevate status" / "where are the HVAs not hitting" / "where is payout at risk" hits.
Read-only, live, computed each run (no schema needed). One row per Elevate advertiser.

## Enumerate the cohort

`organization_management.program='elevate'` (+ active window) → organizations → `amazon_profiles`
(**dedupe by `profile_id`** — one advertiser can have shadow rows). For each, resolve: store name,
day N of 60 / **days left** (`service_ends_at`), and run the EVALUATE scorecard (X/5 + output HVAs).
For a large cohort, fan the per-account EVALUATE out read-only and aggregate.

## The row (per advertiser)

| Field | From |
|---|---|
| Store / profile | list_profiles / seller storefront |
| Days left | org Elevate window |
| Input score X/5 | EVALUATE (which HVAs ❌) |
| Output HVAs | GMS Δ vs baseline, spend Δ / floor, TACoS, ROAS |
| **Risk** | see model below |
| Next action | the single highest-impact build that lifts the score |

## Risk model (payout / eligibility "at risk")

Payout needs **≥ 3/5 input HVAs** and the output HVAs trending to target **before the window closes**.
Classify each advertiser:

- 🔴 **AT RISK** — days_left ≤ 20 AND (score < 3/5 OR any output HVA off-track with no plan in flight).
- 🟠 **WATCH** — score = 3/5 but not 5/5, OR an output HVA drifting, with days_left > 20.
- 🟢 **ON TRACK** — score ≥ 3/5 (aim 5/5) and output HVAs trending to target.
- ⚪ **NEW** — just onboarded / backfill incomplete (no verdict yet; note it, don't fail it).

"Billing/payout at risk" = the 🔴 set (and 🟠 with < 30 days). Sort the cohort by risk, then by
days_left ascending, then by score ascending — the most urgent advertiser is row 1.

## The single-command views

- **"Elevate status" / "Elevate scorecard"** → the full cohort table, every advertiser, sorted by
  risk. End with counts (🔴/🟠/🟢/⚪) and the aggregate "N of M advertisers currently pass (≥3/5)".
- **"Where are the HVAs not hitting"** → the same table but columns collapsed to the 5 HVAs as a
  ✅/❌ matrix, so the operator sees at a glance which HVA is missing where, plus a per-HVA "missing
  on K accounts" tally (tells them the highest-leverage fix across the cohort).
- **"Where is payout/eligibility at risk" / "Elevate billing risk"** → only 🔴 (+ near-deadline 🟠),
  each with days_left, the blocking gap, and the one action that clears it.

## Automatic mode ("run Elevate" / "Elevate weekly review")

1. TRACK the whole cohort (above).
2. For every 🔴 (and 🟠 within 30 days), run ANALYZE → BUILD, laying down the fixes as **pending
   tasks + paused rules** for that account (dry-run, not executed).
3. Report: the cohort table, then per at-risk account a 2-line "gap → the tasks now waiting for your
   approval". The operator reviews and approves; nothing goes live unsupervised.

## Notes / memory

Persist per-advertiser operator notes (do-not-touch ASINs, seller preferences, last review date) via
the platform's `mcp_memories` (mirror `ppc-manager` memory conventions) so a later run doesn't
re-propose rejected items or re-review an account mid-cycle.

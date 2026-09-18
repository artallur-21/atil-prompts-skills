# Elevate — Audit & Action Plan page (Claude Design agent brief)

Paste into the Claude Design agent (claude.ai/design) to build the client-facing audit + action-plan
page. Sample data is illustrative (fictional "HearthNest") — never paste a real client's private figures.
Framework values must match `skills/elevate-manager/references/hva-framework.md`.

---

```text
Build a single-page "Elevate Seller — Audit & Action Plan" report for ScaleSKUs (by ATIL), an Amazon
Ads agency. Client-facing deliverable for a seller in Amazon's Elevate managed program: show where
they stand on Amazon's 5 HVAs and the exact plan we'll execute to grow sales profitably. Premium
PPC-agency audit look — confident, data-forward, trustworthy. Use the synced design system if present;
else clean modern SaaS with a confident brand accent (deep teal/indigo) and a strict semantic status
system (green ✅ on-track, amber ⚠️ at-risk, red ❌ off-track, separate from the accent), strong
hierarchy, tabular numerals. Long-scroll with sticky section nav; responsive to mobile.

### 1. HEADER / READINESS HERO
- "HearthNest" · Amazon.in · Home & Kitchen · "Amazon Elevate" badge · "Day 22 of 60 · 38 days left".
- Elevate Score dial: 2 / 5 HVAs with subtitle "Pass = 3/5 · Goal = 5/5" (amber).
- Four OUTPUT-HVA tiles vs PRE-ELEVATE baseline: GMS +6% (target +10%) ⚠️ · Ad spend ₹41,200/mo
  (min ₹7,500 ✅, +8% MoM vs target +15% ⚠️) · TACoS 8.2% (target ≥10%) ⚠️ · ROAS 4.1 (target >3.5) ✅.

### 2. HVA SCORECARD — 5 input HVAs, each = one activity (status pill + "what closes it")
- HVA-1 SP Auto on quality top-GMS ASINs — ❌ not built (3 unadvertised >3.5★ heroes to cover)
- HVA-2 SP Manual Exact ×2 (top ASINs, SQP price-aligned) — ⚠️ 1 of 2 built
- HVA-3 OOB protection (ROAS>3.5 kept <20% OOB, SP+SB+SD) — ❌ rule not live; hero at 34% OOB
- HVA-4 Sponsored Brands VIDEO — ❌ eligible (spend >₹15k) but no SBV
- HVA-5 SD Views Remarketing — ✅ live (₹100/day)
Banner: "2/5 complete — 1 more to PASS, 3 more for a perfect 5/5."

### 3. ASIN ELIGIBILITY (top 10 by GMS)
Table: thumbnail, ASIN, name, GMS rank, rating (crawled), units 30d / 7d, advertised?, verdict QUALIFY
(>3.5★, ≥2 units/30d, ≥1/7d) / EXCLUDE. Callouts: "3 qualifying heroes UNADVERTISED → the SP Auto
campaign covers them"; "2 EXCLUDED (1 rated 3.2★, 1 with 0 recent units)."

### 4. GAPS & WASTE (3 stat callouts, hard numbers)
- WASTED SPEND: "₹3,400/mo on 12 zero-order search terms + 2 EXCLUDE ASINs."
- UNTARGETED CONVERTERS: "5 search terms are converting but aren't targeted as keywords."
- KEYWORD THINNESS: "Only 6 active keywords; 0 search terms above 5 orders/mo — needs discovery."

### 5. BUDGET UTILIZATION (per campaign)
Utilization bar + OOB% chip + verdict (Constrained winner / Leaky / Mid-day exhaustion / Healthy), each
tied to HVA-3. Include a hero campaign at ₹350/day, 100% util, OOB 34%, ROAS 5.1 → constrained.

### 6. MARKET RESEARCH — client discussion points (two tables)
- A) "Top keywords where your PRICE fits": keyword, category monthly purchases, your price vs market →
  tag "We'll target" (green). Feeds the manual campaigns.
- B) "High-demand keywords where your price does NOT fit": keyword, purchases, your price vs market, gap
  → tag "Discussion point" (amber). Price/offer conversation with the client.

### 7. ACTION PLAN (filter: All · Campaign Creation · Rules · Optimizations)
- Campaign Creation (⚠️ red "Starts spending on approval"):
  HVA-1 SP AUTO — quality-ASIN discovery (harvest new converting terms);
  HVA-2 SP MANUAL EXACT ×2 — top-2 ASINs, ₹350/day, ~70% utilization, 10 SQP price-aligned keywords each;
  HVA-4 SB VIDEO — eligible (>₹15k) — reuse existing video or request/produce;
  HVA-5 SD VIEWS REMARKETING — ₹100/day, sale-period.
- Automation Rules (PAUSED badge — you enable):
  HVA-3 OOB PROTECTION — last-7d ROAS>3.5 campaigns kept OOB<20% across SP+SB+SD, capped, auto-reset;
  plus bid/negative guards.
- Optimizations: harvest 5 converters → exact; add 12 negatives (~₹90/day saved); reallocate budget to
  ROAS>3.5 winners; stop EXCLUDE-ASIN spend.

### 8. BOTTOM LINE
The 2/5 → 5/5 path (which HVAs the plan closes), output-HVA deltas vs pre-Elevate, and expected seller
outcome in money with assumptions. CTAs: "Approve plan" (primary), "Download report".

## INTERACTIONS & DATA
Sticky scroll-spy nav; task cards expand to the numbers + risk; status toggle Proposed→Approved (the
"spends immediately" flag stays on builds, the PAUSED badge stays on rules); live days-left + score dial.
Use the sample above as ONE illustrative Elevate seller (fictional "HearthNest" — not a real client's
figures). Model clean typed data: account, outputHVAs[], inputHVAs[5], eligibility[], gaps, budget[],
marketKeywords{aligned[], misfit[]}, tasks grouped by lane — so components are real and reusable.
```

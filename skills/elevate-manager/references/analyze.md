# Phase ANALYZE — the deep read that the build must trace to (read-only)

After EVALUATE gives the scorecard, ANALYZE produces the evidence that every task/rule will cite.
Five workstreams. No writes.

## 1. ASIN eligibility (the advertise-able set)

Take the **top 10 ASINs by GMS** (`get_product_performance`). For each, resolve **rating** — we do
NOT store it, so **crawl it** per the full method in
[reviews-and-ratings.md](reviews-and-ratings.md) (check `get_product_health` for a stored value
first; if the crawl is unavailable mark rating "unknown — needs crawl" and treat the ASIN as
ineligible, never guess). Then apply the eligibility rule from hva-framework:

> QUALIFY if rating > 3.5★ AND ≥ 2 units/30d AND ≥ 1 unit/7d; else EXCLUDE.

Produce a table: ASIN, name, GMS rank, rating (crawled), units 30d/7d, advertised?, **QUALIFY/EXCLUDE**.
Call out (a) **qualifying but UNADVERTISED** heroes (→ HVA-1 auto + the top-2 → HVA-2), and
(b) **EXCLUDE ASINs that are currently advertised** (spend leak → optimization to stop).

## 2. Item-level health

Per top ASIN: ACoS, ROAS, CVR, stock/days-of-cover, buy-box %, plus the eligibility verdict.
Classify HERO / CONTENDER / WATCH / EXCLUDE (`get_product_health`, `get_entity_tiers`). This drives
which ASINs get HVA-1/HVA-2 and which get spend cut.

## 3. Budget utilization

Per campaign (`get_budget_constrained_campaigns`, `get_realtime_budget_usage`,
`get_campaign_performance`): daily budget, utilization %, **OOB %**, last-7d ROAS, and a verdict:
- OOB > 20% AND ROAS > 3.5 → **constrained winner** (→ HVA-3 rule protects it)
- full budget AND ROAS < target → **leaky** (fix bids/negatives before adding budget)
- spends most of budget before peak → **mid-day exhaustion** (daypart)
- else **healthy**.
Quantify lost hours / lost impression share due to budget.

## 4. Wasted spend & untargeted converters (the two seller-benefit leaks)

- **Wasted spend**: `get_waste_search_terms` — terms with spend and 0 orders (or ACoS ≫ target).
  Sum the ₹/mo. → negatives (optimization).
- **Untargeted converters**: `get_harvest_opportunities` / `get_search_term_analysis` — search terms
  that CONVERTED (orders) but are not yet targeted as keywords. → harvest to EXACT (optimization; and
  feeds HVA-2 where price-aligned). Note the account's keyword thinness (few keywords; ~no terms
  above 5 orders/mo) — the justification for the HVA-1 auto campaign.

## 5. Market-level research (mandatory — two lists, always)

From category SQP / market data (`get_search_catalog_performance`, `get_sqp_performance`,
`get_sqp_share_of_voice`) build the two lists from hva-framework:

- **A) Price-aligned** — top category keywords, high purchase volume, seller's price **fits** →
  columns: keyword, category monthly purchases, seller price vs market price, "we'll target". This is
  the **source for the HVA-2 top-10 keyword pick** (then relevance-checked).
- **B) Price-misfit** — top category keywords, high purchase volume, seller's price **does not fit**
  → columns: keyword, purchases, seller price vs market, the gap, "discussion point". These are
  **mandatory client discussion points** — always present, never drop.

## Output of ANALYZE

A compact findings block: eligibility table, item-level classes, budget-utilization table with
verdicts, the ₹ of wasted spend + the count of untargeted converters, and the two market-research
lists. Every number here becomes the citation for a BUILD task. Then proceed to BUILD.

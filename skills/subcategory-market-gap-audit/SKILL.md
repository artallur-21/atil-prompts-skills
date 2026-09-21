---
name: subcategory-market-gap-audit
description: |
  Build a subcategory-level Amazon growth / keyword-targeting audit for ONE account
  and deliver it as a formatted Google Sheet. Use when the user asks to "run a
  subcategory audit", "market gap audit", "keyword targeting audit by subcategory",
  "build a growth audit for <account/prospect>", "where are the sales coming from and
  where is the whitespace", "categorize the account and show market cap / share / gap
  per subcategory", or wants an onboarding pitch deck of "you earn this today, here's
  the headroom". Produces: README + Summary scorecard + one tab per subcategory, each
  with market cap, our sales & source (paid vs organic), spend & returns
  (CTR/CVR/ACoS), share, the search-query gap, competitor top-3 & whether we target
  them, and suggestions. Read-only analysis; never writes to the ad account. NOT for
  single-metric lookups (query directly) or campaign execution (use ppc-manager /
  amazon-ads-os).
---

# Subcategory Market-Gap Growth Audit

Turn one account's search data into a subcategory-by-subcategory growth story:
**where the sales come from, where the money goes, how big the market is, where the
search-query gap is, and what to do.** Output is always a formatted Google Sheet
(README → Summary → per-subcategory tabs). This skill is the *logic*; supply the
account at run time.

## Golden rules (do not violate)

1. **Read-only.** This audit never writes to the ad account. It only reads DB + writes a Google Sheet.
2. **Settled window only.** End every analysis window at **today − 16 days** (14-day attribution + reporting lag). Verify with the `purchases_14d/1d` ratio (~1.2–1.45 = settled; ~1.0 = not accrued). See `amazon-growth-agent/references/measurement-contract.md` §3.
3. **Resolve columns per profile.** SELLER uses `sales_7d`/`purchases_7d` on SP campaign/searchterm/target tables; VENDOR uses `_14d`; SB/SD and SP keywords use bare `sales`/`purchases`. The wrong column returns NULL silently. Orient first.
4. **No hardcoded taxonomy.** Subcategories are derived from *this account's own query vocabulary* every run (Step 2). Never reuse another account's product tokens.
5. **Label every number** with source + window. `UNAVAILABLE` beats a fabricated number.

## Step 0 — Orient (resolve the account)

Run the growth-agent orienter (read-only): it resolves `profile_id`, SELLER vs
VENDOR, currency, marketplace, data-gate freshness, SQP breadth, and the attribution
curve.

```
.claude/skills/amazon-growth-agent/scripts/orient.sh "<brand or profile_id>"
```

Capture: `{{PROFILE}}` (profile_id), `{{MP}}` (marketplace_id), SELLER/VENDOR (→ column
set), currency, and confirm SQP breadth is healthy (ASIN count not collapsed). Set the
window: `{{TO}}` = today−16d, `{{FROM}}` = `{{TO}}` − 60d; `{{M1}}`,`{{M2}}` = the two
most recent complete SQP months inside that window.

DB access: `ssh scaleskus "sudo mysql amazon_ads …"` (read-only SELECTs). Python:
`/usr/bin/python3` (has openpyxl + the atil-services helpers on the path
`~/.claude/skills/atil-services/scripts`). All SQL templates live in
`references/queries.sql` — parameterized with the placeholders above.

## Step 1 — Pull the raw grain

From `references/queries.sql`, run (export each to a TSV):

- **SQP 60d per query** (`sqp_60d`): market impressions/clicks/orders + our
  impressions/clicks/orders + market & our median price. This is the market
  denominator and our share. Filter `HAVING SUM(market_orders) >= 5`.
- **Ad 60d per search term** (`ad_60d`): SP+SB impressions, clicks, spend, orders,
  sales over `{{FROM}}..{{TO}}`.
- **Account KPIs 60d** (`acct_kpis`): total sales, units, sessions, business CVR from
  `sp_api_daily_summary`.
- **Enabled keywords** (`kw_enabled`), **our product-target ASINs** (`our_targets`),
  **competitor top-3 per term** (`competitors`, from `sp_api_search_terms_brand` for
  `{{MP}}` latest month). See `references/search_terms_brand.md` for populating the
  marketplace report if absent.

## Step 2 — Derive the subcategory taxonomy (per account)

Subcategories are **product-type clusters of the account's queries**, built fresh:

1. Read the top ~300–400 SQP queries by market orders.
2. Read the leaf categories / titles from `product_catalog` **if populated**
   (`catalog:sync-products --profile={{PROFILE}}`); if the catalog is empty or the
   sync errors, subcategorize at the **keyword grain** from the query vocabulary
   instead — this is the normal path for trial/prospect accounts.
3. Group queries into 8–14 subcategories by product-type tokens you observe in *this*
   account (e.g. a fashion account yields "kurtas / dresses / footwear …"; a kitchen
   account yields "curd makers / oil dispensers / masala containers …"). One ordered
   rule list, first match wins; a generic "Other <material/category>" catch-all last.
4. **Exclude off-category noise** (grocery, competitor-brand-only, wrong-department
   terms) with an explicit drop list — state what you dropped.
5. Apply the *same* rules to both SQP queries and ad search terms so market and spend
   aggregate on one taxonomy.

Keep the token rules in the run's scratchpad; they are account-specific by design.

## Step 3 — Compute every metric (definitions are binding)

Per subcategory (and per keyword for the detail tables):

| Metric | Formula |
|---|---|
| **Market Cap ₹** | Σ (market_orders × market_median_price) over the subcategory's queries |
| **Our Rev ₹** (search-attributed) | Σ (our_orders × our_price) from SQP — the SEARCH slice, *not* total sales |
| **Purchase / Impr / Click Share %** | our ÷ market at that funnel stage (SQP) |
| **Our CVR / Market CVR %** | orders ÷ clicks (SQP), ours vs market |
| **CTR %** | ad clicks ÷ ad impressions |
| **Ad CVR %** | ad orders ÷ ad clicks (distinct from Business CVR = units ÷ sessions) |
| **ACoS %** | ad spend ÷ ad sales · **TACOS %** = ad spend ÷ total sales |
| **Source split** | Paid = ad sales; Organic = our search rev − paid |
| **Gap ₹ (upside)** | Σ (market_orders − our_orders) × market_price where our purchase share < 5% |
| **Targeting status** | Keyword-targeted (enabled keyword exists) / Auto-Broad only (in ad report, no keyword) / Not served |
| **Comp Targeted?** | of the term's top-3 marketplace ASINs, how many are in our ENABLED product targets |

Funnel read: if **impression share ≪ purchase share**, the account converts but is
invisible → visibility is the ceiling (grow reach). If purchase share ≪ click share,
it's a price/listing/offer problem → fix retail before spending.

## Step 4 — Diagnose before prescribing

- **Source:** what % of total sales is ad vs organic; what % comes via *any* search
  query (SQP) vs branded (`search_query LIKE brand`). Branded is usually tiny — say so.
- **Spend placement:** split ad spend into IN-SQP (measurable demand) vs NOT-in-SQP,
  and break NOT-in-SQP into ASIN/product-targeting (intentional) vs long-tail
  off-radar (the real leak). Reconcile: Σ search-term spend ≈ campaign spend.
- **Retail chain** (stop at first hit): availability → Buy Box → price → reviews →
  listing → traffic mix → competition → our own changes → only then bids. Report the
  level you stopped at. `product_catalog` empty ⇒ flag the ASIN-level blind spot.
- **History before negation:** never propose cutting a term with lifetime orders > 0.

## Step 5 — Build the deliverable

Follow `references/build_recipe.md`. Structure:

- **README** — sources (tables), date range + why today−16d, metric logic,
  subcategorization method + exclusions, caveats, "prepared by ATIL / ScaleSKUs".
- **Summary** — account KPIs (60d), source split, a subcategory scorecard (market
  cap, our rev, share, spend, ad sales, ACoS, CTR, Ad CVR, gap), and a "way forward"
  block with a capturable-upside line (e.g. gap × a conservative target share).
- **One tab per subcategory** — a KPI block (market cap / search vol / market CVR |
  our rev / share / our CVR), an invest+source+gap line, a targeting-counts line, a
  **WHAT TO DO** row, then the detailed keyword table (one row per keyword, all Step-3
  metrics + targeting status + top-3 competitors + comp-targeted + a per-row
  suggestion).

Use the `atil-services` google_sheets helper (`create`, `write` with USER_ENTERED,
`batch_update` for formatting, `google_drive.share(type="anyone")`). Executive
formatting: navy title, slate section headers, gold "what to do", frozen header rows,
₹ and % number formats, sensible column widths. Every tab self-contained with its own
summary.

## Step 6 — Present & offer next steps

Lead with the business number and the one-line thesis (e.g. "₹X in 60d but ~N%
purchase share of a ₹Y market — visibility is the ceiling"). Offer, don't auto-build:
an upside model (current → target-share revenue + ad investment), a negation list
(with lifetime-order guards), or a letterhead PDF via `atil-company-info`.

## Guards recap

Settled window · per-profile columns · master-table dedup (freshest row, not `MAX()`)
· TACOS denominator = `sp_api_daily_summary.ordered_product_sales` · SQP breadth check
· lifetime history before any negation · read-only. Full contract:
`amazon-growth-agent/references/measurement-contract.md`.

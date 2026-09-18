# Reviews & Ratings — what to crawl and how (HVA-1 eligibility gate)

HVA-1 (and ASIN eligibility everywhere) needs a **star rating**. We do **not** store ratings, and no
Amazon API returns the aggregate star number reliably (Ads API doesn't have it; SP-API `getAccount`
is PII-gated; SP-API Customer Feedback gives review *topics/sentiment*, not the average star). The
only authoritative source of the number is the Amazon storefront itself → we **crawl** it. This
methodology is platform-neutral; only the execution tool differs (Claude vs ChatGPT).

## Order of operations

1. **Check for a stored value first.** Call `get_product_health` / `get_asin_traffic` for the ASIN —
   if a recent rating is already present (e.g. from the platform's SERP crawler
   `keyword_rank_positions.rating`), use it and skip the live crawl.
2. **Otherwise crawl the product detail page (PDP)** for the ASIN on the account's marketplace.
3. **If the crawl is blocked/unavailable → rating = "unknown".** Treat the ASIN as **ineligible**
   (never guess a rating) and flag it for a manual check. Do not advertise an unknown-rating ASIN.

## What to crawl

The ASIN's PDP on the marketplace domain: `https://www.amazon.<tld>/dp/<ASIN>` (and, as a fallback,
the SERP for the ASIN's primary keyword, which also shows the star + review count).

Marketplace → domain: IN `amazon.in` · US `amazon.com` · AE `amazon.ae` · SA `amazon.sa` ·
UK `amazon.co.uk` · DE `amazon.de` · etc. Use the **profile's marketplace** (do not default to .com).

## What to extract (and record)

- **Average star rating** (e.g. "4.3 out of 5 stars") → the gate value.
- **Total review/rating count** (e.g. "1,284 ratings") → confidence: a 3.6★ on 8 ratings is weak
  signal; note low counts (< ~20) as low-confidence.
- **Rating distribution** (% 5★…1★) if visible → detect a recent 1-star flood.
- **Recent-review sentiment** (optional, stronger gate): scan the most recent reviews for a
  net-positive vs net-negative balance, or use SP-API Customer Feedback topics (`starRatingImpact`)
  where available — used only as a health check, never shown as a rating.
- Record per ASIN: `rating`, `review_count`, `crawl_source_url`, `crawled_at`.

## How to execute (per platform)

- **Claude (Claude Code / desktop)**: use the platform's crawl path — its SERP/keyword-rank crawler
  (which already stores `keyword_rank_positions.rating`) or a browser tool. **Crawl from the Mac /
  approved crawl host, NEVER from the production VPS** — datacenter-IP traffic risks getting the
  server IP flagged by Amazon (this is a standing platform rule). Space requests; don't hammer.
- **ChatGPT**: use web browsing to open the PDP URL and read the star rating + review count directly.
  Same discipline: one request per ASIN, don't loop aggressively.
- Either way this is **bounded**: only the **top-10-by-GMS candidate set per account** (not the whole
  catalog), refreshed per audit — a few page reads, not a scrape.

## Apply to eligibility

Combine the crawled rating with the units data we DO hold (from `get_product_performance` /
`sp_api_business_reports`):

> **QUALIFY** if `rating > 3.5★` AND `units_30d ≥ 2` AND `units_7d ≥ 1`. Else **EXCLUDE**.

Stronger optional gate (recommended when data is present): also require net-positive recent reviews
(no fresh 1-star flood). An ASIN that clears units but is rated ≤ 3.5★ is EXCLUDE — do not build a
campaign for it; instead flag "improve rating / fix listing" as a seller discussion point.

## Output

An eligibility table (feeds ANALYZE §1): ASIN · name · GMS rank · **rating (crawled)** · review
count · units 30d/7d · advertised? · **QUALIFY/EXCLUDE** · source+timestamp. The QUALIFY set is the
input to HVA-1 (unadvertised) and HVA-2 (top-2 by sales).

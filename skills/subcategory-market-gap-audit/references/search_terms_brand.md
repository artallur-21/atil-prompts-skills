# Competitor top-3 — the marketplace Top Search Terms report

The "who ranks top-3 on this keyword, and do we target them?" column comes from
`sp_api_search_terms_brand` — the **marketplace-wide** Amazon Brand Analytics Top
Search Terms report (identical for every seller in a marketplace; stored once per
`(marketplace_id, report_period, date_from)`, NO profile_id). Each term carries its
top-3 clicked ASINs + brand + click share. Full contract:
`~/.claude/.../memory/reference_search_terms_brand_report.md`.

## Is it already populated?
```
SELECT report_period, date_from, date_to, COUNT(*) rows, COUNT(DISTINCT search_term) terms
FROM sp_api_search_terms_brand WHERE marketplace_id='{{MP}}'
GROUP BY report_period,date_from,date_to ORDER BY date_to DESC;
```
- If a MONTH row covers your `{{M2}}` with a large term count → use it.
- The scheduled pull defaults to `--relevant-only=1` (only ~terms our clients spend
  on) → shallow. For a full competitor picture pull the **whole** report.

## Populate (full report) if missing
```
sudo -u www-data php8.3 /var/www/reports.atil.ltd/artisan amazon:pull-search-terms-report \
  --period=MONTH --weeks=<N months> --relevant-only=0 --keep-days=0 --marketplace={{MP}}
```
`--relevant-only=0` = every term (≈1.6M rows/month for a big marketplace; run in
background, ~6–14 GB memory). `--keep-days=0` = don't prune history. It reads Amazon
via any brand-registered credential in that marketplace; it does **not** need the
audited account to have API access — the report is marketplace-wide. This is a heavy
prod pull: get the user's OK first, then background it and monitor row counts.

## Join for the audit
Detect the **top-3 clicked ASINs** per audited term, then check each against our
ENABLED product targets (`our_targets`, the `/B0[A-Z0-9]{8}/` set from
`master_sp_targets`): `Comp Targeted? = Yes n/3` if we product-target n of the three,
else `No`. Brand/name comes from `clicked_item_name` (first token). Competitor
**price** is NOT in this report or the catalog for many marketplaces (e.g. IN list
price is ~0% populated) — mark price "live-pull pending" rather than fabricating; a
live SP-API Product-Pricing `getItemOffers` lookup can fill it if the user wants.

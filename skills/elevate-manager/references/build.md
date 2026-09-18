# Phase BUILD — turn gaps into tasks + rules (human-gated)

Every item traces to an EVALUATE ❌/⚠️ or an ANALYZE finding, with the number. Materialize as `tasks`
rows (pending) and automation rules (paused) — never free-text. Present, dry-run, approve, execute.

## What to build (in this order)

### The 5 HVA activities (exact params from hva-framework)

1. **HVA-1 · SP AUTO** — one Sponsored Products **Automatic** campaign over the top-GMS **eligible +
   unadvertised** ASINs. Target ROAS ≥ 3.5. Purpose tag: "discovery — harvest new converting terms".
   Tool: `create_campaign` (SP, targetingType=auto) — **one flow** (campaign + ad group + product ad
   in one approved task; up-and-down + 100% ToS defaults). ⚠️ ACTIVE on approval → spends immediately.
2. **HVA-2 · SP MANUAL EXACT ×2** — for each of the top-2-by-sales **eligible** ASINs: SP **Manual**,
   1 ASIN, 1 ad group, **₹350/day**, ~70% utilization target, **EXACT** match, **up-and-down bidding +
   100% top-of-search** (locked defaults). Keywords = the top-10 **price-aligned + relevance-checked**
   SQP queries from ANALYZE list A; **bids = the Amazon theme-based bid-suggestion median** per keyword
   (fallback: discovery suggested ±25% when theme-based has no price — needs ≥ 5 keywords/ad group).
   **One approved `create_campaign` task builds the whole campaign** — ad group + product ad + EXACT
   keyword targets — no manual chaining of `create_ad_group`/`create_keyword` for a new campaign.
   ⚠️ ACTIVE on approval.
3. **HVA-3 · OOB RULE** — `create_automation_rule` (type=budget), **created PAUSED**: over last 7d,
   ROAS-from-cost > 3.5 → keep OOB < 20% by raising/protecting daily budget within a cap, daily
   auto-reset. Scope: SP + SB + SD campaigns meeting the ROAS test. Note "verify
   AUTOMATION_DRY_RUN=false before enabling".
4. **HVA-4 · SB VIDEO** — only if last-30d spend > ₹15,000. If a brand video exists → new SBV reusing
   the asset; else a task "seller to provide video / ATIL to produce". Tool: `create_campaign` (SB
   video) or a task if no asset.
5. **HVA-5 · SD VIEWS REMARKETING** — one SD views-remarketing campaign, **≥ ₹100/day**, sale-period
   framing. Tool: `create_campaign` (SD, audience=views remarketing).

### Optimizations (seller benefit)

- Negatives for wasted terms (`add_negative`) — cite ₹/day saved.
- Harvest converting-but-untargeted terms → EXACT (`create_keyword`/`harvest_keyword`).
- Budget reallocation from leaky → constrained winners (`adjust_budget`).
- Step down / pause EXCLUDE-ASIN spend.

Each optimization = a `tasks` row with `metrics_json` = the ANALYZE row that produced it.

## Present → approve → execute

Present one plan table grouped by lane — **Campaign creation** (⚠️ spends on approval) ·
**Automation rules (PAUSED)** · **Optimizations** — sorted by (seller $ impact × HVA lift ×
confidence × reversibility), with the HVA each advances.

Then: offer **Approve all / by group / by number**. Execute via `execute_tasks` (or
`/intelligence/tasks/bulk-execute`) with **dry_run=true first**; show the dry-run summary; go live
only on an explicit "go live". Sequence: negatives → bid/budget → new campaigns → rules-enable last.
Capture rejected items as `status='rejected'`.

**Engineer pre-flight (server-side).** The platform's deterministic Elevate planner assembles the
HVA-1/HVA-2 campaigns and prices the theme-based-median bids. To see the exact Amazon Ads v1 payload
(campaign + ad group + product ad + keyword bids) and the budget headroom for one account **without
writing anything**, run `php artisan elevate:dry-run-campaign --profile=<profile_id>` (dry-run;
optional `--asin=`). Use it to validate a build before the operator approves it live.

## Guardrails (load this section on any push-back)

- **New campaigns target ROAS ≥ 3.5**; reject any change predicted to breach account **ROAS > 3.5 /
  TACoS ≥ 10%** — propose the seller-first alternative instead.
- **Rules are created PAUSED**; the operator enables them. Confirm `AUTOMATION_DRY_RUN=false` in prod
  before an enable is meaningful.
- **Spend discipline**: floor ₹7,500/mo; raises capped at **+15% MoM** unless the seller approves
  more (aim 25%, commit 15%).
- **Never advertise EXCLUDE ASINs** (fails eligibility). Flag them for the seller to fix (stock/rating).
- **No invented keywords** — only SQP / converting / relevance-checked terms; drop irrelevant ones.
- **Never write to Amazon directly** — only through the tasks pipeline. Default dry-run first.
- If data is insufficient for a claim (e.g. a rating not yet crawled), request it — do not guess.

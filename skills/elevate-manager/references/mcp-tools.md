# ScaleSKUs MCP — knowledge & tool map (Claude + ChatGPT)

This skill runs on **any assistant connected to the ScaleSKUs MCP** — Claude (Claude Code / desktop)
or ChatGPT (connector / custom GPT). The instructions are model-neutral; only the connection step
differs.

## What the MCP is

The ScaleSKUs MCP is the platform's tenant-scoped tool surface over the live Amazon Ads + SP-API data.
- **READS** are row-level-security scoped to the operator's assigned accounts (tenant + RLS).
- **WRITES do not touch Amazon directly.** Every create/adjust/negative tool writes a **task** into
  the platform's tasks pipeline (`mcp:actions`) for human approval + audit + rollback. Automation
  rules are created **paused**. So "propose" in this skill = call the write tool → a pending task.

## Connecting (per platform)

- **Claude Code / Claude desktop**: the ScaleSKUs MCP server is configured as an MCP connector; tools
  appear as `mcp__…__<tool>`. This skill auto-loads on matching intent.
- **ChatGPT**: add ScaleSKUs as a connector / custom-GPT action. Upload this skill's `SKILL.md` as the
  GPT's instructions and the `references/*.md` as knowledge files. ChatGPT then calls the same tools.

## Two portability rules that bite (both platforms, ChatGPT especially)

1. **IDs are tokenized.** The MCP hands back **opaque handles** (e.g. a profile handle like `prf_…`).
   Pass them back **verbatim**. Never fabricate, "tidy", or guess an ID — a made-up handle returns
   `unknown_handle`. When you only have a name, resolve it with `find_entity` / `list_profiles`, or
   pass the parent **by name** to create tools (they accept handle OR name).
2. **Result sets are capped.** List tools return ~10 rows by default, 200 max; `run_analysis_query`
   caps ~5k rows / 15s. Page/aggregate deliberately; don't assume you got the full set.

Reads are live fact/master tables (never stale `intelligence_*`). The MCP also exposes a guide/RAG
layer — `list_guides` / `search_guides` / `read_guide` (`guide://scaleskus/*`) — consult it if a
metric's definition or a tool's contract is unclear.

## Tool map by phase

### SCOPE / cohort
- `list_profiles` — resolve profile + handle; confirm Elevate + window.
- `run_analysis_query` — enumerate the cohort, pre-Elevate baseline windows, bespoke aggregates.
- `get_sync_status` — fully synced / backfill complete? (⚪ NEW vs verdict-ready).

### EVALUATE
- `get_profile_summary` — GMS, spend, TACoS, ROAS, 30d spend (HVA-4 gate).
- `get_campaign_structure` — which campaigns/types exist (HVA-1/2/4/5 presence).
- `get_product_performance` — per-ASIN advertised? + sales rank (HVA-1/2 candidates).
- `get_budget_constrained_campaigns` / `get_realtime_budget_usage` — OOB signal (HVA-3).
- `get_campaign_performance` — per-campaign ROAS (the HVA-3 ROAS>3.5 test).
- `get_automation_rules` — is an OOB rule already present?
- `get_profit_loss` — GMS/TACoS vs baseline; `get_account_daily_trend` — spend MoM.

### ANALYZE
- `get_product_performance` + `get_product_health` + `get_entity_tiers` — item-level classes; check
  `get_product_health` / `get_asin_traffic` for any **stored rating** before crawling.
- **Rating/reviews** — see [reviews-and-ratings.md](reviews-and-ratings.md) (we do not store ratings).
- `get_waste_search_terms` — wasted spend → negatives.
- `get_harvest_opportunities` / `get_search_term_analysis` — converting-but-untargeted terms.
- `get_search_catalog_performance` / `get_sqp_performance` / `get_sqp_share_of_voice` — SQP for the
  HVA-2 keyword pick and the two market lists (price-aligned vs price-misfit).
- `get_inventory` — stock / days-of-cover for eligibility + EXCLUDE.

### BUILD (writes → tasks pipeline; rules paused)
- `create_campaign` — SP auto (HVA-1), SP manual (HVA-2), SB video (HVA-4), SD remarketing (HVA-5).
- `create_ad_group` / `create_keyword` / `create_target` / `create_product_ad` — structure the
  manual campaigns (1 ASIN/ad group, EXACT keywords at median bids). Parents by handle OR name.
- `create_automation_rule` — the OOB rule (type=budget), **paused**.
- `add_negative` — wasted-term negatives. `harvest_keyword` — converters → EXACT.
- `adjust_budget` / `adjust_bid` — reallocation / bid tuning within the ±25% band.
- `pause_entity` — stop EXCLUDE-ASIN spend.
- `execute_tasks` — run approved tasks (**dry_run=true first**).

### TRACK
- `get_agency_recommendations` / `get_recommendations` — cross-account signal (advisory only).
- `get_tasks` — what is already pending/approved per account (don't double-propose).
- `get_change_history` — recent changes (avoid re-doing; verify executions).

## Guardrail reminders
Human-gated + dry-run-first for every write. New campaigns ACTIVE on approval (⚠️ flag spend); rules
PAUSED. Seller-benefit + ROAS>3.5 / TACoS≥10% beats an HVA checkbox. One profile per reasoning unit —
never blend metrics across profiles (Elevate is per advertiser; dedupe on the profile handle).

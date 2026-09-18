# Phase EVALUATE — score the account (read-only)

Goal: a per-account **HVA scorecard** — the 5 input HVAs (→ X/5) + the 4 output HVAs vs the
pre-Elevate baseline — computed from live MCP data. No writes. This is the gate that decides what
ANALYZE and BUILD focus on.

Load [mcp-tools.md](mcp-tools.md) for the exact tool per signal. Always start by resolving the
profile (`list_profiles`) and confirming it is Elevate-tagged and inside its window.

## Score the 5 INPUT HVAs

For each, produce: **status ✅ / ⚠️ / ❌**, the current number, the target, and one line of evidence.

- **HVA-1 (SP Auto / quality-ASIN coverage)** — Are the account's top-GMS **eligible** ASINs
  advertised, and does an SP Auto discovery campaign exist? ❌ if the top eligible ASINs are
  unadvertised or there is no auto campaign harvesting terms. Signal: `get_campaign_structure`,
  `get_product_performance` (advertised? per top-GMS ASIN). (Eligibility itself is confirmed in ANALYZE.)
- **HVA-2 (SP Manual Exact ×2)** — Do the top-2-by-sales ASINs each have a structured single-ASIN
  MANUAL exact campaign? Score 0/1/2 built → ❌/⚠️/✅. Signal: `get_campaign_structure`,
  `get_product_performance`.
- **HVA-3 (OOB protection)** — Do ROAS>3.5 campaigns stay **OOB < 20%**, and is the protective rule
  in place? ❌ if any ROAS>3.5 campaign is OOB ≥ 20% and no rule guards it. Signal:
  `get_budget_constrained_campaigns`, `get_realtime_budget_usage`, `get_campaign_performance` (ROAS),
  `get_automation_rules` (is an OOB rule present?).
- **HVA-4 (SB Video)** — Is the account **eligible** (last-30d spend > ₹15,000) and does an SBV
  campaign exist? ❌ if eligible but no SBV; N/A if under the spend gate (note it, don't fail it).
  Signal: `get_profile_summary` (30d spend), `get_campaign_structure` (SB video present?).
- **HVA-5 (SD Views remarketing)** — Does a Sponsored Display **views-remarketing** campaign exist
  (≥ ₹100/day)? ❌ if none. Signal: `get_campaign_structure`.

**Score = count of ✅** (⚠️/partials do not count toward the 5). Report **X/5** with the reminder
"≥3/5 = pass, 5/5 = goal", and name exactly which activities would move each ❌/⚠️ to ✅.

## Score the 4 OUTPUT HVAs (vs pre-Elevate baseline)

- **GMS growth** — current-period GMS vs the pre-Elevate baseline window. Target **≥ +10%**.
  Signal: `get_profit_loss` / `get_profile_summary` GMS (ordered product sales); baseline via
  `run_analysis_query` over the pre-service window.
- **Monthly ad spend** — current monthly ad spend and its MoM delta. Target **≥ +15% MoM OR ≥
  ₹7,500/mo, whichever higher**. Flag if under the ₹7,500 floor. Signal: `get_profile_summary`,
  `get_account_daily_trend`.
- **TACoS** — account TACoS. Target **≥ 10% or the desired GR-level TACoS, whichever higher**.
  Treat as monitor-only (do not "fix" by cutting spend). Signal: `get_profit_loss` / `get_profile_summary`.
- **ROAS** — account ROAS. Target **> 3.5**. Signal: `get_profile_summary`.

## Output of EVALUATE

```
## Elevate Scorecard — <store name> (<profile>) — <window, day N of 60, D days left>
INPUT HVAs: X/5  (pass ≥3/5 · goal 5/5)
| HVA | Status | Current | Target | What closes it |
OUTPUT HVAs (vs pre-Elevate):
| Metric | Current | Baseline | Target | Status |
Verdict: <PASS / AT-RISK / OFF-TRACK> + the one-line reason.
```

Then proceed to ANALYZE for any account that is not already 5/5 with all output HVAs green (and even
then, run the optimization scan). For a cohort run, stop here per account and hand the scorecard to
TRACK.

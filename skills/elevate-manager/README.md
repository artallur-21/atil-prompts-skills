# elevate-manager — install & use

An installable skill that runs the Amazon **Elevate** managed-service loop —
**EVALUATE → ANALYZE → BUILD**, plus a cohort **TRACK** surface — on **Claude or ChatGPT**,
against the ScaleSKUs MCP. Internal ATIL operators only. It never writes to Amazon directly:
every campaign / rule / optimization becomes a **pending task** (new campaigns ACTIVE-on-approval;
automation rules created PAUSED).

Files: `SKILL.md` (the operating contract) + `references/` (hva-framework, mcp-tools, evaluate,
analyze, reviews-and-ratings, build, tracking).

## Prerequisites (both platforms)
- **ScaleSKUs MCP access** for the operator: the Elevate accounts assigned to them (READ is
  RLS-scoped) and write entitlement so task-creation tools work (`MCP_ACTIONS_ENTITLED_ORG_IDS`).
- **A rating source** for the HVA-1 crawl: on Claude, the platform crawler / a browser **on the Mac
  (never the VPS)**; on ChatGPT, **web browsing enabled**. (See `references/reviews-and-ratings.md`.)

---

## Install on Claude

**A. Team / this project (recommended)** — it already lives at `.claude/skills/elevate-manager/`.
1. Commit + push it; teammates `git pull`.
2. Ensure the ScaleSKUs MCP is connected in their Claude Code (MCP connector configured).
3. It auto-discovers as a project skill — no extra step. Confirm with `/skills` (or just use a
   trigger phrase below).

**B. Personal / all projects** — copy the folder to your user skills dir:
```bash
cp -R .claude/skills/elevate-manager ~/.claude/skills/elevate-manager
```
Now it's available in any project you open with the MCP connected.

**Invoke:** type a trigger phrase (below) and Claude auto-loads it, or call it explicitly with
`/elevate-manager`.

---

## Install on ChatGPT (Custom GPT)

1. **Create a GPT** — ChatGPT → *Explore GPTs → Create* (GPT Builder → *Configure*).
2. **Instructions** — paste the body of `SKILL.md` into the GPT's *Instructions* box.
3. **Knowledge** — upload all seven `references/*.md` files as *Knowledge* files. (The GPT reads them
   the way Claude loads references.)
4. **Connect the MCP** — add ScaleSKUs as a *Connector* / *Action* (the MCP endpoint + OAuth) so the
   GPT can call the same tools. Confirm it can `list_profiles`.
5. **Browsing on** — enable web browsing (needed for the rating crawl).
6. Chat with the GPT using the same trigger phrases.

> Portability note (in `references/mcp-tools.md`): the MCP returns **opaque ID handles** — pass them
> back verbatim, never invent one — and result sets are capped (10/200 rows). This matters on ChatGPT
> especially.

---

## How to use — one line drives it

| Type this | You get |
|---|---|
| `Elevate status` · `Elevate scorecard` | Whole-cohort table, ranked by risk (🔴/🟠/🟢/⚪) |
| `Where are the HVAs not hitting` | 5-HVA ✅/❌ matrix across the cohort + "missing on K accounts" tally |
| `Where is payout at risk` · `Elevate billing risk` | Only the at-risk sellers, each with the blocking gap + the one fix |
| `Audit <account>` · `Run Elevate on <account>` | Full EVALUATE → ANALYZE → BUILD for one seller |
| `Run Elevate` · `Elevate weekly review` | **Automatic mode**: score the cohort, then draft fixes (pending tasks + paused rules) for every at-risk seller |
| `Build the Elevate campaigns/rules for <account>` | The BUILD step (runs EVALUATE+ANALYZE first if needed) |

## What happens (and where you stay in control)
1. **EVALUATE** — a scorecard: 5 input HVAs → X/5 (pass ≥3/5, goal 5/5) + the 4 output HVAs vs the
   pre-Elevate baseline.
2. **ANALYZE** — ASIN eligibility (with the **rating crawl**), item-level health, budget utilization,
   wasted spend, untargeted converters, and the two market-research keyword lists (price-aligned to
   target · price-misfit = client discussion points).
3. **BUILD** — the 5 activities + the OOB rule + optimizations, laid down as **pending tasks** and
   **paused rules**. It **dry-runs first** and shows you the summary.
4. **You approve** — "approve all / by group / by number", then "go live". New campaigns start
   spending on approval (it flags this ⚠️); rules stay **PAUSED until you enable them** — and confirm
   `AUTOMATION_DRY_RUN=false` in prod before an enable is meaningful.

## Guardrails (always on)
Elevate cohort only · no direct Amazon writes (tasks pipeline only) · seller-benefit and
ROAS > 3.5 / TACoS ≥ 10% beat any HVA checkbox · EXCLUDE ASINs (rating ≤ 3.5★ / OOS / no buy-box) are
never advertised · no invented keywords · spend floor ₹7,500/mo, raises capped at +15% MoM.

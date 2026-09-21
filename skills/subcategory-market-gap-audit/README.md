# subcategory-market-gap-audit

Build a **subcategory-level Amazon growth / keyword-targeting audit** for ONE account and
deliver it as a formatted Google Sheet. Read-only analysis — it never writes to the ad
account; it only reads the ScaleSKUs DB and writes a Sheet.

Use it to win/keep an account: *"here's what you earn today, by subcategory, and here's the
headroom."* Great for prospect pitches and quarterly account reviews.

## Trigger phrases
- "run a subcategory audit for `<account>`" · "market gap audit"
- "keyword targeting audit by subcategory"
- "where are the sales coming from and where's the whitespace"
- "categorize the account and show market cap / share / gap per subcategory"
- "build the onboarding growth audit for `<prospect>`"

## What it produces
A Google Sheet: **README → Summary scorecard → one tab per subcategory**. Each subcategory
tab carries market cap, our sales & source (paid vs organic), spend & returns
(CTR / Ad-CVR / ACoS), purchase/impression share, the search-query gap, the top-3
marketplace competitors + whether we product-target them, and per-keyword suggestions.

## How it works (logic, not accounts)
Every run: orient the account (SELLER vs VENDOR columns, settled window), **derive the
subcategory taxonomy from that account's own query vocabulary** (never hardcoded), pull the
market (SQP) + our ads + targeting + competitor grain, compute every metric, diagnose
(convert-but-invisible vs retail-broke vs priced-out), then build the Sheet.

## Files
- `SKILL.md` — the workflow, golden rules, and binding metric formulas.
- `references/queries.sql` — parameterized SQL (`{{PROFILE}} {{MP}} {{FROM}} {{TO}} {{M1}} {{M2}}`).
- `references/build_recipe.md` — the exact Sheet structure, column schema, suggestion logic, palette.
- `references/search_terms_brand.md` — sourcing competitor top-3 + the "do we target them?" join.

## Install
```bash
git clone https://github.com/artallur-21/atil-prompts-skills.git ~/Projects/atil-prompts-skills
ln -s ~/Projects/atil-prompts-skills/skills/subcategory-market-gap-audit ~/.claude/skills/subcategory-market-gap-audit
```
Then say a trigger phrase with an account name. Requires DB read access (`ssh scaleskus`) and
the `atil-services` Google helpers; competitor data needs the marketplace Top Search Terms
report (see `references/search_terms_brand.md`).

## Guards
Settled window (today−16d) · per-profile column resolution · master-table dedup · lifetime
history before any negation · read-only. No secrets or client data — the account is supplied
at run time.

# Build recipe — the Google Sheet

Assemble with `/usr/bin/python3` + the atil-services helpers
(`sys.path.insert(0, "~/.claude/skills/atil-services/scripts")`):
`from google_sheets import client, create, write, batch_update, tabs`,
`from google_drive import share`.

Create ONE workbook per run: **"<Account> — Amazon Growth Audit (Last 60 Days)"**.
Tab order: **README → Summary → one tab per subcategory** (subcategories ordered by
market cap, biggest first). Share `type="anyone", role="writer"`.

## Tab: README
Two columns (label | value). Sections (slate headers): Purpose · **Date range** (the
60d window + why it ends today−16d + which SQP months) · **Data sources** (name the
exact tables — see queries.sql) · **Metric logic** (paste the Step-3 formula table in
words) · **Subcategorization logic** (token-cluster method + what was excluded) ·
**Caveats** (catalog blind spot if empty; search-attributed ≠ total sales; branded is
tiny; rounding) · Prepared-by line.

## Tab: Summary
- Title (navy) + one-line method subtitle.
- **ACCOUNT (60d):** total sales, sessions, business CVR; ad spend, ad sales, ACoS, TACOS; search-captured revenue vs market cap and overall purchase share.
- **SUBCATEGORY SCORECARD** (slate header) — one row per subcategory, columns:
  `Subcategory | Market Cap ₹ | Our Rev ₹ | Shr% | Spend ₹ | Ad Sales ₹ | ACoS% | CTR% | Ad CVR% | Gap ₹ (upside)`, then a bold **TOTAL** row.
- **THE STORY / WAY FORWARD** (gold header) — 4–6 numbered lines: the thesis
  (convert-but-invisible / retail-broke / etc.), the engine to defend, the biggest
  whitespace subcategories, the spend leaks, the competitor-targeting gap; then a
  green highlighted **capturable-upside** line = `gap × conservative target share`.

## Tab: each subcategory (self-contained)
Rows 1–5 are the summary block, row 7 the header, row 8+ the detail. Freeze 7 rows.

- **Row 1** title (navy): `"<Subcategory> — 60-day audit"`.
- **Row 2** (slate): `MARKET CAP ₹… · Search volume … · Market CVR …%  |  OUR REVENUE ₹… (…% purchase share, our CVR …%)`.
- **Row 3** (slate): `WE INVEST: spend ₹… → ad sales ₹… (ACoS …%, CTR …%, Ad CVR …%)  |  SOURCE: …% paid / …% organic  |  GAP: ₹… at <5% share`.
- **Row 4** (slate): `TARGETING: N keyword-targeted · M auto/broad-only · K not-served · competitor-targeting on C terms`.
- **Row 5** (gold, wrapped): `WHAT TO DO: (1)… (2)… (3)…` — derived from this subcategory's pattern (gaps→structure keywords; priced-out→value SKU; zero comp-targeting→add rivals; high share→push impression share; high ACoS→tighten).
- **Row 7 header + Row 8+ detail**, one row per keyword (top ~30 by market orders):

`Keyword | Mkt Orders | Mkt Cap ₹ | Mkt Price | Our Price | Our Orders | Our Rev ₹ | Purch Shr% | Impr Shr% | Ad Impr | Ad Clicks | CTR% | Ad Spend ₹ | Ad Orders | Ad CVR% | ACoS% | Targeting | Top-3 Competitors (brand·click%) | Comp Targeted? | Suggestion`

### Per-row suggestion logic (first match)
- Not served & mkt orders ≥150 → `GAP → add exact keyword + campaign`
- Auto/Broad only & mkt orders ≥150 → `HARVEST search term → exact keyword`
- our price ≥ 1.4× market price & mkt orders ≥100 → `PRICE {n}% over mkt → value SKU/reposition`
- has top-3 competitor & we target none & mkt orders ≥100 → `Add competitor ASIN targeting`
- purchase share ≥15% → `DEFEND — raise impression share`
- ACoS ≥45% & spend >small → `Rebid — ACoS {n}%`
- keyword-targeted → `Maintain / optimise bid` ; else `Monitor`

## Formatting palette
Navy `#0B1729` title text white bold; slate `#33424D` section headers white; gold
`#CC9E1C` "what to do"; light `#F0F2F7` totals; green `#D9F0D4` the upside line.
Number formats: `₹#,##0` for money, `0.0`/`0` for percents (values stored as 10.4 not
0.104), `#,##0` for counts. Merge title/summary rows across all columns; widen the
keyword col (~230px), competitors (~220px), suggestion (~260px). Batch `repeatCell` /
`mergeCells` requests ≤45 per `batch_update` call. `unmergeCells` the sheet before
re-merging on a rebuild.

## Assembly order
1. Assign subcategory to every SQP query and ad term (account rules from Step 2).
2. Aggregate SQP → market/our/share/gap; aggregate ad → spend/return/CTR/CVR/ACoS.
3. Join keyword targeting (`kw_enabled`), competitors (`competitors`), our target
   ASIN set (`our_targets`) onto the per-keyword rows.
4. Compute source split (paid = ad sales; organic = our rev − paid).
5. Write README + Summary + subcategory tabs; format; share; hand back the URL.

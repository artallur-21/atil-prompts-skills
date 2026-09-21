-- Subcategory Market-Gap Audit — parameterized query templates.
-- Replace placeholders before running (read-only SELECTs on amazon_ads):
--   {{PROFILE}} profile_id           {{MP}} marketplace_id
--   {{FROM}} window start (today-76d) {{TO}} window end (today-16d, settled)
--   {{M1}} {{M2}} the two SQP month starts inside the window (YYYY-MM-01)
-- SELLER cols = sales_7d / purchases_7d ; VENDOR = sales_14d / purchases_14d.
-- Resolve per profile (orient.sh / BlendedDataService::resolveAdColumns) and substitute {{S}}/{{P}}.

-- ============ acct_kpis : account KPIs over the settled 60d ============
SELECT ROUND(SUM(ordered_product_sales)) total_sales, SUM(units_ordered) units,
       SUM(sessions) sessions, ROUND(100*SUM(units_ordered)/NULLIF(SUM(sessions),0),2) business_cvr
FROM sp_api_daily_summary
WHERE profile_id='{{PROFILE}}' AND date BETWEEN '{{FROM}}' AND '{{TO}}';

-- ============ acct_ad : account ad spend/sales (all products) 60d ============
SELECT 'SP' ap, ROUND(SUM(COALESCE(spend,cost))) spend, ROUND(SUM({{S}})) sales FROM reports_sp_campaigns_daily WHERE profile_id='{{PROFILE}}' AND date BETWEEN '{{FROM}}' AND '{{TO}}'
UNION ALL SELECT 'SB', ROUND(SUM(cost)), ROUND(SUM(sales)) FROM reports_sb_campaigns_daily WHERE profile_id='{{PROFILE}}' AND date BETWEEN '{{FROM}}' AND '{{TO}}'
UNION ALL SELECT 'SD', ROUND(SUM(cost)), ROUND(SUM(sales)) FROM reports_sd_campaigns_daily WHERE profile_id='{{PROFILE}}' AND date BETWEEN '{{FROM}}' AND '{{TO}}';

-- ============ sqp_60d : market + our funnel per query (2 SQP months) ============
-- market_* = MAX per (query,month) then summed; our_* = SUM of our ASINs.
SELECT search_query, SUM(mkti) mkt_impr, SUM(mktc) mkt_clk, SUM(mkto) mkt_ord, SUM(vol) search_vol,
       SUM(ouri) our_impr, SUM(ourc) our_clk, SUM(ouro) our_ord,
       ROUND(AVG(mktprice)) mkt_price, ROUND(AVG(ourprice)) our_price
FROM (
  SELECT search_query, date_from,
    MAX(query_impressions) mkti, MAX(query_clicks) mktc, MAX(query_purchases) mkto, MAX(search_query_volume) vol,
    SUM(asin_impressions) ouri, SUM(asin_clicks) ourc, SUM(asin_purchases) ouro,
    AVG(NULLIF(total_median_purchase_price,0)) mktprice, AVG(NULLIF(asin_median_purchase_price,0)) ourprice
  FROM sp_api_sqp_monthly
  WHERE profile_id='{{PROFILE}}' AND date_from IN ('{{M1}}','{{M2}}')
  GROUP BY search_query, date_from
) m GROUP BY search_query HAVING SUM(mkto) >= 5;

-- ============ ad_60d : our SP+SB spend/return per search term ============
SELECT search_term, SUM(impr), SUM(clk), ROUND(SUM(spend)), SUM(orders), ROUND(SUM(sales)) FROM (
  SELECT search_term, impressions impr, clicks clk, COALESCE(spend,cost) spend, {{P}} orders, {{S}} sales
    FROM reports_sp_searchterms_daily WHERE profile_id='{{PROFILE}}' AND date BETWEEN '{{FROM}}' AND '{{TO}}'
  UNION ALL
  SELECT search_term, impressions, clicks, cost, purchases, sales
    FROM reports_sb_searchterms_daily WHERE profile_id='{{PROFILE}}' AND date BETWEEN '{{FROM}}' AND '{{TO}}'
) x GROUP BY search_term;

-- ============ kw_enabled : deliberate keyword targets (dedup freshest) ============
SELECT keyword_text, GROUP_CONCAT(DISTINCT match_type) match_types
FROM master_sp_keywords WHERE profile_id='{{PROFILE}}' AND state='ENABLED' GROUP BY keyword_text;
-- (add master_sb_keywords with a UNION for full SEM coverage)

-- ============ our_targets : our ENABLED product-target ASINs ============
SELECT DISTINCT resolved_target_text FROM master_sp_targets
WHERE profile_id='{{PROFILE}}' AND state='ENABLED'
  AND (resolved_target_text LIKE '%asin%' OR resolved_target_text LIKE '%ASIN%');
-- In code, extract every /B0[A-Z0-9]{8}/ into a set = the ASINs we conquest-target.

-- ============ competitors : marketplace top-3 clicked ASINs per term ============
-- Requires sp_api_search_terms_brand populated for {{MP}} (see search_terms_brand.md).
-- Build an IN-list of your audited terms (escape ' as '') to bound the scan.
SELECT search_term, clicked_asin_rank, clicked_asin,
       REPLACE(LEFT(clicked_item_name,42),'\t',' ') item, click_share
FROM sp_api_search_terms_brand
WHERE marketplace_id='{{MP}}' AND report_period='MONTH' AND date_from='{{M2}}'
  AND search_term IN ( {{TERM_IN_LIST}} )
ORDER BY search_term, clicked_asin_rank;

-- ============ spend_vs_sqp : where ad spend goes, In-SQP vs Not-in-SQP ============
SELECT CASE WHEN in_sqp=1 THEN 'IN SQP' ELSE 'NOT in SQP' END bucket,
       COUNT(*) terms, ROUND(SUM(spend)) spend, ROUND(SUM(sales)) sales, SUM(orders) orders
FROM (
  SELECT st.search_term, SUM(COALESCE(st.spend,st.cost)) spend, SUM(st.{{S}}) sales, SUM(st.{{P}}) orders,
         MAX(sq.search_query IS NOT NULL) in_sqp
  FROM reports_sp_searchterms_daily st
  LEFT JOIN (SELECT DISTINCT search_query FROM sp_api_sqp_monthly WHERE profile_id='{{PROFILE}}'
             UNION SELECT DISTINCT search_query FROM sp_api_sqp_weekly WHERE profile_id='{{PROFILE}}') sq
    ON sq.search_query = st.search_term
  WHERE st.profile_id='{{PROFILE}}' AND st.date BETWEEN '{{FROM}}' AND '{{TO}}'
  GROUP BY st.search_term
) t GROUP BY in_sqp;
-- Sub-split NOT-in-SQP: search_term REGEXP '^b0' = ASIN/product-target (intentional);
-- LIKE '%<brand>%' = branded; else long-tail off-radar (the leak).

-- ============ decline_check : did retail break? (optional retail dig) ============
-- Per top ASIN, month-over-month sales + Buy Box + unit_session_percentage (CVR).
SELECT asin,
  SUM(IF(date>='{{M1}}' AND date<'{{M2}}',ordered_product_sales,0)) m1_sales,
  SUM(IF(date>='{{M2}}',ordered_product_sales,0)) m2_sales,
  ROUND(AVG(IF(date>='{{M2}}',buy_box_percentage,NULL)),0) bb_recent,
  ROUND(AVG(IF(date>='{{M2}}',unit_session_percentage,NULL)),1) cvr_recent
FROM sp_api_business_reports WHERE profile_id='{{PROFILE}}' AND date>='{{M1}}'
GROUP BY asin ORDER BY m2_sales DESC LIMIT 25;

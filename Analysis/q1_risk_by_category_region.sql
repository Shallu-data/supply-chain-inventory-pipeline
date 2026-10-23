SELECT
  category, region,
  COUNT(*) AS records,
  ROUND(AVG(is_high_risk) * 100, 2) AS pct_high_risk,
  ROUND(AVG(is_overstock) * 100, 2) AS pct_overstock,
  ROUND(APPROX_QUANTILES(stock_cover_ratio, 100)[OFFSET(50)], 2) AS median_cover,
  ROUND(SUM(revenue), 0) AS revenue
FROM `supply-chain-pipeline-55606.gold.vw_inventory_dashboard`
GROUP BY category, region
ORDER BY pct_high_risk DESC;

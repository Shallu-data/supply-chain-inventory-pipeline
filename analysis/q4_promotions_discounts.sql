SELECT
  holiday_promotion,
  discount,
  COUNT(*) AS records,
  ROUND(AVG(units_sold), 1) AS avg_units_sold,
  ROUND(AVG(revenue), 1) AS avg_revenue
FROM `supply-chain-pipeline-55606.gold.vw_inventory_dashboard`
GROUP BY holiday_promotion, discount
ORDER BY holiday_promotion, discount;

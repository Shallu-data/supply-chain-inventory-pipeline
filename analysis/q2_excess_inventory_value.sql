SELECT
  COUNT(DISTINCT date) AS days,
  MIN(date) AS first_date,
  MAX(date) AS last_date,
  ROUND(SUM(GREATEST(inventory_level - 2 * units_sold, 0) * price) / COUNT(DISTINCT date), 0) AS avg_daily_excess_value
FROM `supply-chain-pipeline-55606.gold.vw_inventory_dashboard`;

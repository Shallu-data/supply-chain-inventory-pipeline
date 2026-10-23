SELECT
  category,
  ROUND(SUM(forecast_error) / SUM(units_sold) * 100, 2) AS wape_pct,
  ROUND((SUM(demand_forecast) - SUM(units_sold)) / SUM(units_sold) * 100, 2) AS bias_pct
FROM `supply-chain-pipeline-55606.gold.vw_inventory_dashboard`
GROUP BY category
ORDER BY wape_pct DESC;

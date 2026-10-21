-- Gold summary table: daily rollup of inventory health by record and risk category.
CREATE OR REPLACE TABLE `your-project-id.retail_inventory.stock_summary` AS
SELECT
  inventory_date AS date_id,
  store,
  region,
  COUNT(*) AS total_records,
  AVG(inventory_level) AS avg_inventory_level,
  AVG(units_sold) AS avg_units_sold,
  AVG(CASE WHEN units_sold > 0 THEN inventory_level / units_sold ELSE NULL END) AS avg_stock_cover_ratio,
  AVG(ABS(demand_forecast - units_sold)) AS avg_forecast_error,
  SUM(CASE WHEN inventory_level > (units_sold * 2) THEN 1 ELSE 0 END) AS overstock_records,
  SUM(CASE WHEN stockout_risk = 'High' THEN 1 ELSE 0 END) AS high_risk_records,
  SUM(CASE WHEN stockout_risk = 'Medium' THEN 1 ELSE 0 END) AS medium_risk_records,
  SUM(CASE WHEN stockout_risk = 'Low' THEN 1 ELSE 0 END) AS low_risk_records,
  SUM(CASE WHEN stockout_risk = 'Unknown' THEN 1 ELSE 0 END) AS unknown_risk_records
FROM `your-project-id.retail_inventory.fact_inventory`
GROUP BY
  inventory_date,
  store,
  region
ORDER BY inventory_date, store;

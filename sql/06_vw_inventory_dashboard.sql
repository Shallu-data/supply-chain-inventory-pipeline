-- Dashboard view: expose the joined inventory fact and dimension attributes for Looker Studio.
CREATE OR REPLACE VIEW `your-project-id.retail_inventory.vw_inventory_dashboard` AS
SELECT
  f.date_id,
  d.date_id AS calendar_date,
  f.store_name,
  f.product_name,
  f.category,
  f.region,
  f.inventory_level,
  f.units_sold,
  f.units_ordered,
  f.demand_forecast,
  f.price,
  f.discount_pct,
  f.has_promotion,
  f.stock_cover_ratio,
  f.forecast_error,
  f.stockout_risk,
  f.stock_status,
  CASE
    WHEN f.inventory_level > f.units_sold * 2 THEN 'Overstock'
    ELSE 'Healthy'
  END AS stock_status_label
FROM `your-project-id.retail_inventory.fact_inventory` f
LEFT JOIN `your-project-id.retail_inventory.dim_date` d
  ON f.date_id = d.date_id
ORDER BY f.date_id, f.store_name, f.product_name;

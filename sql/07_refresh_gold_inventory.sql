-- Full refresh script for the gold layer and dashboard objects.
-- Run daily via BigQuery Scheduled Query.

CREATE OR REPLACE TABLE `your-project-id.retail_inventory.dim_store` AS
SELECT DISTINCT
  store AS store_name,
  region,
  CONCAT(store, ' - ', region) AS store_label
FROM `your-project-id.retail_inventory.inventory_silver`
ORDER BY store_name;

CREATE OR REPLACE TABLE `your-project-id.retail_inventory.dim_product` AS
SELECT DISTINCT
  product AS product_name,
  category,
  CONCAT(product, ' - ', category) AS product_label
FROM `your-project-id.retail_inventory.inventory_silver`
ORDER BY product_name;

CREATE OR REPLACE TABLE `your-project-id.retail_inventory.dim_date` AS
WITH dates AS (
  SELECT MIN(inventory_date) AS min_date, MAX(inventory_date) AS max_date
  FROM `your-project-id.retail_inventory.inventory_silver`
),
calendar AS (
  SELECT
    day AS calendar_date,
    EXTRACT(YEAR FROM day) AS year_num,
    EXTRACT(MONTH FROM day) AS month_num,
    EXTRACT(DAY FROM day) AS day_num,
    FORMAT_DATE('%A', day) AS day_name,
    FORMAT_DATE('%b', day) AS month_name
  FROM UNNEST(GENERATE_DATE_ARRAY((SELECT min_date FROM dates), (SELECT max_date FROM dates))) AS day
)
SELECT
  CAST(calendar_date AS DATE) AS date_id,
  year_num,
  month_num,
  day_num,
  day_name,
  month_name
FROM calendar
ORDER BY calendar_date;

CREATE OR REPLACE TABLE `your-project-id.retail_inventory.fact_inventory` AS
WITH ranked AS (
  SELECT
    s.inventory_date,
    s.store,
    s.product,
    s.category,
    s.region,
    s.inventory_level,
    s.units_sold,
    s.units_ordered,
    s.demand_forecast,
    s.price,
    s.discount_pct,
    s.has_promotion,
    CASE WHEN s.units_sold = 0 THEN NULL ELSE s.inventory_level / s.units_sold END AS stock_cover_ratio,
    CASE WHEN s.units_sold = 0 THEN NULL ELSE ABS(s.demand_forecast - s.units_sold) END AS forecast_error,
    PERCENT_RANK() OVER (
      ORDER BY CASE WHEN s.units_sold = 0 THEN NULL ELSE s.inventory_level / s.units_sold END
    ) AS stock_cover_pct_rank
  FROM `your-project-id.retail_inventory.inventory_silver` s
)
SELECT
  inventory_date AS date_id,
  store AS store_name,
  product AS product_name,
  category,
  region,
  inventory_level,
  units_sold,
  units_ordered,
  demand_forecast,
  price,
  discount_pct,
  has_promotion,
  stock_cover_ratio,
  forecast_error,
  CASE
    WHEN units_sold = 0 THEN 'Unknown'
    WHEN stock_cover_pct_rank <= 0.20 THEN 'High'
    WHEN stock_cover_pct_rank <= 0.50 THEN 'Medium'
    ELSE 'Low'
  END AS stockout_risk,
  CASE
    WHEN inventory_level > units_sold * 2 THEN 'Overstock'
    ELSE 'Healthy'
  END AS stock_status
FROM ranked;

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
GROUP BY inventory_date, store, region
ORDER BY inventory_date, store;

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

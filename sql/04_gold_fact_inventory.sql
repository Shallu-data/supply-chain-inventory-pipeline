-- Gold fact table: inventory observations with derived stock risk and status fields.
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
    CASE
      WHEN s.units_sold = 0 THEN NULL
      ELSE s.inventory_level / s.units_sold
    END AS stock_cover_ratio,
    CASE
      WHEN s.units_sold = 0 THEN NULL
      ELSE ABS(s.demand_forecast - s.units_sold)
    END AS forecast_error,
    PERCENT_RANK() OVER (ORDER BY CASE WHEN s.units_sold = 0 THEN NULL ELSE s.inventory_level / s.units_sold END) AS stock_cover_pct_rank
  FROM `your-project-id.retail_inventory.inventory_silver` s
),
final AS (
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
  FROM ranked
)
SELECT *
FROM final;

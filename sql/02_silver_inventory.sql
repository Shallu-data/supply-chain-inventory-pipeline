-- Silver layer: clean, type-cast, and deduplicate the raw bronze inventory rows.
CREATE OR REPLACE TABLE `your-project-id.retail_inventory.inventory_silver` AS
WITH cleaned AS (
  SELECT
    CAST(TRIM(date) AS DATE) AS inventory_date,
    TRIM(store) AS store,
    TRIM(product) AS product,
    TRIM(category) AS category,
    TRIM(region) AS region,
    SAFE_CAST(TRIM(REPLACE(inventory_level, ',', '')) AS NUMERIC) AS inventory_level,
    SAFE_CAST(TRIM(REPLACE(units_sold, ',', '')) AS NUMERIC) AS units_sold,
    SAFE_CAST(TRIM(REPLACE(units_ordered, ',', '')) AS NUMERIC) AS units_ordered,
    SAFE_CAST(TRIM(REPLACE(demand_forecast, ',', '')) AS NUMERIC) AS demand_forecast,
    SAFE_CAST(TRIM(REPLACE(price, '$', '')) AS NUMERIC) AS price,
    SAFE_CAST(TRIM(REPLACE(discount, '%', '')) AS NUMERIC) / 100.0 AS discount_pct,
    CASE
      WHEN LOWER(TRIM(promotions)) IN ('yes', 'true', '1', 'y') THEN TRUE
      WHEN LOWER(TRIM(promotions)) IN ('no', 'false', '0', 'n', '') THEN FALSE
      ELSE NULL
    END AS has_promotion
  FROM `your-project-id.retail_inventory.inventory_bronze`
  WHERE TRIM(store) != ''
    AND TRIM(product) != ''
    AND TRIM(category) != ''
    AND TRIM(region) != ''
),
ranked AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY inventory_date, store, product, category, region
      ORDER BY inventory_date DESC
    ) AS row_num
  FROM cleaned
)
SELECT
  inventory_date,
  store,
  product,
  category,
  region,
  inventory_level,
  units_sold,
  units_ordered,
  demand_forecast,
  price,
  discount_pct,
  has_promotion
FROM ranked
WHERE row_num = 1;

-- Optional validation query:
-- SELECT COUNT(*) AS row_count FROM `your-project-id.retail_inventory.inventory_silver`;

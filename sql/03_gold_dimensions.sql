-- Gold dimensions: store, product, and date dimensions built from the silver layer.

CREATE OR REPLACE TABLE `your-project-id.retail_inventory.dim_store` AS
SELECT
  DISTINCT
  store AS store_name,
  region,
  CONCAT(store, ' - ', region) AS store_label
FROM `your-project-id.retail_inventory.inventory_silver`
ORDER BY store_name;

CREATE OR REPLACE TABLE `your-project-id.retail_inventory.dim_product` AS
SELECT
  DISTINCT
  product,
  category,
  CONCAT(product, ' - ', category) AS product_label
FROM `your-project-id.retail_inventory.inventory_silver`
ORDER BY product;

CREATE OR REPLACE TABLE `your-project-id.retail_inventory.dim_date` AS
WITH dates AS (
  SELECT
    MIN(inventory_date) AS min_date,
    MAX(inventory_date) AS max_date
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

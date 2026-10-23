SELECT
  category,
  ROUND(SUM(GREATEST(inventory_level - 2 * units_sold, 0) * price), 0) AS excess_inventory_value,
  ROUND(SUM(revenue), 0) AS revenue,
  ROUND(SUM(GREATEST(inventory_level - 2 * units_sold, 0) * price) / SUM(revenue) * 100, 2) AS excess_pct_of_revenue
FROM `supply-chain-pipeline-55606.gold.vw_inventory_dashboard`
GROUP BY category
ORDER BY excess_inventory_value DESC;

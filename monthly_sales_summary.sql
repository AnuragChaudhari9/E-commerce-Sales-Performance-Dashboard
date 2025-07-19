SELECT
  table_id
FROM
  `bigquery-public-data.thelook_ecommerce.__TABLES_SUMMARY__`;

SELECT
  column_name,
  data_type
FROM
  `bigquery-public-data.thelook_ecommerce.INFORMATION_SCHEMA.COLUMNS`
WHERE
  table_name = 'order_items'; 

SELECT 
  o.order_id,
  o.created_at AS order_date,
  oi.product_id,
  p.name AS product_name,
  p.category,
  oi.sale_price,
  p.cost,
  (oi.sale_price - p.cost) AS profit
FROM 
  `bigquery-public-data.thelook_ecommerce.orders` AS o
JOIN 
  `bigquery-public-data.thelook_ecommerce.order_items` AS oi
ON 
  o.order_id = oi.order_id
JOIN 
  `bigquery-public-data.thelook_ecommerce.products` AS p
ON 
  oi.product_id = p.id
WHERE 
  o.status = 'Complete';

CREATE OR REPLACE VIEW `sales-insights-project-466412.sales_analysis.monthly_sales_summary` AS
SELECT
  DATE_TRUNC(DATE(o.created_at), MONTH) AS order_month,
  COUNT(DISTINCT o.order_id) AS total_orders,
  SUM(oi.sale_price) AS total_sales,
  SUM(oi.sale_price - p.cost) AS total_profit
FROM
  `bigquery-public-data.thelook_ecommerce.orders` AS o
JOIN
  `bigquery-public-data.thelook_ecommerce.order_items` AS oi
ON
  o.order_id = oi.order_id
JOIN
  `bigquery-public-data.thelook_ecommerce.products` AS p
ON
  oi.product_id = p.id
WHERE
  o.status = 'Complete'
  AND o.user_id IS NOT NULL
  AND o.created_at IS NOT NULL
  AND oi.product_id IS NOT NULL
  AND oi.sale_price IS NOT NULL
  AND p.cost IS NOT NULL
  AND p.category IS NOT NULL
GROUP BY order_month
ORDER BY order_month;
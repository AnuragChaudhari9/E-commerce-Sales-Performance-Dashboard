# E-commerce Sales Performance Analysis using BigQuery and Looker Studio

## Overview

This project analyzes historical e-commerce data to generate insights into monthly trends in orders, revenue, and profitability. Using SQL on Google BigQuery and visualizing with Looker Studio, the goal is to simulate a real-world business intelligence workflow.

## Dataset

**Source**: `bigquery-public-data.thelook_ecommerce`

Tables used:
- `orders`: Order metadata and status
- `order_items`: Line-item sale details
- `products`: Product information including category and cost

## Objectives

- Join transactional tables to form a unified sales dataset
- Clean data by filtering nulls and invalid entries
- Calculate key performance indicators (KPIs):
  - Total Orders
  - Total Sales
  - Total Profit
- Group metrics by month for trend analysis
- Build an interactive dashboard using Looker Studio

## Tools & Technologies

| Tool               | Purpose                               |
|--------------------|---------------------------------------|
| Google BigQuery    | Cloud-based data warehouse (SQL)      |
| Looker Studio      | Data visualization & dashboarding     |
| Google Cloud Platform | Infrastructure hosting and analytics |

## Project Steps

### 1. Schema Exploration

```sql
SELECT table_id
FROM `bigquery-public-data.thelook_ecommerce.__TABLES_SUMMARY__`;

SELECT column_name, data_type
FROM `bigquery-public-data.thelook_ecommerce.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'order_items';
```

### 2. Transaction Join & Profit Calculation
```
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
  ON o.order_id = oi.order_id
JOIN 
  `bigquery-public-data.thelook_ecommerce.products` AS p
  ON oi.product_id = p.id
WHERE 
  o.status = 'Complete';
```

### 3. Aggregating Monthly KPIs
```
SELECT
  DATE_TRUNC(DATE(o.created_at), MONTH) AS order_month,
  COUNT(DISTINCT o.order_id) AS total_orders,
  SUM(oi.sale_price) AS total_sales,
  SUM(oi.sale_price - p.cost) AS total_profit
FROM 
  `bigquery-public-data.thelook_ecommerce.orders` AS o
JOIN 
  `bigquery-public-data.thelook_ecommerce.order_items` AS oi
  ON o.order_id = oi.order_id
JOIN 
  `bigquery-public-data.thelook_ecommerce.products` AS p
  ON oi.product_id = p.id
WHERE 
  o.status = 'Complete'
  AND o.user_id IS NOT NULL
  AND o.created_at IS NOT NULL
  AND oi.product_id IS NOT NULL
  AND oi.sale_price IS NOT NULL
  AND p.cost IS NOT NULL
  AND p.category IS NOT NULL
GROUP BY 
  order_month
ORDER BY 
  order_month;
```

### 4. Creating View in BigQuery
```
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
  ON o.order_id = oi.order_id
JOIN
  `bigquery-public-data.thelook_ecommerce.products` AS p
  ON oi.product_id = p.id
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
```

## Dashboard in Looker Studio
- Connected BigQuery view directly to Looker Studio
- Used order_month as Date dimension
- Visual elements:
  - Scorecards: Total Orders, Sales, Profit
  - Time-series line charts
  - Optional filters for category, date range
 
## Outcome
- Built an interactive BI dashboard simulating a real business use case
- Demonstrated data cleaning, transformation, and cloud SQL skills
- Gained experience in using GCP tools in a free-tier setup
  

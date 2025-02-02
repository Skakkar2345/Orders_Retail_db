create table df_orders(
[order_id] int primary key
,[order_date] date
,[ship_mode] varchar(20)
,[segment] varchar(20)
,[country] varchar(20)
,[city] varchar(20)
,[state] varchar(20)
,[postal_code] varchar(20)
,[region] varchar(20)
,[category] varchar(20)
,[sub_category] varchar(20)
,[product_id] varchar(50)
,[quantity] int
,[discount] decimal(7,2)
,[sale_price] decimal(7,2)
,[profit] decimal(7,2))


SELECT * FROM df_orders


TRUNCATE TABLE df_orders

ALTER TABLE df_orders
ALTER COLUMN final_sale_price decimal(18,4)

SELECT TOP 10 product_id,SUM(final_sale_price) AS Total_sales
FROM df_orders
GROUP BY product_id
ORDER BY Total_sales DESC

WITH CTE AS (SELECT region,product_id, SUM(final_sale_price) AS Total_Sales,RANK() OVER(PARTITION BY region ORDER BY SUM(final_sale_price) DESC) AS Ranks
FROM df_orders
GROUP BY region,product_id)

SELECT *
FROM CTE
WHERE Ranks BETWEEN 1 and 5

-- find month over month growth comparisons for 2022 and 2023 sales eg: jan 2022 vs jan 2023
WITH sales_overall AS(select year(order_date) as yr , month(order_date) as mth, SUM(final_sale_price) AS sales
FROM df_orders
GROUP BY year(order_date),month(order_date)
) 

SELECT mth
,SUM(CASE WHEN yr = 2022 THEN sales ELSE 0 end) AS sales_2022 , 
SUM(CASE WHEN yr = 2023 THEN sales ELSE 0 end ) AS sales_2023
FROM sales_overall
GROUP BY mth
ORDER BY mth

-- for each category which month had highest sales
WITH CTES AS(SELECT category, format(order_date,'yyyyMM')as year_mth, SUM(final_sale_price) as sales,
RANK() OVER(PARTITION BY category ORDER BY SUM(final_sale_price) DESC) AS Rnk
FROM df_orders
GROUP BY category,format(order_date,'yyyyMM')
)


SELECT category,year_mth,Rnk,sales
FROM CTES
WHERE Rnk = 1
ORDER BY category,year_mth

-- which sub category had highest growth by profit in 2023 vs 2022
WITH sales_overall AS(select year(order_date) as yr , SUM(final_sale_price) AS sales, sub_category
FROM df_orders
GROUP BY year(order_date),month(order_date),sub_category
) 
, cte2 as(
SELECT sub_category
,SUM(CASE WHEN yr = 2022 THEN sales ELSE 0 end) AS sales_2022 , 
SUM(CASE WHEN yr = 2023 THEN sales ELSE 0 end ) AS sales_2023
FROM sales_overall
GROUP BY sub_category)

SELECT top 1*,(sales_2023-sales_2022)*100/sales_2022 As growth_pct
FROM cte2
ORDER BY growth_pct DESC























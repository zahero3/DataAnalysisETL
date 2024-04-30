--DROP TABLE df_orders;

--SELECT * FROM df_orders;

CREATE TABLE df_orders(
	[order_id] INT PRIMARY KEY,
	[order_date] date,
	[ship_mode] varchar(20),
	[segment] varchar(20),
	[country] varchar(20),
	[city] varchar(20),
	[state] varchar(20),
	[postal_code] varchar(20),
	[region] varchar(20),
	[category] varchar(20),
	[sub_category] varchar(20),
	[product_id] varchar(50),
	[quantity] int,
	[discount] decimal(7,2),
	[sale_price] decimal(7,2),
	[profit] decimal(7,2));

--Q1. Find Top 10 highest revenue generating products
SELECT top 10 product_id, SUM(sale_price) AS sales
FROM   df_orders
GROUP BY product_id ORDER BY sales DESC;

--Q2. Top 5 highest selling produt in each region
SELECT distinct region FROM   df_orders;

with cte as (
SELECT region,product_id, SUM(sale_price) AS sales
FROM   df_orders GROUP BY region,product_id)

select * from (
select *,ROW_NUMBER() over(partition by region order by sales desc) as rn
from cte) as X
where rn <= 5;


--Q3. Find month over month growth comparison for 2022 & 2023 sales. eg. jan 2022 vs jan 2023
select distinct year(order_date) from df_orders;

with cte as (
select YEAR(order_date)as Oyear,MONTH(order_date) as Omonth,sum(sale_price) as sales
from df_orders
group by YEAR(order_date),MONTH(order_date) --order by YEAR(order_date),MONTH(order_date)
)

select Omonth,
sum(case when Oyear = 2022 then sales else 0 end) as sales_2022,
sum(case when Oyear = 2023 then sales else 0 end) as sales_2023
from cte 
group by Omonth;


--Q4. For each category which month has highest sales.
select distinct category from df_orders;

with cte as (
select category,MONTH(order_date) as om,sum(sale_price) as sales
from df_orders
group by category,MONTH(order_date)
--order by category,MONTH(order_date)
)

select * from 
(select category,om,sales,RANK() over(partition by category order by sales desc) as rk
from cte) as X
where rk = 1;

---------------including year
with cte as (
select category,FORMAT(order_date,'yyyy-MM') as om,sum(sale_price) as sales
from df_orders
group by category,FORMAT(order_date,'yyyy-MM')
--order by category,MONTH(order_date)
)

select * from 
(select category,om,sales,RANK() over(partition by category order by sales desc) as rk
from cte) as X
where rk = 1;

--Q5.Which sub category had highest growth by profit in 2023  compare to 2022?

select distinct sub_category from df_orders;

with cte1 as(
select sub_category,year(order_date) as oy,sum(sale_price) as sales
from df_orders
group by sub_category,year(order_date)
)
, cte2 as
(select sub_category,
sum(case when oy = 2022 then sales else 0 end) as sale_2022,
sum(case when oy = 2023 then sales else 0 end) as sale_2023
from cte1
group by sub_category)

select top 1 *,(sale_2023-sale_2022)*100/sale_2022 as growth
from cte2
order by growth desc;

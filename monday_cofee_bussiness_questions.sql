---coffee_sales_analysis of 3 branches 
--- eda
select * from city
select * from customers
select * from products
select  * from sales 

-- Reports & Data Analysis


-- Q.1 Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does? 

select * from city 

select 
     city_name,
    (population * 0.25)/100000,2) as coffe_million_analysis
     city_rank 
from city
order by 2 desc

-- -- Q.2
-- Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

select * from sales 

select 
    sum(total) as total_revenue
from sales
where extract(year from sale_date) = 2023 
and 
extract(quarter from sale_date) = 4 

--2 approach
select
	 c1.city_name,
	 sum(s.total) as revenue
from sales as s
join
customers as c
on s.customer_id = c.customer_id
join
city as c1 
on c.city_id = c1.city_id
where extract (year from sale_date) = 2023
and 
extract (quarter from sale_date) = 4 
group by 1 

-- Q.3
-- Sales Count for Each Product
-- How many units of each coffee product have been sold? 
select * from products 
select * from sales
select 
	p.product_name,
	count(s.sale_id) as total
from products as p
join
sales as s
on s.product_id = p.product_id 
group by 1 

-- Q.4
-- Average Sales Amount per City
-- What is the average sales amount per customer in each city? 


select 
	avg(s.total) as avg_sales, 
	c1.city_name,
	c.customer_name
from sales as s
join
customers as c
on s.customer_id = c.customer_id
join
city as c1
on c.city_id = c1.city_id 
group by 2,3 
order by 1 desc 

-- -- Q6
-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume? 
select
*
from
(
select
	c4.city_name,
	p.product_name,
	count(s.sale_id) as total_sales,
	dense_rank()over(partition by c4.city_name order by count(s.sale_id) desc) drn
from sales as s
join
products as p
on s.product_id = p.product_id
join
customers as c
on c.customer_id = s.customer_id
join
city as c4
on c.city_id = c4.city_id
group by 1,2
) as t1
where drn <= 3


-- Q.7
-- Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?
select
distinct(count(c.customer_id)) as unique_customer, 
	c1.city_name
from customers as c
join
city as c1
on c.city_id = c1.city_id 
join
sales as s
on c.customer_id = s.customer_id
where s.product_id in(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)
group by 2 


-- Q.9
-- Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly)
-- by each city 
WITH
monthly_sales
AS
(
	SELECT 
		ci.city_name,
		EXTRACT(MONTH FROM sale_date) as month,
		EXTRACT(YEAR FROM sale_date) as YEAR,
		SUM(s.total) as total_sale
	FROM sales as s
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1, 2, 3
	ORDER BY 1, 3, 2
),
growth_ratio
AS
(
		SELECT
			city_name,
			month,
			year,
			total_sale as cr_month_sale,
			LAG(total_sale, 1) OVER(PARTITION BY city_name ORDER BY year, month) as last_month_sale
		FROM monthly_sales
)

SELECT
	city_name,
	month,
	year,
	cr_month_sale,
	last_month_sale,
	ROUND(
		(cr_month_sale-last_month_sale)::numeric/last_month_sale::numeric * 100
		, 2
		) as growth_ratio

FROM growth_ratio
WHERE 
	last_month_sale IS NOT NULL	



-- Q.10
-- Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer



WITH city_table
AS
(
	SELECT 
		ci.city_name,
		SUM(s.total) as total_revenue,
		COUNT(DISTINCT s.customer_id) as total_cx,
		ROUND(
				SUM(s.total)::numeric/
					COUNT(DISTINCT s.customer_id)::numeric
				,2) as avg_sale_pr_cx
		
	FROM sales as s
	JOIN customers as c
	ON s.customer_id = c.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1
	ORDER BY 2 DESC
),
city_rent
AS
(
	SELECT 
		city_name, 
		estimated_rent,
		ROUND((population * 0.25)/1000000, 3) as estimated_coffee_consumer_in_millions
	FROM city
)
SELECT 
	cr.city_name,
	total_revenue,
	cr.estimated_rent as total_rent,
	ct.total_cx,
	estimated_coffee_consumer_in_millions,
	ct.avg_sale_pr_cx,
	ROUND(
		cr.estimated_rent::numeric/
									ct.total_cx::numeric
		, 2) as avg_rent_per_cx
FROM city_rent as cr
JOIN city_table as ct
ON cr.city_name = ct.city_name
ORDER BY 2 DESC

/*
-- Recomendation
City 1: Pune
	1.Average rent per customer is very low.
	2.Highest total revenue.
	3.Average sales per customer is also high.

City 2: Delhi
	1.Highest estimated coffee consumers at 7.7 million.
	2.Highest total number of customers, which is 68.
	3.Average rent per customer is 330 (still under 500).

City 3: Jaipur
	1.Highest number of customers, which is 69.
	2.Average rent per customer is very low at 156.
	3.Average sales per customer is better at 11.6k.
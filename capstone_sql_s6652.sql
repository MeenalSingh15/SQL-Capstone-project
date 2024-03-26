# creating database 
create database amazon;
use amazon;
create table amazon_sale( invoice_id VARCHAR(30) primary key NOT NULL,
branch VARCHAR(5) NOT NULL,
city varchar(30) NOT NULL,
customer_type VARCHAR(30) NOT NULL,
gender VARCHAR(10) NOT NULL,
product_line VARCHAR(100) NOT NULL,
unit_price DECIMAL(20, 10) NOT NULL,
quantity INT NOT NULL,
VAT FLOAT(6, 4) NOT NULL,
total DECIMAL(20, 10) NOT NULL,
date DATE NOT NULL,
time TIME NOT NULL,
payment_method varchar(50) NOT NULL,
cogs DECIMAL(20,10 ) NOT NULL,
gross_margin_percentage FLOAT(20, 10) NOT NULL,
gross_income DECIMAL(20, 10) NOT NULL,
rating FLOAT(2, 1) NOT NULL);
# loading data from csv file into our database
# used importing data wizard of mysql
# ## BUSINESS Questions
use amazon;

-- 1.What is the count of distinct cities in the dataset?
select count(distinct city) as distinct_city_count from amazon_sale ;
select distinct city as distinct_city_count from amazon_sale ;

-- 2.For each branch, what is the corresponding city? 
select distinct branch ,city from amazon_sale;

--  3.What is the count of distinct product lines in the dataset?
select count(distinct product_line) as product_line_distinct from amazon_sale;

-- 4.Which payment method occurs most frequently? 
select count(payment_method),payment_method from amazon_sale 
group by payment_method 
order by payment_method desc limit 1 ;

-- 5.Which product line has the highest sales? 
SELECT product_line, SUM(quantity) AS total_products_sold
FROM amazon_sale
GROUP BY product_line
ORDER BY total_products_sold DESC 
limit 1
;
SELECT product_line, SUM(total) AS total_amount_received
FROM amazon_sale
GROUP BY product_line
ORDER BY total_amount_received DESC 
limit 1
;
-- 6.How much revenue is generated each month? 
/* Add a new column named monthname that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar).
 Help determine which month of the year has the most sales and profit.*/
 ALTER TABLE amazon_sale
ADD COLUMN monthname VARCHAR(3);

UPDATE amazon_sale
SET monthname = UPPER(LEFT(MONTHNAME(date), 3));
-- 6.How much revenue is generated each month? 
SELECT monthname,
       SUM(total) AS monthly_revenue
FROM amazon_sale
GROUP BY monthname
ORDER BY monthly_revenue desc;

-- 7.In which month did the cost of goods sold reach its peak?
select monthname,sum(cogs) as cogs_sum from amazon_sale
group by monthname
order by cogs_sum desc limit 1;
-- 8.Which product line generated the highest revenue? 
SELECT product_line, SUM(total) AS total_amount_received
FROM amazon_sale
GROUP BY product_line
ORDER BY total_amount_received DESC limit 1
;
SELECT product_line, SUM(gross_income) AS total_gross_income
FROM amazon_sale
GROUP BY product_line
ORDER BY total_gross_income DESC limit 1
;
-- 9.In which city was the highest revenue recorded? 
select city,sum(total) as total_amount from amazon_sale
group by city
order by total_amount desc limit 1;

-- 10.Which product line incurred the highest Value Added Tax?
select product_line, sum(vat) as total_VAT from amazon_sale
group by product_line
order by total_VAT desc limit 1;

-- 11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."

--  Calculate the average sales across all product lines
SELECT AVG(quantity) AS avg_quantity
INTO @avg_quantity
FROM amazon_sale;

-- Add a new column to the table
ALTER TABLE amazon_sale
ADD COLUMN sales_quality ENUM('Good', 'Bad');

--  Update the new column with values
UPDATE amazon_sale
SET sales_quality = CASE 
                        WHEN total > @avg_total THEN 'Good'
                        ELSE 'Bad'
                    END;

-- checking the new column just added
select total,sales_quality from amazon_sale;

-- 12.Identify the branch that exceeded the average number of products sold. 

SELECT branch, SUM(quantity) AS total_quantity_sold
FROM amazon_Sale
GROUP BY branch
HAVING total_quantity_sold > (
    SELECT AVG(average_quantity_sold) AS avg_quantity_sold
    FROM (
        SELECT branch, avg(quantity) AS average_quantity_sold
        FROM amazon_sale
        GROUP BY branch
    ) AS branch_quantity 
)  limit 1;

-- 13.Which product line is most frequently associated with each gender? 

SELECT gender, product_line, frequency_rank
FROM (
    SELECT gender, product_line,
           RANK() OVER(PARTITION BY gender ORDER BY product_line_count DESC) AS frequency_rank
    FROM (
        SELECT gender, product_line, COUNT(*) AS product_line_count
        FROM amazon_sale
        GROUP BY gender, product_line
    ) AS product_line_counts
) AS ranked_data
WHERE frequency_rank = 1;
# for all product lines gender frequency
select product_line, gender,count(*) as frequency from amazon_sale
group by gender, product_line
order by count(*) desc ;

-- 14.Calculate the average rating for each product line.

select avg(rating) ,product_line from amazon_sale
group by product_line;

-- 15.Count the sales occurrences for each time of day on every weekday.
-- Add a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening. 
ALTER TABLE amazon_Sale
ADD COLUMN timeofday VARCHAR(15);

UPDATE amazon_Sale
SET timeofday = CASE
    WHEN HOUR(time) < 12 THEN 'Morning'
    WHEN HOUR(time) >= 12 AND HOUR(time) < 18 THEN 'Afternoon'
    ELSE 'Evening'
END;
select time ,timeofday from amazon_sale;
#Count the sales occurrences for each time of day on every weekday.

select dayname(date) as weekday,timeofday,count(*) as sales from amazon_sale
group by weekday,timeofday
order by sales desc ;
 
 -- 16.Identify the customer type contributing the highest revenue.
 
 select customer_type , sum(total) as total_revenue 
 from amazon_sale 
 group by customer_type
 order by total_revenue desc limit 1;
 
 --  17.Determine the city with the highest VAT percentage.
 
 select sum(vat)/sum(total)*100 as vat_percent ,city from amazon_sale
 group  by city
 order by vat_percent desc limit 1;
 
 --  18.Identify the customer type with the highest VAT payments. 
 
 select customer_type, sum(vat) as highest_vat from amazon_sale
 group by customer_type
 order by highest_vat desc limit 1;
 
 -- 19.What is the count of distinct customer types in the dataset? 
 select  count(distinct customer_type) as distinct_type_customer from amazon_sale;

 -- 20.What is the count of distinct payment methods in the dataset?
 SELECT COUNT(DISTINCT payment_method) AS distinct_payment_methods
FROM amazon_sale;

-- 21.Which customer type occurs most frequently?
select customer_type, count(*) as customer_frequency from amazon_sale
 group  by customer_type
 order by customer_frequency desc limit 1;
 
 -- 22. Identify the customer type with the highest purchase frequency.
 
 select customer_type, count(invoice_id) as purchase_frequency from amazon_sale
 group  by customer_type
 order by purchase_frequency desc limit 1;

-- 23.Determine the predominant gender among customers. 
select gender , count(*) as total_frequency from amazon_sale
group by gender 
order by total_frequency desc limit 1;

-- 24.Examine the distribution of genders within each branch.
select branch , count(gender) as gender_distri,gender from amazon_sale
group by branch ,gender
order by gender_distri desc  ;
-- 25.Identify the time of day when customers provide the most ratings. 
SELECT timeofday, COUNT(*) AS rating_count
FROM amazon_sale
GROUP BY timeofday
ORDER BY rating_count DESC
LIMIT 1;
-- 26.Determine the time of day with the highest customer ratings for each branch.
SELECT timeofday, COUNT(rating) AS rating_count,branch
FROM amazon_sale
GROUP BY timeofday,branch
ORDER BY rating_count DESC;

-- 27.Identify the day of the week with the highest average ratings.
/*Add a new column named dayname that contains the extracted days of the week on which the given
 transaction took place (Mon, Tue, Wed, Thur, Fri). */
ALTER TABLE amazon_sale
ADD COLUMN dayname VARCHAR(3);

UPDATE amazon_sale
SET dayname = UPPER(LEFT(DAYNAME(date), 3));
#Identify the day of the week with the highest average ratings.
SELECT dayname, AVG(rating) AS avg_rating
FROM amazon_sale
GROUP BY dayname
ORDER BY avg_rating DESC
limit 1;



-- 28.Determine the day of the week with the highest average ratings for each branch.
SELECT branch, dayname, avg_rating
FROM (
    SELECT branch, dayname, AVG(rating) AS avg_rating,
           Rank()OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS ranks
    FROM amazon_sale
    WHERE rating IS NOT NULL
    GROUP BY branch, dayname
) AS ranked_data
WHERE ranks = 1;

-- Analysis
/*1. Product Analysis

Conduct analysis on the data to understand the different product lines, the products lines performing best and the product lines that need to be improved.*/
select distinct product_line,count(*) as frequency,gender from amazon_sale
group  by product_line,gender
order by count(*) desc;
-- tells us which gender uses which product line most
-- to know which product line is performing best
select product_line,sum(total) as total_sale_amount ,sum(quantity) as quantity_sold from amazon_sale
group by product_line 
order by total_sale_amount desc limit 1;
-- to know which product line is performing worst
select product_line,sum(total) as total_sale_amount,sum(quantity) as quantity_sold from amazon_sale
group by product_line 
order by total_sale_amount limit 1;
-- average sale per transaction
SELECT product_line, AVG(total) AS avg_sales_per_transaction
FROM amazon_sale
GROUP BY product_line
ORDER BY avg_sales_per_transaction DESC;
/* Sales Analysis

This analysis aims to answer the question of the sales trends of product. The result of this can help us measure 
the effectiveness of each sales strategy the business applies and what modifications are needed to gain more sales.*/
-- Product Sales Analysis:
SELECT product_line, SUM(quantity) AS total_quantity_sold
FROM amazon_sale
GROUP BY product_line
ORDER BY total_quantity_sold DESC;
-- Sales Trends Over Time:
SELECT date AS transaction_date, SUM(quantity) AS total_quantity_sold,product_line
FROM amazon_sale
GROUP BY transaction_date,product_line
order by total_quantity_sold desc ;
/*Customer Analysis

This analysis aims to uncover the different customer segments, purchase trends and the profitability of each customer segment.*/
-- Customer type making most transactions: 
SELECT customer_type, SUM(total) AS total_spent
FROM amazon_sale
GROUP BY customer_type
ORDER BY total_spent DESC;
-- customer giving the most profit

SELECT customer_type , SUM(gross_income) AS total_income
FROM amazon_sale
GROUP BY customer_type
ORDER BY total_income DESC
LIMIT 1;


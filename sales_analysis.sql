CREATE DATABASE IF NOT EXISTS amazon_sales;
USE amazon_sales;

CREATE TABLE amazon_transactions (
    invoice_id VARCHAR(30) NOT NULL,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    tax_5 DECIMAL(10, 2) NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    cogs DECIMAL(10, 2) NOT NULL,
    gross_margin_percentage FLOAT NOT NULL,
    gross_income DECIMAL(10, 2) NOT NULL,
    rating FLOAT NOT NULL
);

desc amazon_transactions;
SELECT * FROM amazon_sales.amazon_transactions;
SELECT * FROM amazon_transactions WHERE 
    invoice_id IS NULL OR
    branch IS NULL OR
    city IS NULL OR
    customer_type IS NULL OR
    gender IS NULL OR
    product_line IS NULL OR
    unit_price IS NULL OR
    quantity IS NULL OR
    tax_5 IS NULL OR
    total IS NULL OR
    date IS NULL OR
    time IS NULL OR
    payment_method IS NULL OR
    cogs IS NULL OR
    gross_margin_percentage IS NULL OR
    gross_income IS NULL OR
    rating IS NULL;
/* 
Added a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening. 
This will help me to answer the question on which part of the day most sales are made.
*/

ALTER TABLE amazon_transactions ADD timeofday VARCHAR(20);

UPDATE amazon_transactions
SET timeofday = 
    CASE 
        WHEN TIME(time) BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
        WHEN TIME(time) BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
        ELSE 'Evening'
    END;
   
   /* 
   Added a new column named dayname that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri).
   This will help me to answer the question on which week of the day each branch is busiest.
   */
   ALTER TABLE amazon_transactions ADD dayname VARCHAR(10);

UPDATE amazon_transactions
SET dayname = DAYNAME(date);

/*
Add a new column named monthname that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar).
 Help determine which month of the year has the most sales and profit.
*/
ALTER TABLE amazon_transactions ADD monthname VARCHAR(15);

UPDATE amazon_transactions
SET monthname = MONTHNAME(date);

-- Business Questions To Answer:

 -- 1.What is the count of distinct cities in the dataset?
 SELECT COUNT(DISTINCT city) AS distinct_cities
FROM amazon_transactions;

-- 2. For each branch, what is the corresponding city?
SELECT DISTINCT branch, city
FROM amazon_transactions;

-- 3.What is the count of distinct product lines in the dataset?
SELECT COUNT(DISTINCT product_line) AS distinct_product_lines
FROM amazon_transactions;

-- 4.Which payment method occurs most frequently?
SELECT payment_method, COUNT(*) AS count
FROM amazon_transactions
GROUP BY payment_method
ORDER BY count DESC
LIMIT 1;

-- 5.Which product line has the highest sales (quantity)?
SELECT product_line, SUM(quantity) AS total_quantity_sold
FROM amazon_transactions
GROUP BY product_line
ORDER BY total_quantity_sold DESC
LIMIT 1;

-- 6.How much revenue is generated each month?
SELECT monthname, SUM(total) AS monthly_revenue
FROM amazon_transactions
GROUP BY monthname
ORDER BY monthly_revenue DESC;

-- 7.In which month did the cost of goods sold reach its peak?
SELECT monthname, SUM(cogs) AS total_cogs
FROM amazon_transactions
GROUP BY monthname
ORDER BY total_cogs DESC
LIMIT 1;

-- 8.Which product line generated the highest revenue?
SELECT product_line, SUM(total) AS total_revenue
FROM amazon_transactions
GROUP BY product_line
ORDER BY total_revenue DESC
LIMIT 1;

-- 9.In which city was the highest revenue recorded?
SELECT city, SUM(total) AS total_revenue
FROM amazon_transactions
GROUP BY city
ORDER BY total_revenue DESC
LIMIT 1;

-- 10.Which product line incurred the highest Value Added Tax?
SELECT product_line, SUM(tax_5) AS total_vat
FROM amazon_transactions
GROUP BY product_line
ORDER BY total_vat DESC
LIMIT 1;

-- 11.For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
-- (CTE - Common Table Expression)
WITH product_sales AS (
    SELECT product_line, SUM(total) AS total_sales
    FROM amazon_transactions
    GROUP BY product_line
),
average_sales AS (
    SELECT AVG(total_sales) AS avg_sales
    FROM product_sales
)
SELECT 
    ps.product_line,
    ps.total_sales,
    CASE 
        WHEN ps.total_sales > a.avg_sales THEN 'Good'
        ELSE 'Bad'
    END AS performance
FROM product_sales ps, average_sales a;

-- 12. Identify the branch that exceeded the average number of products sold.
-- (CTE - Common Table Expression)
WITH branch_sales AS (
    SELECT branch, SUM(quantity) AS total_quantity
    FROM amazon_transactions
    GROUP BY branch
),
average_quantity AS (
    SELECT AVG(total_quantity) AS avg_quantity
    FROM branch_sales
)
SELECT branch, total_quantity
FROM branch_sales, average_quantity
WHERE total_quantity > avg_quantity;

-- 13.Which product line is most frequently associated with each gender?
SELECT gender, product_line, COUNT(*) AS count
FROM amazon_transactions
GROUP BY gender, product_line
ORDER BY gender, count DESC;

-- 14.Calculate the average rating for each product line.
SELECT product_line, ROUND(AVG(rating), 2) AS avg_rating
FROM amazon_transactions
GROUP BY product_line
ORDER BY avg_rating DESC;

-- 15 Count the sales occurrences for each time of day on every weekday.
SELECT dayname, timeofday, COUNT(*) AS sales_count
FROM amazon_transactions
GROUP BY dayname, timeofday
ORDER BY dayname, timeofday;

-- 16.Identify the customer type contributing the highest revenue.
SELECT customer_type, SUM(total) AS total_revenue
FROM amazon_transactions
GROUP BY customer_type
ORDER BY total_revenue DESC
LIMIT 1;

-- 17.Determine the city with the highest VAT percentage
SELECT city, AVG((tax_5 / total) * 100) AS avg_vat_percentage
FROM amazon_transactions
GROUP BY city
ORDER BY avg_vat_percentage DESC
LIMIT 1;

-- 18.Identify the customer type with the highest VAT payments.
SELECT customer_type, SUM(tax_5) AS total_vat
FROM amazon_transactions
GROUP BY customer_type
ORDER BY total_vat DESC
LIMIT 1;

-- 19.What is the count of distinct customer types in the dataset?
SELECT COUNT(DISTINCT customer_type) AS distinct_customer_types
FROM amazon_transactions;

-- 20.What is the count of distinct payment methods in the dataset?
SELECT COUNT(DISTINCT payment_method) AS distinct_payment_methods
FROM amazon_transactions;

            -- END OF THE PROJECT --






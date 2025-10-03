
--50000 records on sales table
-- 500 records on marketing table

--Starting checking common issues in our database

-- Checking how many inconherent dates we have

SELECT COUNT(*) as inconherent_dates
From sales
WHERE delivery_date < order_date;

-- We have 3373 cases where the deliver_date < order date. It's a problem because it doesn't make sense that deliver_date (01/09/2024) < order_date (01/10/2024).
-- The user need to order a product to receive it, so the order_date should be < than the deliver_date

-- Checking if we have invalid prices

SELECT COUNT(*) as invalid_prices
FROM sales
WHERE unit_price <= 0;

--We have 2518 records with a order showing 0$
-- This one is pretty simple, no product should be sold for 0$. 

-- Checking if we have orders placed with 0 products
SELECT COUNT(*) AS zero_quantity
FROM sales
WHERE quantity = 0;


-- Checking if we have some invalid conversions

SELECT COUNT(*) AS invalid_conversions
FROM marketing
WHERE conversions > clicks


SELECT m.campaign_id, o.order_id
FROM marketing m
LEFT JOIN sales o
	ON FIND_IN_SET (o.order_id, m.related orders) > 0
WHERE o.order_id IS NULL
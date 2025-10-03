------------------------------------------------------------
-- 1. Fix incoherent dates
------------------------------------------------------------
CREATE OR ALTER VIEW vw_datesfixed AS
SELECT
    order_id,
    order_date,
    delivery_date,
    CASE WHEN delivery_date < order_date THEN delivery_date ELSE order_date END AS order_date_fixed,
    CASE WHEN delivery_date < order_date THEN order_date ELSE delivery_date END AS delivery_date_fixed,
    CASE WHEN delivery_date < order_date THEN 1 ELSE 0 END AS was_swapped
FROM sales;
GO


------------------------------------------------------------
-- 2. Clean Product ID and Unit Price
------------------------------------------------------------
CREATE OR ALTER VIEW vw_sales_c AS
SELECT
    s.order_id,
    s.customer_id,
    CONCAT('P', CAST(CAST(s.product_id AS INT) AS varchar(10))) AS product_id_clean,
    s.region,
    s.product_category,
    s.unit_price,
    s.unit_price / 100.0 AS unit_price_clean,
    s.quantity,
    s.order_status,
    s.sales_channel,
    d.order_date_fixed,
    d.delivery_date_fixed,
    d.was_swapped
FROM sales s
INNER JOIN vw_datesfixed d
    ON s.order_id = d.order_id
WHERE s.unit_price > 0;
GO


------------------------------------------------------------
-- 3. Flagging zero quantity orders
------------------------------------------------------------
CREATE OR ALTER VIEW vw_sales_final AS
SELECT *,
       CASE WHEN quantity = 0 THEN 0 ELSE 1 END AS is_valid_quantity
FROM vw_sales_c;
GO


------------------------------------------------------------
-- 4. Marketing Orders
------------------------------------------------------------
CREATE OR ALTER VIEW vw_marketing_orders AS
SELECT
    m.campaign_id,
    TRIM(value) AS order_id,
    CASE WHEN sf.order_id IS NOT NULL THEN 1 ELSE 0 END AS is_valid_order
FROM marketing m
CROSS APPLY STRING_SPLIT(m.related_orders, ',') AS split_values
LEFT JOIN vw_sales_final sf
    ON TRIM(split_values.value) = sf.order_id;
GO

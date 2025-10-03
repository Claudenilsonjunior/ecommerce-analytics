-- 1. Fixing incoherent dates
-- Solution: Swap values when delivery_date < order_date.
-- We also add an audit flag (was_swapped) for transparency.

WITH datesfixed AS (
	SELECT
		order_id,
		order_date,
		delivery_date,
		
		CASE
            WHEN delivery_date < order_date THEN delivery_date
            ELSE order_date
        END AS order_date_fixed,

		CASE
			WHEN delivery_date < order_date THEN order_date
			ELSE delivery_date
		END AS delivery_date_fixed,

		CASE WHEN delivery_date < order_date THEN 1 ELSE 0 END AS was_swapped
	FROM sales
),


-- 2. Cleaning Product ID and Unit Price
-- Issues found:
-- - product_id stored in "458,00" format → must be normalized.
-- - unit_price stored as integer cents (e.g., 34158 = 341.58).
-- - ~5% of records have unit_price <= 0 → invalid.
-- Solution: normalize IDs, convert prices to decimals, and exclude invalid rows.

sales_c AS(
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
	INNER JOIN datesfixed d
        ON s.order_id = d.order_id
	WHERE s.unit_price > 0
),

-- 3. Flagging zero quantity orders
-- Orders with quantity = 0 are excluded from analysis
sales_final AS (
    SELECT *,
	-- Flagging invalid orders: 0 = invalid (qty = 0), 1 = valid
        CASE WHEN quantity = 0 THEN 0 ELSE 1 END AS is_valid_quantity
    FROM sales_c
),

-- 4. Marketing orders with validity flag
-- Flag orders that do not exist in sales_final
marketing_orders_cte AS (
    SELECT
        m.campaign_id,
        TRIM(value) AS order_id,
        CASE 
            WHEN sf.order_id IS NOT NULL THEN 1
            ELSE 0
        END AS is_valid_order
    FROM marketing m
    CROSS APPLY STRING_SPLIT(m.related_orders, ',') AS split_values
    LEFT JOIN sales_final sf
        ON TRIM(split_values.value) = sf.order_id
)


-- FINAL SELECTIONS FOR ANALYSIS / DASHBOARDS

------------------------------------------------------------
-- Q1. What is the total revenue and average order value?
-- Executive relevance:
--   Shows how much money the company is making
--   and how much each order contributes on average.
------------------------------------------------------------

--SELECT 
--    FORMAT(SUM(unit_price_clean * quantity), 'C', 'pt-BR') AS total_revenue,
--    FORMAT(AVG(unit_price_clean * quantity), 'C', 'pt-BR') AS avg_order_value
--FROM sales_final
--WHERE is_valid_quantity = 1;

-- Total Revenue: R$ 32.509.010,16
-- AVG Order Value: R$ 699,18

------------------------------------------------------------
-- Q2. How is revenue distributed across regions?
-- Executive relevance:
--   Identifies top-performing regions and potential markets
--   for further investment or targeted campaigns.
------------------------------------------------------------
--SELECT 
--    region,
--    COUNT(DISTINCT order_id) AS total_orders,
--    FORMAT(SUM(unit_price_clean * quantity), 'C', 'pt-br') AS total_revenue,
--    FORMAT(AVG(unit_price_clean * quantity), 'C', 'pt-br') AS avg_order_value
--FROM sales_final
--WHERE is_valid_quantity = 1
--GROUP BY region
--ORDER BY total_revenue DESC;

--Sudeste	9355	R$ 6.583.379,06	R$ 703,73
--Norte	9381	R$ 6.560.816,48	R$ 699,37
--Sul	9252	R$ 6.535.927,30	R$ 706,43
--Centro-Oeste	9302	R$ 6.500.652,75	R$ 698,84
--Nordeste	9206	R$ 6.328.234,57	R$ 687,40

------------------------------------------------------------
-- Q3. What are the Top 10 products driving revenue?
-- Executive relevance:
--   Helps understand product mix and dependency.
--   Can guide inventory and promotional strategies.
------------------------------------------------------------
--SELECT TOP 10
--    product_id_clean,
--    FORMAT(SUM(unit_price_clean * quantity), 'C', 'pt-br') AS total_revenue,
--    COUNT(DISTINCT order_id) AS total_orders
--FROM sales_final
--WHERE is_valid_quantity = 1
--GROUP BY product_id_clean
--ORDER BY total_revenue DESC;

------------------------------------------------------------
-- Q4. How are campaigns performing in terms of conversions?
-- Executive relevance:
--   Conversion rate (CVR) tells how efficient campaigns are
--   at turning clicks into purchases.
------------------------------------------------------------
--SELECT 
--    campaign_id,
--    SUM(clicks) AS total_clicks,
--    SUM(conversions) AS total_conversions,
--    CAST(1.0 * SUM(conversions) / NULLIF(SUM(clicks),0) AS DECIMAL(10,4)) AS conversion_rate
--FROM marketing
--WHERE conversions <= clicks   -- exclude invalid campaigns
--GROUP BY campaign_id
--ORDER BY conversion_rate DESC;


------------------------------------------------------------
-- Q5. What is the ROI of each campaign?
-- Executive relevance:
--   ROI = (Revenue - Spend) / Spend
--   Shows if campaigns are generating profit or burning money.
------------------------------------------------------------
--SELECT 
--    m.campaign_id,
--    FORMAT(SUM(m.total_spent), 'C', 'pt-br') AS total_spend,
--    FORMAT(SUM(s.unit_price_clean * s.quantity), 'C', 'pt-br') AS attributed_revenue,
--    CAST(
--        (SUM(s.unit_price_clean * s.quantity) - SUM(m.total_spent)) 
--        / NULLIF(SUM(m.total_spent),0) 
--    AS DECIMAL(10,2)) AS ROI
--FROM marketing_orders_cte mo
--JOIN sales_final s 
--    ON mo.order_id = s.order_id 
--   AND mo.is_valid_order = 1
--JOIN marketing m 
--    ON m.campaign_id = mo.campaign_id
--WHERE s.is_valid_quantity = 1
--GROUP BY m.campaign_id
--ORDER BY ROI DESC;

------------------------------------------------------------
-- Q6. Which campaigns drive the most valid orders?
-- Executive relevance:
--   Goes beyond clicks → ties campaigns directly to real sales.
--   Shows where marketing spend is effectively converting.
------------------------------------------------------------
--SELECT 
--    m.campaign_id,
--    COUNT(DISTINCT s.order_id) AS valid_orders,
--    FORMAT(SUM(s.unit_price_clean * s.quantity), 'C', 'pt-br') AS revenue_from_campaign
--FROM marketing_orders_cte mo
--JOIN sales_final s 
--    ON mo.order_id = s.order_id 
--   AND mo.is_valid_order = 1
--JOIN marketing m 
--    ON m.campaign_id = mo.campaign_id
--WHERE s.is_valid_quantity = 1
--GROUP BY m.campaign_id
--ORDER BY revenue_from_campaign DESC;


------------------------------------------------------------
-- Q7. Executive Summary: Key KPIs in one view
-- Executive relevance:
--   High-level snapshot for quick decision-making.
------------------------------------------------------------
--SELECT
--    (SELECT FORMAT(SUM(unit_price_clean * quantity), 'C', 'pt-br') 
--     FROM sales_final 
--     WHERE is_valid_quantity = 1) AS total_revenue,
     
--    (SELECT FORMAT(AVG(unit_price_clean * quantity), 'C', 'pt-br') 
--     FROM sales_final 
--     WHERE is_valid_quantity = 1) AS avg_order_value,
     
--    (SELECT COUNT(DISTINCT order_id) 
--     FROM sales_final 
--     WHERE is_valid_quantity = 1) AS total_orders,
     
--    (SELECT CAST(1.0 * SUM(conversions) / NULLIF(SUM(clicks),0) AS DECIMAL(10,4)) 
--     FROM marketing
--     WHERE conversions <= clicks) AS avg_conversion_rate,
     
--    (SELECT CAST(
--        (SUM(s.unit_price_clean * s.quantity) - SUM(m.total_spent)) 
--        / NULLIF(SUM(m.total_spent),0)
--     AS DECIMAL(10,2))
--     FROM marketing_orders_cte mo
--     JOIN sales_final s 
--       ON mo.order_id = s.order_id AND mo.is_valid_order = 1
--     JOIN marketing m 
--       ON m.campaign_id = mo.campaign_id
--     WHERE s.is_valid_quantity = 1) AS overall_ROI;

	 -- R$ 32.509.010,16 Total_Revenue
	 -- R$ 699,18 AVG Order Value
	 -- 46496 Orders
	 -- 0.4998 AVG Conversion Rate
	 -- -1.00 Overall ROI
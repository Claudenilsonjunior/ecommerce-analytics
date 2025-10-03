
-- 50000 records on sales table
-- 500 records on marketing table

-- Starting data quality checks on common issues

-- Checking incoherent dates

SELECT COUNT(*) as inconherent_dates
From sales
WHERE delivery_date < order_date;

-- Found 3,373 cases where delivery_date < order_date
-- Problem: delivery_date cannot be earlier than order_date
-- Example: delivery_date (2024-09-01) < order_date (2024-10-01)
-- Explanation: an order must exist before it can be delivered
-- Proposed solution: swap values when incoherent
-- =============================================================================


-- Checking invalid prices

SELECT COUNT(*) as invalid_prices
FROM sales
WHERE unit_price <= 0;

-- Found 2,518 rows (~5% of the dataset) with unit_price <= 0
-- Problem: invalid prices impact revenue and profitability analysis
-- Explanation: unit_price should always be > 0
-- Impact: These rows compromise revenue, average ticket size,
-- and profitability analysis.
-- Proposed solution: Use a centralized product catalog to reference correct prices.
-- Temporary solution: Exclude these rows from all financial analyses.
-- ==================================================================================


-- Checking if we have orders placed with 0 products
SELECT COUNT(*) AS zero_quantity
FROM sales
WHERE quantity = 0;

-- Problem: 1,048 orders have quantity = 0
-- Breakdown:
--   - 986 orders with positive price (creates fake revenue)
--   - 32 orders with zero price (irrelevant orders)
--   - 30 orders with negative price (creates wrong negative revenue)
-- Impact: Including these orders would distort total sales, average order value, and revenue KPIs
-- Solution for analysis: Exclude all orders with quantity = 0 from calculations
-- Business recommendation: Add upstream validation in the sales system to block orders with quantity = 0



-- Checking if we have some invalid conversions

SELECT COUNT(*) AS invalid_conversions
FROM marketing
WHERE conversions > clicks

-- Problem: 41 campaigns have conversions greater than clicks
-- Possible explanation: In some ad platforms, conversions can be set as "count every"
--   → Meaning a single click may generate multiple conversions (e.g., repeat purchases)
-- Impact: Without clarification, this inflates CVR and ROI, leading to misleading insights
-- Solution for analysis: Exclude these campaigns or flag them as "suspicious conversions"
-- Business recommendation: Standardize conversion tracking across platforms (prefer "one per click") 
--   or clearly separate "every" vs "unique" conversions in reporting



-- Explodir os pedidos relacionados
SELECT
    m.campaign_id,
    TRIM(value) AS order_id
INTO marketing_orders
FROM marketing m
CROSS APPLY STRING_SPLIT(m.related_orders, ',');


SELECT mo.campaign_id, mo.order_id
FROM marketing_orders mo
LEFT JOIN sales s
  ON mo.order_id = s.order_id
WHERE s.order_id IS NULL;

-- Problem: Some campaigns list orders that do not exist in the sales table
-- Example: Campaign X references order_id 1234, but 1234 is not in sales
-- Impact: Including these orders inflates campaign ROI and conversion metrics
-- Solution for analysis: Exclude these invalid order references
-- Business recommendation: Add validation to ensure marketing only references valid sales orders




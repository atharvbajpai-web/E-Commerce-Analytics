-- =====================================================================
-- E-COMMERCE SALES & CUSTOMER ANALYTICS  |  SQL ANALYSIS
-- Database : SQLite (works in MySQL/PostgreSQL with minor date changes)
-- Tables   : orders (1 row per order), order_items (1 row per product
--            in an order), products, customers
-- Tip      : "net_sales" = amount charged to the customer (after
--            discount, incl. tax + shipping). "profit" = net_sales
--            - product_cost - shipping_cost.
-- Every query uses only SELECT, WHERE, GROUP BY, ORDER BY, JOIN, CASE.
-- =====================================================================


-- ---------------------------------------------------------------------
-- SECTION A : DATA UNDERSTANDING & QUALITY CHECKS
-- ---------------------------------------------------------------------

-- Q1. How big is each table?
SELECT 'orders' AS table_name, COUNT(*) AS row_count FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'products',    COUNT(*) FROM products
UNION ALL SELECT 'customers',   COUNT(*) FROM customers;

-- Q2. Is the data clean? (duplicates, missing values, date range)
SELECT
    COUNT(*)                                   AS total_orders,
    COUNT(DISTINCT order_id)                   AS unique_orders,      -- same number = no duplicates
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer,
    SUM(CASE WHEN customer_rating IS NULL THEN 1 ELSE 0 END) AS missing_rating,
    MIN(order_date)                            AS first_order_date,
    MAX(order_date)                            AS last_order_date
FROM orders;


-- ---------------------------------------------------------------------
-- SECTION B : HEADLINE KPIs
-- ---------------------------------------------------------------------

-- Q3. Overall business KPIs
SELECT
    COUNT(*)                                         AS total_orders,
    COUNT(DISTINCT customer_id)                      AS total_customers,
    ROUND(SUM(net_sales), 0)                         AS total_revenue,
    ROUND(SUM(profit), 0)                            AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(net_sales), 1)   AS profit_margin_pct,
    ROUND(AVG(net_sales), 0)                         AS avg_order_value,
    ROUND(AVG(customer_rating), 2)                   AS avg_rating
FROM orders;

-- Q4. What happens to our orders? (Completed / Returned / Cancelled / Pending)
SELECT
    order_status,
    COUNT(*)                                          AS orders,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 1) AS pct_of_orders,
    ROUND(SUM(net_sales), 0)                          AS revenue
FROM orders
GROUP BY order_status
ORDER BY orders DESC;


-- ---------------------------------------------------------------------
-- SECTION C : SALES TRENDS
-- ---------------------------------------------------------------------

-- Q5. Year-wise revenue, profit and orders
SELECT
    SUBSTR(order_date, 1, 4)           AS year,
    COUNT(*)                           AS orders,
    ROUND(SUM(net_sales), 0)           AS revenue,
    ROUND(SUM(profit), 0)              AS profit,
    ROUND(SUM(profit) * 100.0 / SUM(net_sales), 1) AS margin_pct
FROM orders
GROUP BY SUBSTR(order_date, 1, 4)
ORDER BY year;

-- Q6. Month-wise revenue and profit (for the trend line)
SELECT
    SUBSTR(order_date, 1, 7)           AS month,
    COUNT(*)                           AS orders,
    ROUND(SUM(net_sales), 0)           AS revenue,
    ROUND(SUM(profit), 0)              AS profit
FROM orders
GROUP BY SUBSTR(order_date, 1, 7)
ORDER BY month;

-- Q7. Which sales channel performs best?
SELECT
    sales_channel,
    COUNT(*)                           AS orders,
    ROUND(SUM(net_sales), 0)           AS revenue,
    ROUND(SUM(profit), 0)              AS profit,
    ROUND(AVG(net_sales), 0)           AS avg_order_value
FROM orders
GROUP BY sales_channel
ORDER BY revenue DESC;


-- ---------------------------------------------------------------------
-- SECTION D : PRODUCT PERFORMANCE   (order_items JOIN products)
-- ---------------------------------------------------------------------

-- Q8. Category performance: revenue, profit and margin
SELECT
    p.product_category,
    SUM(oi.quantity)                   AS units_sold,
    ROUND(SUM(oi.net_sales), 0)        AS revenue,
    ROUND(SUM(oi.profit), 0)           AS profit,
    ROUND(SUM(oi.profit) * 100.0 / SUM(oi.net_sales), 1) AS margin_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category
ORDER BY revenue DESC;

-- Q9. Top 10 brands by profit
SELECT
    p.brand,
    ROUND(SUM(oi.net_sales), 0)        AS revenue,
    ROUND(SUM(oi.profit), 0)           AS profit,
    ROUND(SUM(oi.profit) * 100.0 / SUM(oi.net_sales), 1) AS margin_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.brand
ORDER BY profit DESC
LIMIT 10;

-- Q10. Do heavy discounts hurt profit?  (group items into discount bands)
SELECT
    CASE
        WHEN oi.discount_amount * 1.0 / oi.gross_sales < 0.10 THEN '1. Under 10%'
        WHEN oi.discount_amount * 1.0 / oi.gross_sales < 0.20 THEN '2. 10-20%'
        WHEN oi.discount_amount * 1.0 / oi.gross_sales < 0.30 THEN '3. 20-30%'
        WHEN oi.discount_amount * 1.0 / oi.gross_sales < 0.40 THEN '4. 30-40%'
        ELSE '5. 40% and above'
    END                                AS discount_band,
    COUNT(*)                           AS items_sold,
    ROUND(SUM(oi.net_sales), 0)        AS revenue,
    ROUND(SUM(oi.profit), 0)           AS profit,
    ROUND(SUM(oi.profit) * 100.0 / SUM(oi.net_sales), 1) AS margin_pct
FROM order_items oi
GROUP BY discount_band
ORDER BY discount_band;


-- ---------------------------------------------------------------------
-- SECTION E : CUSTOMER ANALYSIS
-- ---------------------------------------------------------------------

-- Q11. Customer segment performance
SELECT
    customer_segment,
    COUNT(DISTINCT customer_id)        AS customers,
    COUNT(*)                           AS orders,
    ROUND(SUM(net_sales), 0)           AS revenue,
    ROUND(AVG(net_sales), 0)           AS avg_order_value,
    ROUND(SUM(profit) * 100.0 / SUM(net_sales), 1) AS margin_pct
FROM orders
GROUP BY customer_segment
ORDER BY revenue DESC;

-- Q12. Country performance
SELECT
    customer_country,
    COUNT(*)                           AS orders,
    ROUND(SUM(net_sales), 0)           AS revenue,
    ROUND(SUM(profit), 0)              AS profit,
    ROUND(AVG(customer_rating), 2)     AS avg_rating
FROM orders
GROUP BY customer_country
ORDER BY revenue DESC;

-- Q13. Which age group buys the most?
SELECT
    CASE
        WHEN customer_age < 25 THEN '18-24'
        WHEN customer_age < 35 THEN '25-34'
        WHEN customer_age < 45 THEN '35-44'
        WHEN customer_age < 55 THEN '45-54'
        ELSE '55+'
    END                                AS age_group,
    COUNT(*)                           AS orders,
    ROUND(SUM(net_sales), 0)           AS revenue,
    ROUND(AVG(net_sales), 0)           AS avg_order_value
FROM orders
GROUP BY age_group
ORDER BY age_group;

-- Q14. Top 10 customers by revenue
SELECT
    customer_id,
    customer_name,
    customer_segment,
    COUNT(*)                           AS orders,
    ROUND(SUM(net_sales), 0)           AS revenue
FROM orders
GROUP BY customer_id, customer_name, customer_segment
ORDER BY revenue DESC
LIMIT 10;

-- Q15. How are customers spread by number of orders? (repeat behaviour)
SELECT
    CASE
        WHEN order_count = 1 THEN '1 order'
        WHEN order_count <= 3 THEN '2-3 orders'
        WHEN order_count <= 6 THEN '4-6 orders'
        ELSE '7+ orders'
    END                                AS customer_group,
    COUNT(*)                           AS customers,
    ROUND(SUM(total_spent), 0)         AS revenue
FROM (
    SELECT customer_id, COUNT(*) AS order_count, SUM(net_sales) AS total_spent
    FROM orders
    GROUP BY customer_id
) AS per_customer
GROUP BY customer_group
ORDER BY MIN(order_count);


-- ---------------------------------------------------------------------
-- SECTION F : MARKETING & PAYMENTS
-- ---------------------------------------------------------------------

-- Q16. Which marketing channel brings the most value?
SELECT
    marketing_channel,
    COUNT(*)                           AS orders,
    ROUND(SUM(net_sales), 0)           AS revenue,
    ROUND(SUM(profit), 0)              AS profit,
    ROUND(AVG(net_sales), 0)           AS avg_order_value
FROM orders
GROUP BY marketing_channel
ORDER BY revenue DESC;

-- Q17. Payment method mix and failure risk
SELECT
    payment_method,
    COUNT(*)                           AS orders,
    ROUND(SUM(net_sales), 0)           AS revenue,
    ROUND(SUM(CASE WHEN payment_status = 'Failed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS failed_pct
FROM orders
GROUP BY payment_method
ORDER BY orders DESC;


-- ---------------------------------------------------------------------
-- SECTION G : DELIVERY, RETURNS & SATISFACTION
-- ---------------------------------------------------------------------

-- Q18. Delivery speed and delays by shipping method (completed orders only)
SELECT
    shipping_method,
    COUNT(*)                           AS orders,
    ROUND(AVG(delivery_days), 1)       AS avg_delivery_days,
    ROUND(SUM(CASE WHEN delivery_status = 'Delayed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS delayed_pct,
    ROUND(AVG(customer_rating), 2)     AS avg_rating
FROM orders
WHERE order_status = 'Completed'
GROUP BY shipping_method
ORDER BY avg_delivery_days;

-- Q19. Does a late delivery lower customer rating?
SELECT
    delivery_status,
    COUNT(*)                           AS orders,
    ROUND(AVG(customer_rating), 2)     AS avg_rating
FROM orders
WHERE order_status = 'Completed'
GROUP BY delivery_status
ORDER BY avg_rating DESC;

-- Q20. Why do customers return products?
SELECT
    return_reason,
    COUNT(*)                           AS returned_orders,
    ROUND(SUM(net_sales), 0)           AS revenue_lost
FROM orders
WHERE order_status = 'Returned'
GROUP BY return_reason
ORDER BY returned_orders DESC;

-- Q21. Lost revenue: cancelled + returned + pending vs completed
SELECT
    CASE WHEN order_status = 'Completed' THEN 'Completed' ELSE 'Not realised' END AS bucket,
    COUNT(*)                           AS orders,
    ROUND(SUM(net_sales), 0)           AS revenue,
    ROUND(SUM(profit), 0)              AS profit
FROM orders
GROUP BY bucket;

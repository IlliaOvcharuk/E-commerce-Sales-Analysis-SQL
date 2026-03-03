/* PROJECT: E-commerce Sales & Customer Behavior Analysis
Author: Illia Ovcharuk
Description: SQL script for customer segmentation, category performance, retention tracking, and channel benchmarking.
*/

-- =================================================================
-- TASK 1: Customer Classification (Segmentation)
-- Goal: Identify high-value customers based on order totals.
-- =================================================================

WITH order_totals AS (
    SELECT 
        customer_id, 
        order_id,
        SUM(quantity * price) AS over_sum
    FROM sales
    GROUP BY customer_id, order_id
)
SELECT 
    customer_id, 
    over_sum, 
    COUNT(order_id) OVER(PARTITION BY customer_id) AS count_orders,
    ROUND(AVG(over_sum) OVER(PARTITION BY customer_id), 2) AS avg_check, 
    CASE
        WHEN over_sum > 5000 THEN 'Top Spender'
        WHEN over_sum BETWEEN 1000 AND 5000 THEN 'Medium'
        ELSE 'Small'
    END AS status_cost
FROM order_totals
ORDER BY over_sum DESC;

-- =================================================================
-- TASK 2: Best Selling Categories
-- Goal: Find the most profitable categories and unique customer reach.
-- =================================================================

SELECT 
    category, 
    SUM(quantity * price) AS total_amount, 
    SUM(quantity) AS total_quantity, 
    COUNT(DISTINCT customer_id) AS unique_customer
FROM sales
GROUP BY category
ORDER BY total_amount DESC;

-- =================================================================
-- TASK 3: Retention & Loyalty Analysis
-- Goal: Calculate the number of days between customer orders.
-- =================================================================

WITH unique_orders AS (
    SELECT 
        customer_id, 
        order_id, 
        order_date, 
        LAG(order_date) OVER(PARTITION BY customer_id ORDER BY order_date) AS previous_order
    FROM sales
    GROUP BY order_date, customer_id, order_id
)
SELECT 
    customer_id, 
    order_id, 
    order_date, 
    previous_order,
    order_date - previous_order AS days_since_last_order
FROM unique_orders
GROUP BY customer_id, order_id, order_date, previous_order
ORDER BY customer_id, order_date;

-- =================================================================
-- TASK 4: Marketing Channel & Device Efficiency (Benchmarking)
-- Goal: Compare segment AOV with general channel/device averages.
-- =================================================================

WITH base_metrics AS (
    SELECT 
        channel,
        device_type,
        price * quantity AS line_total,
        AVG(price * quantity) OVER(PARTITION BY channel) AS avg_channel,
        AVG(price * quantity) OVER(PARTITION BY device_type) AS avg_device
    FROM sales
)
SELECT 
    channel, 
    device_type,
    ROUND(AVG(line_total), 2) AS current_segment_avg,
    ROUND(AVG(avg_channel), 2) AS general_channel_avg,
    ROUND(AVG(avg_device), 2) AS general_device_avg
FROM base_metrics
GROUP BY channel, device_type
ORDER BY channel, current_segment_avg DESC;

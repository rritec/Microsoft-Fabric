-- sales_summary.sql
-- Shared SQL script stored in Fabric Environment Resources
-- Can be executed from any notebook attached to this environment

SELECT
    category,
    COUNT(order_id)          AS total_orders,
    SUM(total_amount)        AS total_revenue,
    AVG(total_amount)        AS avg_order_value,
    MIN(total_amount)        AS min_order_value,
    MAX(total_amount)        AS max_order_value,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM fact_orders
WHERE status = 'Completed'
GROUP BY category
ORDER BY total_revenue DESC

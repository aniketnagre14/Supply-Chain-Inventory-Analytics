SELECT COUNT(*) AS total_records
FROM supply_chain_orders;

SELECT *
FROM supply_chain_orders
LIMIT 10;

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'supply_chain_orders'
ORDER BY ordinal_position;

--Calculate overall business KPIs
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT order_id) AS unique_orders,
    ROUND(SUM(sales)::numeric, 2) AS total_sales,
    ROUND(SUM(order_profit_per_order)::numeric, 2)
        AS total_order_profit,
    ROUND(AVG(days_for_shipping_real)::numeric, 2)
        AS avg_actual_shipping_days,
    ROUND(AVG(days_for_shipment_scheduled)::numeric, 2)
        AS avg_scheduled_shipping_days
FROM supply_chain_orders;


--Analyze shipping performance

SELECT
    shipping_mode,
    COUNT(*) AS total_records,
    ROUND(AVG(days_for_shipping_real)::numeric, 2)
        AS avg_actual_days,
    ROUND(AVG(days_for_shipment_scheduled)::numeric, 2)
        AS avg_scheduled_days,
    ROUND(AVG(
        days_for_shipping_real -
        days_for_shipment_scheduled
    )::numeric, 2) AS avg_delay_days
FROM supply_chain_orders
GROUP BY shipping_mode
ORDER BY avg_delay_days DESC;

--Sales by product category

SELECT
    category_name,
    ROUND(SUM(sales)::numeric, 2) AS total_sales,
    ROUND(SUM(order_profit_per_order)::numeric, 2) AS total_profit
FROM supply_chain_orders
GROUP BY category_name
ORDER BY total_sales DESC;

--Sales by region

SELECT
    order_region,
    ROUND(SUM(sales)::numeric, 2) AS total_sales,
    COUNT(DISTINCT order_id) AS unique_orders
FROM supply_chain_orders
GROUP BY order_region
ORDER BY total_sales DESC;

--Order status analysis

SELECT
    order_status,
    COUNT(*) AS total_records,
    COUNT(DISTINCT order_id) AS unique_orders
FROM supply_chain_orders
GROUP BY order_status
ORDER BY total_records DESC;

-- Identify late shipments
SELECT
    shipping_mode,
    COUNT(*) AS total_records,
    SUM(
        CASE
            WHEN days_for_shipping_real >
                 days_for_shipment_scheduled
            THEN 1 ELSE 0
        END
    ) AS late_records,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN days_for_shipping_real >
                     days_for_shipment_scheduled
                THEN 1 ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS late_record_percentage
FROM supply_chain_orders
GROUP BY shipping_mode
ORDER BY late_record_percentage DESC;


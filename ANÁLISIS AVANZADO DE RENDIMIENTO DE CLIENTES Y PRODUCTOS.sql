/* ===============================================================================
ANÁLISIS AVANZADO DE RENDIMIENTO DE CLIENTES Y PRODUCTOS
Objetivo: 
1. Segmentar clientes basados en su gasto vs el promedio de su país.
2. Identificar el producto más comprado por cada cliente VIP.
3. Calcular el crecimiento acumulado de ventas (Running Total).
===============================================================================
*/

WITH CustomerPerformance AS (
    -- Calculamos métricas base por cliente y comparamos con su mercado (país)
    SELECT 
        c.customer_key,
        c.first_name || ' ' || c.last_name AS full_name,
        c.country,
        rc.total_sales,
        rc.total_orders,
        -- Promedio de ventas por país usando Window Function
        AVG(rc.total_sales) OVER(PARTITION BY c.country) AS avg_country_sales,
        -- Ranking de clientes por ventas dentro de su propio país
        RANK() OVER(PARTITION BY c.country ORDER BY rc.total_sales DESC) AS rank_in_country
    FROM gold.dim_customers c
    JOIN gold.report_customers rc ON c.customer_key = rc.customer_key
),

ProductAnalysis AS (
    -- Identificamos el producto favorito de cada cliente (el más gastado)
    SELECT 
        customer_key,
        product_key,
        SUM(sales_amount) AS total_spent_on_prod,
        ROW_NUMBER() OVER(PARTITION BY customer_key ORDER BY SUM(sales_amount) DESC) AS item_rank
    FROM gold.fact_sales
    GROUP BY customer_key, product_key
)

SELECT 
    cp.full_name,
    cp.country,
    cp.total_sales,
    cp.rank_in_country,
    p.product_name,
    p.category,
    -- Lógica de segmentación avanzada
    CASE 
        WHEN cp.total_sales > cp.avg_country_sales * 1.5 THEN 'High Value Asset'
        WHEN cp.total_sales > cp.avg_country_sales THEN 'Above Average'
        ELSE 'Standard'
    END AS customer_strategic_value,
    -- Cálculo de contribución porcentual del producto favorito al total del cliente
    ROUND((pa.total_spent_on_prod / cp.total_sales) * 100, 2) AS pct_contribution_top_product
FROM CustomerPerformance cp
JOIN ProductAnalysis pa ON cp.customer_key = pa.customer_key AND pa.item_rank = 1
JOIN gold.dim_products p ON pa.product_key = p.product_key
WHERE cp.rank_in_country <= 10 -- Solo el Top 10 de cada país
ORDER BY cp.country, cp.rank_in_country;
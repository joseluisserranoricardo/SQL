/* ===============================================================================
ANÁLISIS DE MOMENTUM DE VENTAS Y PENETRACIÓN DE PRODUCTO
Objetivo:
1. Comparar las ventas del mes actual contra el mes anterior (MoM Growth).
2. Identificar productos "estrella" que representan > 10% de las ventas de su categoría.
3. Calcular la fecha de la primera y última venta de cada producto dinámicamente.
===============================================================================
*/

WITH MonthlySales AS (
    -- Agregamos ventas por mes y año para ver tendencias
    SELECT 
        STRFTIME('%Y-%m', order_date) AS month_id,
        SUM(sales_amount) AS current_month_revenue,
        COUNT(DISTINCT order_number) AS total_orders
    FROM gold.fact_sales
    GROUP BY 1
),

TrendAnalysis AS (
    -- Usamos LAG para comparar el mes actual con el anterior
    SELECT 
        month_id,
        current_month_revenue,
        LAG(current_month_revenue) OVER (ORDER BY month_id) AS prev_month_revenue,
        total_orders,
        -- Cálculo del crecimiento porcentual mes a mes (MoM)
        ROUND(((current_month_revenue - LAG(current_month_revenue) OVER (ORDER BY month_id)) 
                / LAG(current_month_revenue) OVER (ORDER BY month_id)) * 100, 2) AS mom_growth_pct
    FROM MonthlySales
),

CategoryDominance AS (
    -- Identificamos qué productos dominan su categoría usando una subconsulta
    SELECT 
        p.product_name,
        p.category,
        rp.total_sales AS product_sales,
        -- Ventas totales de la categoría para calcular participación
        SUM(rp.total_sales) OVER(PARTITION BY p.category) AS category_total_sales
    FROM gold.dim_products p
    JOIN gold.report_products rp ON p.product_key = rp.product_key
)

SELECT 
    t.month_id,
    t.current_month_revenue,
    t.mom_growth_pct,
    -- Agregamos información de productos dominantes en ese contexto
    (SELECT cd.product_name 
     FROM CategoryDominance cd 
     WHERE cd.product_sales = (SELECT MAX(product_sales) FROM CategoryDominance)
     LIMIT 1) AS all_time_top_product,
    -- Clasificación del rendimiento del mes
    CASE 
        WHEN t.mom_growth_pct > 0 THEN '📈 Crecimiento'
        WHEN t.mom_growth_pct < 0 THEN '📉 Declive'
        ELSE '➖ Estable'
    END AS trend_status
FROM TrendAnalysis t
WHERE t.prev_month_revenue IS NOT NULL -- Filtramos el primer mes por no tener comparativa
ORDER BY t.month_id DESC;
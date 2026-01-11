SQL Data Analytics: Customer & Product Intelligence
Este repositorio contiene una serie de scripts avanzados de SQL diseñados para transformar datos transaccionales en insights estratégicos. Utilizando un modelo de datos de ventas (Bikes & Accessories), los análisis se centran en el comportamiento del cliente, tendencias temporales y el rendimiento de categorías.

Estructura de Datos
El análisis se basa en un esquema de tipo Estrella compuesto por:

Hechos: fact_sales (Transacciones detalladas).

Dimensiones: dim_customers, dim_products.

Capas de Reporte: report_customers, report_products (Tablas pre-agregadas para optimización).

Scripts Principales
1. Análisis de Segmentación y Clientes VIP
Archivo: customer_performance_analysis.sql

Este script identifica el valor estratégico de los clientes comparando su gasto individual contra el promedio de su mercado local (país).

Técnicas utilizadas: * Window Functions: AVG() OVER y RANK() OVER para métricas comparativas.

CTEs: Organización modular para separar el perfil del cliente del análisis de productos.

Agregación Condicional: Clasificación de clientes en categorías (High Value, Above Average, Standard).

2. Momentum de Ventas y Análisis MoM
Archivo: sales_momentum_trends.sql

Un análisis enfocado en la dimensión temporal para entender si el negocio está creciendo o contrayéndose mes a mes, además de identificar la dominancia de productos.

Técnicas utilizadas:

Time Series Analysis: Uso de LAG() para obtener datos del periodo anterior.

Cálculos Delta: Cálculo porcentual del crecimiento Month-over-Month (MoM).

Subconsultas Correlacionadas: Extracción dinámica del producto líder histórico dentro del flujo de tendencias mensuales.

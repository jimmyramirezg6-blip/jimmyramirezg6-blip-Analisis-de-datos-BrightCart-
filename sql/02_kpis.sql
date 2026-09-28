-- Campaigns KPIs : 1 - 7 jul vs prev-week 24 -30 jun
SELECT 
	CASE 
		WHEN s.fecha_pedido BETWEEN DATE '2024-06-24' AND DATE '2024-06-30' THEN 'Semana previa'
		WHEN s.fecha_pedido BETWEEN DATE '2024-07-01' AND DATE '2024-07-07' THEN 'Semana rebajas'
	END AS periodo, 
	ROUND(
		SUM(ol.cantidad * ol.precio_unitario::NUMERIC * (1 - ol.descuento_pct::NUMERIC)),2
	) AS income, 
	SUM(ol.cantidad) AS counts, 
	COUNT(DISTINCT ol.pedido_id) AS orders, 

	ROUND(
		SUM(ol.cantidad * ol.precio_unitario::NUMERIC * (1 - ol.descuento_pct::NUMERIC)) / COUNT(DISTINCT ol.pedido_id), 2
	) AS avg_ticket
	
FROM order_lines ol
JOIN sales s ON ol.pedido_id = s.pedido_id
WHERE s.fecha_pedido BETWEEN DATE '2024-06-24' AND DATE '2024-07-07'
GROUP BY periodo
ORDER BY periodo;

-- 

SELECT 
	ROUND(
		SUM(ol.cantidad * ol.precio_unitario::NUMERIC), 2	
	) AS income, 
	ROUND(
		SUM(ol.cantidad * ol.precio_unitario::NUMERIC * (1 - ol.descuento_pct::NUMERIC)), 2
	) AS income_final
FROM order_lines ol 
JOIN sales s ON ol.pedido_id = s.pedido_id
WHERE s.campana_id = 1


-- 
SELECT 
	ROUND(
		SUM(ol.cantidad * ol.precio_unitario::NUMERIC * ol.descuento_pct::NUMERIC) 
		/ SUM(ol.cantidad * ol.precio_unitario::NUMERIC) * 100, 2
	) AS descuento_ponderado, 
	ROUND(AVG(ol.descuento_pct::NUMERIC)*100, 2 ) AS descuento_simple
FROM order_lines ol
JOIN sales s ON ol.pedido_id = s.pedido_id
WHERE s.campana_id = 1


--

SELECT
	CASE 
		WHEN fecha_pedido BETWEEN DATE '2024-06-24' AND DATE '2024-06-30' THEN 'Semana previa'
		WHEN fecha_pedido BETWEEN DATE '2024-07-01' AND DATE '2024-07-07' THEN 'Semana rebajas'
	END AS periodo, 
	COUNT(DISTINCT cliente_id) AS customers
FROM sales
WHERE fecha_pedido BETWEEN DATE '2024-06-24' AND DATE '2024-07-07'
GROUP BY periodo
ORDER BY periodo; 

--

WITH previa AS (
	SELECT 
		SUM(ol.cantidad * ol.precio_unitario * (1 - ol.descuento_pct)) AS income, 
		SUM(ol.cantidad::DOUBLE PRECISION) AS quantity, 
		SUM(ol.cantidad * ol.precio_unitario * (1 - ol.descuento_pct))
		/ COUNT(DISTINCT ol.pedido_id) AS ticket
	FROM order_lines ol
	JOIN sales s ON ol.pedido_id = s.pedido_id
	WHERE s.fecha_pedido BETWEEN DATE '2024-06-24' AND DATE '2024-06-30'
), 
rebajas AS (
	SELECT
		SUM(ol.cantidad * ol.precio_unitario * (1 - ol.descuento_pct)) AS income, 
		SUM(ol.cantidad::DOUBLE PRECISION) AS quantity, 
		SUM(ol.cantidad * ol.precio_unitario * (1 - ol.descuento_pct))
		/ COUNT(DISTINCT ol.pedido_id) AS ticket
	FROM order_lines ol
	JOIN sales s ON ol.pedido_id = s.pedido_id
	WHERE s.fecha_pedido BETWEEN DATE '2024-07-01' AND DATE	'2024-07-07'
)

SELECT
	ROUND(((r.income - p.income)/p.income * 100)::NUMERIC, 1) AS crecimiento_ingresos,
	ROUND(((r.quantity - p.quantity)/p.quantity * 100)::NUMERIC, 1) AS crecimiento_unidades,
	ROUND(((r.ticket - p.ticket)/p.ticket * 100)::NUMERIC, 1) AS crecimiento_ticket
FROM previa p, rebajas r; 


--
	
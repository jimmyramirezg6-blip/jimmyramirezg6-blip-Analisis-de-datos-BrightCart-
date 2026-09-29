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

-- ticket por canal
SELECT 
	s.canal,
	ROUND(
		SUM(ol.cantidad * ol.precio_unitario::NUMERIC * (1 - ol.descuento_pct::NUMERIC))
		/ COUNT(DISTINCT ol.pedido_id), 2
	) AS ticket_medio
FROM order_lines ol
JOIN sales s ON ol.pedido_id = s.pedido_id 
WHERE s.campana_id = 1
GROUP BY s.canal
ORDER BY ticket_medio DESC;


-- Ticket promedio, mínimo y máximo
WITH ticket_por_pedido AS (
	SELECT 
		ol.pedido_id, 
		SUM(ol.cantidad * ol.precio_unitario * (1 - ol.descuento_pct)) AS ticket
	FROM order_lines ol
	JOIN sales s ON ol.pedido_id = s.pedido_id
	WHERE s.campana_id = 1 
	GROUP BY ol.pedido_id
)
SELECT
	ROUND(AVG(ticket::NUMERIC),2) AS ticket_medio, 
	ROUND((percentile_cont(0.5) WITHIN GROUP (ORDER BY ticket::NUMERIC))::NUMERIC,2) AS ticket_típico, 
	ROUND(MAX(ticket::NUMERIC),2) AS pedido_más_alto
FROM ticket_por_pedido

-- Método de pagos en rebajas
SELECT
	s.metodo_pago, 
	SUM(ol.cantidad) AS unidades, 
	ROUND(
		SUM(ol.cantidad) * 100.0 / SUM(SUM(ol.cantidad)) OVER (), 2
	)

FROM order_lines ol
JOIN sales s ON ol.pedido_id = s.pedido_id
WHERE s.campana_id = 1
GROUP BY s.metodo_pago
ORDER BY unidades DESC





	
	


	
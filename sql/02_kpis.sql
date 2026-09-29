
-- Ingresos y unidades por categoria en la camapaña, de mayor a menor
SELECT
	pr.categoria, 
	ROUND(
		SUM(ol.cantidad * ol.precio_unitario::NUMERIC *(1 - ol.descuento_pct::NUMERIC)), 2
	) AS income, 
	SUM(ol.cantidad) AS cantidades

FROM order_lines ol 
JOIN sales s ON ol.pedido_id = s.pedido_id
JOIN products pr  ON ol.producto_id = pr.producto_id
WHERE s.campana_id = 1
GROUP BY pr.categoria
ORDER BY income DESC

-- Top 5 productos por unidades en la campaña 
SELECT
	pr.nombre, 
	SUM(ol.cantidad) AS unidades
FROM order_lines ol
JOIN sales s ON ol.pedido_id = s.pedido_id
JOIN products pr ON ol.producto_id = pr.producto_id
WHERE s.campana_id = 1
GROUP BY pr.nombre
ORDER BY unidades DESC
LIMIT 5;

-- Conversión por canal. ¿Qué canal convierte mejor?
WITH ses AS (
	SELECT canal, SUM(sesiones) AS sesiones
	FROM web_visits
	WHERE fecha BETWEEN DATE '2024-07-01' AND DATE '2024-07-21'
	GROUP BY canal
), ped AS (
	SELECT canal, COUNT(DISTINCT pedido_id) AS pedidos
	FROM sales
	WHERE campana_id = 1
	GROUP BY canal
)
SELECT 
	ped.canal, 
	ROUND(
		ped.pedidos * 100.0 /ses.sesiones::NUMERIC, 2
	) AS conversion_
FROM ped
JOIN ses ON ped.canal = ses.canal
ORDER BY conversion_ DESC; 

-- top 3 por unidades y top 3 por ingresos 

WITH prod AS (
	SELECT 
		pr.nombre, 
		SUM(ol.cantidad) AS counts, 
		SUM(ol.cantidad * ol.precio_unitario * (1 - ol.descuento_pct)) AS income
	FROM order_lines ol
	JOIN sales s ON ol.pedido_id = s.pedido_id
	JOIN products pr ON ol.producto_id = pr.producto_id
	WHERE s.campana_id = 1
	GROUP BY pr.nombre
)
(
	SELECT 'counts' AS ranking, nombre, ROUND(counts, 2) AS valor 
	FROM prod ORDER BY counts DESC LIMIT 3
)

UNION ALL
(
	SELECT 'income' AS ranking, nombre, ROUND(income::NUMERIC, 2) AS valor
	FROM prod ORDER BY income DESC LIMIT 3
);

-- Peso del VEstido Alma en la campana
SELECT 
	SUM()


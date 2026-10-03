
-- Revenue and units by category in the campaign, from highest to lowest
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

-- Top 5 products by units in the campaign
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

-- Conversion by channel. Which channel converts best?
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

-- Top 3 by units and top 3 by revenue

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

-- Share of Vestido Alma in the campaign
SELECT 
	SUM(ol.cantidad) AS uds_campana, 
	SUM(CASE WHEN pr.nombre = 'Vestido Alma' THEN ol.cantidad ELSE 0 END) AS uds_alma, 
  -- Alma as a share of the full campaign
	ROUND(
		SUM(CASE WHEN pr.nombre = 'Vestido Alma' THEN ol.cantidad ELSE 0 END) * 100.0
		/ SUM(ol.cantidad), 1
	) AS alma_sobre_total, 
	ROUND(
		SUM(CASE WHEN pr.nombre = 'Vestido Alma' THEN ol.cantidad ELSE 0 END) * 100.0
		/ SUM(CASE WHEN pr.categoria = 'Vestidos' THEN ol.cantidad ELSE 0 END), 1 
	) AS alma_sobre_vestidos
FROM order_lines ol
JOIN sales s ON ol.pedido_id = s.pedido_id
JOIN products pr ON ol.producto_id = pr.producto_id
WHERE s.campana_id = 1;

-- Traffic by channel - campaign (Jul 1-21)
SELECT 
	canal,
	SUM(sesiones) AS sesiones
FROM web_visits
WHERE fecha BETWEEN DATE '2024-07-01' AND DATE '2024-07-21'
GROUP BY canal
ORDER BY sesiones DESC;

-- Sales concentration
WITH por_producto AS (
	SELECT 
		ol.producto_id, 
		SUM(ol.cantidad) AS unidades
	FROM order_lines ol
	JOIN sales s ON ol.pedido_id = s.pedido_id
	WHERE campana_id = 1
	GROUP BY ol.producto_id
), 
rankeado AS (
	SELECT 
		producto_id, 
		unidades, 
		ROW_NUMBER() OVER(ORDER BY unidades DESC) AS rn
	FROM por_producto
)
SELECT 
	COUNT(*) AS productos_distintos, 
	ROUND(
		SUM(CASE WHEN rn <= 10 THEN unidades ELSE 0 END) * 100.0
		/ SUM(unidades), 1
	) AS top10_pct, 
	ROUND(
		SUM(CASE WHEN rn <=50 THEN unidades ELSE 0 END) * 100.0
		/ SUM(unidades), 1
	) AS top50_pct
FROM rankeado; 

-- Revenue by collection in the campaign
SELECT
	pr.coleccion,
	ROUND(
		SUM(ol.cantidad * ol.precio_unitario::NUMERIC * (1 - ol.descuento_pct::NUMERIC)), 2
	) AS ingresos
FROM order_lines ol
JOIN sales s ON ol.pedido_id = s.pedido_id
JOIN products pr ON ol.producto_id = pr.producto_id
WHERE s.campana_id = 1
GROUP BY pr.coleccion
ORDER BY ingresos DESC
LIMIT 4; 

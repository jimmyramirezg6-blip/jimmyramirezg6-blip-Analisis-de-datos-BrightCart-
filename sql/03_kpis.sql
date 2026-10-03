-- Overall return rate
SELECT 
	COUNT(*) AS devoluciones, 
	(SELECT COUNT(*) FROM order_lines) AS lineas_vendidas, 
	ROUND(
		COUNT(*) * 100.0 /(SELECT COUNT(*) FROM order_lines), 1
	) AS tasa_global_pct
FROM refunds r
WHERE r.linea_id IN (SELECT linea_id FROM order_lines);


-- Return rate by category
WITH lineas_cat AS (
	SELECT
		ol.linea_id,
		pr.categoria
	FROM order_lines ol 
	JOIN products pr ON ol.producto_id = pr.producto_id
)
SELECT 
	COALESCE(lc.categoria, 'GLOBAL') AS cateogira, 
	COUNT(*) AS lineas_vendidas, 
	COUNT(r.linea_id) AS devoluciones, 
	ROUND(
		COUNT(r.linea_id) * 100.0 / COUNT(*), 1
	) AS tasa_pct
FROM lineas_cat lc
LEFT JOIN refunds r on lc.linea_id = r.linea_id
GROUP BY GROUPING SETS ((lc.categoria), ())
ORDER BY (lc.categoria IS NULL) DESC, tasa_pct DESC;


-- Number one in sales and number one in returns
WITH por_productos AS (
	SELECT
		pr.nombre, 
		SUM(ol.cantidad) AS unidades, 
		COUNT(*) AS lineas_vendidas, 
		COUNT(r.linea_id) AS devoluciones
	FROM order_lines ol
	JOIN products pr ON ol.producto_id = pr.producto_id
	LEFT JOIN refunds r ON ol.linea_id = r.linea_id
	GROUP BY pr.nombre
)
SELECT
	nombre, 
	unidades, 
	lineas_vendidas, 
	devoluciones, 
	ROUND((devoluciones*100.0)/NULLIF(lineas_vendidas,0), 1) AS tasa_pct
FROM por_productos 
ORDER BY unidades DESC
LIMIT 1;

-- How much Vestido Alma returns cost
WITH alma AS (
	SELECT 
		ol.cantidad * ol.precio_unitario::NUMERIC * (1 - ol.descuento_pct::NUMERIC) AS ingreso, 
		ol.cantidad * pr.coste_unitario::NUMERIC AS coste, 
		(ol.linea_id IN (SELECT linea_id FROM refunds)) AS devuelta
	FROM order_lines ol
	JOIN sales s ON ol.pedido_id = s.pedido_id
	JOIN products pr ON ol.producto_id = pr.producto_id
	WHERE pr.nombre = 'Vestido Alma' AND s.campana_id = 1
)
SELECT
	ROUND(SUM(ingreso), 2) AS ingreso_bruto, 
	ROUND(SUM(ingreso) FILTER (WHERE NOT devuelta), 2) AS ingreso_neto, 
	
	ROUND(SUM(ingreso) FILTER(WHERE NOT devuelta) - SUM(coste) FILTER (WHERE NOT devuelta), 2) AS margen_neto 
FROM alma;

-- Return reasons

SELECT
	motivo,
	COUNT(*) AS devoluciones,
	ROUND(COUNT(*) * 100.0 /SUM(COUNT(*)) OVER(), 1) AS porcentaje
FROM refunds r
WHERE r.linea_id IN (SELECT linea_id FROM order_lines)
GROUP BY motivo
ORDER BY devoluciones DESC;

-- Vestido Alma sales by size in the campaign

SELECT 
	REPLACE(UPPER(TRIM(ol.talla)), 'TALLA ', '') AS talla, 
	SUM(ol.cantidad) AS unidades, 
	ROUND(SUM(ol.cantidad) * 100.0 / SUM(SUM(ol.cantidad)) OVER(), 1) AS porcentaje
FROM order_lines ol 
JOIN sales s ON ol.pedido_id = s.pedido_id
JOIN products pr ON ol.producto_id = pr.producto_id
WHERE pr.nombre = 'Vestido Alma' AND s.campana_id = 1
GROUP BY REPLACE(UPPER(TRIM(ol.talla)), 'TALLA ', '')
ORDER BY unidades DESC;

-- Are Alma returns still coming in?
WITH dev_alma AS (
	SELECT
		r.fecha_devolucion
	FROM refunds r
	JOIN order_lines ol ON r.linea_id = ol.linea_id
	JOIN products pr ON ol.producto_id = pr.producto_id
	WHERE pr.nombre = 'Vestido Alma'
)
SELECT
	COUNT(*) AS devoluciones, 
	MAX(fecha_devolucion) AS ultima_devolucion, 

	COUNT(*) FILTER(WHERE fecha_devolucion >= '2024-07-15') AS desde_15_jul, 
	ROUND(
		COUNT(*) FILTER (WHERE fecha_devolucion >= '2024-07-15') *100.0 / COUNT(*), 1
	) AS pct_ultima_semana
FROM dev_alma;	


-- Return rate by size
WITH lineas_norm AS (
	SELECT 
		ol.linea_id, 
		REPLACE(UPPER(TRIM(ol.talla)), 'TALLA ', '') AS talla
	FROM order_lines ol
)

SELECT 
	ln.talla, 
	COUNT(*) AS ventas, 
	COUNT(r.linea_id) AS devoluciones, 
	ROUND(
		COUNT(r.linea_id) * 100.0 /COUNT(*), 1
	) AS tasa_pct
FROM lineas_norm ln
LEFT JOIN refunds r ON ln.linea_id = r.linea_id
WHERE ln.talla IN('XS', 'S', 'M','L', 'XL')
GROUP BY ln.talla
ORDER BY CASE ln.talla WHEN 'XS' THEN 1 WHEN 'S' THEN 2 WHEN 'M' THEN 3 WHEN 'L' THEN 4 WHEN 'XL' THEN 5 END;

-- How much of the campaign revenue went to returns
WITH camp AS (
	SELECT 
		ol.cantidad * ol.precio_unitario::NUMERIC * (1 - ol.descuento_pct::NUMERIC) AS ingreso, 
		(ol.linea_id IN (SELECT linea_id FROM refunds)) AS devuelta
	FROM order_lines ol
	JOIN sales s ON ol.pedido_id = s.pedido_id
	WHERE s.campana_id = 1
)

SELECT
	ROUND(SUM(ingreso), 2) AS ingreso_bruto, 

	ROUND(SUM(ingreso) FILTER(WHERE devuelta), 2) AS ingreso_devuelto, 
	ROUND(SUM(ingreso) FILTER(WHERE NOT devuelta), 2) AS ingreso_neto,
	ROUND(
		SUM(ingreso) FILTER(WHERE devuelta) * 100.0 / SUM(ingreso), 1
	) AS pct_devuelto
FROM camp;

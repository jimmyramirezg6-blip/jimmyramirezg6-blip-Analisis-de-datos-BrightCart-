SELECT 
	CASE 
		WHEN s.fecha_pedido BETWEEN DATE '2024-06-24' AND DATE '2024-06-30' THEN 'Semana previa'
		WHEN s.fecha_pedido BETWEEN DATE '2024-07-1' AND DATE '2024-07-07' THEN 'Semana rebajas'
	END AS periodo, 
	ROUND(
		SUM(ol.cantidad * ol.precio_unitario::NUMERIC * (1 - ol.descuento_pct::NUMERIC)),2
	) AS ingresos, 
	SUM(ol.cantidad) AS counts, 
	COUNT(DISTINCT ol.pedido_id) AS pedidos
	
FROM order_lines ol
JOIN sales s ON ol.pedido_id = s.pedido_id
WHERE s.fecha_pedido BETWEEN DATE '2024-06-24' AND DATE '2024-07-07'
GROUP BY periodo
ORDER BY periodo;

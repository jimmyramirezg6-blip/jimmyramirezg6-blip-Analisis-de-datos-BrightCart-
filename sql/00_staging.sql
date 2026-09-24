-- ============================================================
-- PROJECT: BrigthCart Main KPIs Analysis
-- Phase 1: staging
-- ============================================================

-- How to Run the Staging Script
--  1. Connect to the database
-- psql -h localhost -U postgres -d brightcart
--  2. Run the script
-- \i sql/00_staging.sql


-- Date format 
SET datestyle = 'ISO, YMD';


DROP TABLE IF EXISTS campaigns; 
CREATE TABLE campaigns (
	
	campaña_id 		BIGINT, 
	nombre  		VARCHAR, 
	tipo   			VARCHAR, 
	fecha_inicio 	DATE, 
	fecha_fin 		DATE, 
	canal 			VARCHAR, 
	presupuesto  	DOUBLE PRECISION, 
	ventas_ano_anterior DOUBLE PRECISION
); 

\copy campaigns FROM 'data/processed/campana.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF-8')

DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
	cliente_id		BIGINT, 
	fecha_registro  DATE, 
	ciudad			VARCHAR, 
	genero 			VARCHAR, 
	edad 			BIGINT
);

\copy customers FROM 'data/processed/clientes.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF-8')

DROP TABLE IF EXISTS refunds;
CREATE TABLE refunds (
	devoluciones_id BIGINT, 
	linea_id 		BIGINT, 
	fecha_devolucion DATE, 
	talla 			VARCHAR, 
	motivo			TEXT,
	talla_norm      VARCHAR
);

\copy refunds FROM 'data/processed/devoluciones.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF-8')


DROP TABLE IF EXISTS order_lines; 
CREATE TABLE order_lines (
	linea_id 		BIGINT, 
	pedido_id 		BIGINT, 
	producto_id 	BIGINT, 
	talla 			VARCHAR, 
	cantidad 		BIGINT, 
	precio_unitario DOUBLE PRECISION, 
	descuento_pct	DOUBLE PRECISION, 
	talla_norm		VARCHAR
); 

\copy order_lines FROM 'data/processed/lineas_pedido.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF-8')


DROP TABLE IF EXISTS sales; 
CREATE TABLE sales (
	pedido_id 		BIGINT, 
	cliente_id		BIGINT, 
	fecha_pedido 	DATE, 
	campana_id 		DOUBLE PRECISION, 
	canal			VARCHAR, 
	ciudad 			VARCHAR, 
	metodo_pago 	VARCHAR
); 

\copy sales FROM 'data/processed/pedidos.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF-8')


DROP TABLE IF EXISTS products; 
CREATE TABLE products (
	producto_id 	BIGINT, 
	nombre 			VARCHAR, 
	categoria 		VARCHAR, 
	temporada 		VARCHAR, 
	coleccion 		VARCHAR, 
	coste_unitario	DOUBLE PRECISION, 
	precio_base 	DOUBLE PRECISION
);
\copy products FROM 'data/processed/productos.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF-8')


DROP TABLE IF EXISTS web_visits; 
CREATE TABLE web_visits (
	fecha 		DATE, 
	canal 		VARCHAR, 
	sesiones	DOUBLE PRECISION
);

\copy web_visits FROM 'data/processed/visitas_web.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF-8')



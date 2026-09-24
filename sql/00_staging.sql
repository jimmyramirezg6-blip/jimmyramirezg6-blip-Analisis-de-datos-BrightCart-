-- ============================================================
-- PROJECT: BrigthCart Main KPIs Analysis
-- Phase 1: staging
-- ============================================================

-- Date format 
SET datestyle = 'ISO, YMD'


DROP TABLE IF EXISTS campaigns; 
CREATE TABLE campaigns (
	campaña_id 		BIGINT, 
	nombre  		VARCHAR, 
	tipo   			VARCHAR, 
	fecha_inicio 	DATE, 
	fecha_fin 		DATE, 
	canal 			VARCHAR, 
	presupuesto  	double precision, 
	ventas_ano_anterior double precision
); 

\COPY campaigns FROM 'data/raw/campaña.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';', ENCODING 'WIN1252')
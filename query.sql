SELECT a.id_marca, a.nom_marca, 
COUNT (b.nom_producto) AS total_producto
FROM  tab_marcas AS a, tab_productos AS b
WHERE a.id_marca = b.id_marca
GROUP BY 1
-- query para saber la cantidad de productos que tiene una marca.

SELECT a.id_subcategoria, a.nom_subcategoria,
COUNT(b.nom_producto) AS total_producto
FROM  tab_subcategorias AS a, tab_productos AS b
WHERE a.id_subcategoria =b.id_subcategoria
GROUP BY 1,2
ORDER BY 3;
--query para saber la cantidad de productos que tiene una subcategoria.

SELECT 
COUNT (a.id_producto) AS conteo,
SUM(a.cantidad_producto) AS suma,
avg(a.cantidad_producto) as promedio
FROM tab_productos a;
--query para sacar sumas, promedios y conteos.


SELECT a.fecha_movimiento, a.cantidad
FROM tab_kardexs AS a
GROUP BY(a.fecha_movimiento, a.cantidad)
HAVING a.fecha_movimiento BETWEEN '2023-01-10' AND '2023-03-10'
ORDER BY 1;
--query para sumar todas las entradas de dinero por fecha en un rango específico

SELECT a.fecha_movimiento, a.cantidad
FROM tab_kardexs AS a
WHERE a.fecha_movimiento BETWEEN '2023-01-10' AND '2023-03-10'
GROUP BY(a.fecha_movimiento, a.cantidad)
ORDER BY 1;
--query para sumar todas las entradas de dinero por fecha en un rango específico sin usar having

DROP VIEW IF EXISTS view_mov_dia;

CREATE VIEW view_mov_dia AS
	SELECT  a.fecha_movimiento,SUM(a.cantidad), a.tipo_movimiento
	FROM tab_kardexs AS a
	GROUP BY(a.fecha_movimiento, a.cantidad, a.tipo_movimiento)
	HAVING a.fecha_movimiento BETWEEN '2023-01-10' AND '2023-03-10'
	ORDER BY 1;

	
SELECT * FROM view_mov_dia;

SELECT MAX(id_kardex) FROM tab_kardexs;

--ejemplo para creación de vista. 

SELECT tp.id_producto, tp.id_categoria, tc.nombre_categoria, tp.nombre_producto 
FROM tab_productos AS tp
INNER JOIN tab_categorias AS tc 
ON tp.id_categoria = tc.id_categoria;
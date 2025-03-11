CREATE OR REPLACE FUNCTION fun_insert_products (
    wid_producto tab_productos.id_producto%TYPE,
    wid_categoria tab_productos.id_categoria%TYPE,
    wid_subcategorias_2 tab_productos.id_subcategorias_2%TYPE,
    wid_subcategorias_3 tab_productos.id_subcategorias_3%TYPE,
    wnombre_producto tab_productos.nombre_producto%TYPE,
    wcosto_unitario  tab_productos.costo_unitario%TYPE,
    wfecha_caducidad tab_productos.fecha_caducidad%TYPE,
    wstock_maximo tab_productos.stock_maximo%TYPE,
    wstock_minimo tab_productos.stock_minimo%TYPE,
    wpunto_reorden tab_productos.punto_reorden%TYPE,
    wpresentacion tab_productos.presentacion%TYPE,
    wvalor_unidad_medida tab_productos.valor_unidad_medida%TYPE,
    wdireccion_imagen tab_productos.direccion_imagen%TYPE,
    westado tab_productos.estado%TYPE,
    wstock_actual tab_productos.stock_actual%TYPE,
    wid_marca tab_productos.id_marca%TYPE,
    wid_unidad_medida tab_productos.id_unidad_medida%TYPE,
    wtotal_existencias tab_productos.total_existencias%TYPE,)
    RETURNS VARCHAR AS 

$$
BEGIN
    IF((SELECT a.id_producto FROM tab_productos a WHERE a.id_producto= wid_producto) IS NULL) THEN
        RAISE NOTICE 'El producto % fue insertado ', wnombre_producto;
        RETURN 'FUNCIONÓ'
    ELSE 
        RAISE NOTICE 'El producto % no pudo ser insertado porque ya existe', %nombre_producto;
        RETURN 'NO FUNCIONÓ'
    END IF;
END;
$$
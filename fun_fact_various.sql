CREATE OR REPLACE FUNCTION fun_fact(
    wid_cliente tab_clientes.id_cliente%TYPE,
    wid_productos INTEGER[],
    wcantidades INTEGER[],
    wind_descto BOOLEAN,
    wind_forma_pago tab_enc_fact.ind_forma_pago%TYPE,
    wnum_caja tab_enc_fact.num_caja%TYPE
) RETURNS BOOLEAN AS
$$
DECLARE 
    wnom_completo   VARCHAR;
    wreg_pmtros     RECORD;
    wreg_productos  RECORD;
    wreg_clientes   RECORD;
    wid_factura     tab_enc_fact.id_factura%TYPE;
    i               INTEGER;
BEGIN
    -- Cargar parámetros generales
    SELECT a.id_empresa, a.nom_empresa, a.dir_empresa, a.val_poriva, a.val_pordesc,
           a.val_puntos, a.val_inifact, a.val_finfact, a.val_actfac, a.id_ciudad, b.nom_ciudad 
    INTO wreg_pmtros 
    FROM tab_pmtros a, tab_ciudades b
    WHERE a.id_ciudad = b.id_ciudad;

    -- Validar el cliente
    SELECT id_cliente, nom_cliente, ape_cliente, ind_estado INTO wreg_clientes 
    FROM tab_clientes WHERE id_cliente = wid_cliente;
    
    IF NOT FOUND OR wreg_clientes.ind_estado IS FALSE THEN
        RAISE EXCEPTION 'Cliente no válido o tiene estado inactivo';
        RETURN FALSE;
    END IF;
    
    -- Verificar límite de facturación
    IF wreg_pmtros.val_actfact >= wreg_pmtros.val_finfact THEN
        RAISE NOTICE '¡¡ ALERTA... UYYYYY ÚLTIMA FACTURA !!, no podrá seguir facturando... Vaya a la DIAN';
    END IF;
    
    -- Generar número de factura
    wid_factura := wreg_pmtros.val_actfact;
    wreg_pmtros.val_actfact := wreg_pmtros.val_actfact + 1;
    UPDATE tab_pmtros SET val_actfact = wreg_pmtros.val_actfact;
    
    -- Insertar encabezado de factura
    INSERT INTO tab_enc_fact VALUES (wid_factura, CURRENT_DATE, CURRENT_TIME, wreg_clientes.id_cliente, 
                                     wreg_pmtros.id_ciudad, wnum_caja, 0, TRUE, TRUE);
    
    -- Iterar sobre los productos
    FOR i IN 1..array_length(wid_productos, 1) LOOP
        -- Validar existencia del producto
        SELECT id_producto, nombre_producto, val_venta, total_existencias INTO wreg_productos 
        FROM tab_productos WHERE id_producto = wid_productos[i];
        
        IF NOT FOUND THEN
            RAISE NOTICE 'El producto con ID % no existe', wid_productos[i];
            RETURN FALSE;
        ELSIF wcantidades[i] > wreg_productos.total_existencias THEN
            RAISE NOTICE 'Stock insuficiente para el producto %', wid_productos[i];
            RETURN FALSE;
        END IF;
        
        -- Insertar detalle de factura
        INSERT INTO tab_det_fact VALUES (wid_factura, wid_productos[i], wcantidades[i], wreg_productos.val_venta);
    END LOOP;
    
    RETURN TRUE;
END;
$$ LANGUAGE PLPGSQL;
CREATE OR REPLACE FUNCTION fun_act_kardex(
    wid_producto tab_kardex.id_producto%TYPE,
    wcantidad tab_kardex.cantidad%TYPE,
    wtipo_movim tab_kardex.tipo_movim%TYPE,
    wind_tipomov tab_kardex.ind_tipomov%TYPE)
RETURNS VARCHAR AS 
$BODY$
DECLARE 
    wfecha_movim tab_kardex.fecha_movim%TYPE;
    wnext_id INTEGER;
BEGIN
   
    IF NOT EXISTS (SELECT 1 FROM tab_productos WHERE id_producto = wid_producto) THEN
        RETURN 'Error: El producto no existe.';
    END IF;

  
    IF wcantidad < 1 THEN 
        RETURN 'Error: La cantidad debe ser mayor a 0.';
    END IF;

    IF wtipo_movim IS TRUE 
        CASE wind_tipomov
        WHEN 1 THEN

        WHEN 2 THEN 
        WHEN 3 THEN 
    END CASE;
    ELSE
    END IF;
  
    wfecha_movim := CURRENT_TIMESTAMP;

  
    SELECT COALESCE(MAX(id_kardex), 0) + 1 INTO wnext_id FROM tab_kardex;






    IF wtipo_movim IS TRUE 

 
    INSERT INTO tab_kardex (id_kardex, id_producto, tipo_movim, fecha_movim, ind_tipomov, cantidad)
    VALUES (wnext_id, wid_producto, wtipo_movim, wfecha_movim, wind_tipomov, wcantidad);

    RETURN 'Inserción exitosa en el kardex.';
END;
$BODY$
LANGUAGE PLPGSQL;

-- SELECT fun_act_kardex(1,1,TRUE, 1);
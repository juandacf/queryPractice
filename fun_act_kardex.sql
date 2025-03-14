CREATE OR REPLACE FUNCTION fun_act_kardex(
wid_producto tab_kardex.id_producto%TYPE,
wcantidad tab_kardex.cantidad%TYPE,
wtipo_movim tab_kardex.tipo_movim%TYPE,
wind_tipomov tab_kardex.ind_tipomov%TYPE)
     RETURNS VARCHAR AS 
$BODY$
BEGIN
    SELECT a.id_producto INTO wid_producto FROM tab_productos a 
    WHERE a.id_producto = wid_producto;
    IF NOT FOUND OR wid_producto = NULL THEN 
        RETURN 'Dont be brutation.. Go back to elemtary school';
    ELSE 
        RAISE NOTICE 'Existe el producto %',wid_producto;
    END IF;


    INSERT INTO tab_kardex (SELECT COALESCE(MAX(id_kardex),0) +1 FROM tab_kardex,
                        wid_producto,
                        wtipo_movim,
                        wfecha_movim,
                        wind_tipomov
    );
    END;
$BODY$
LANGUAGE PLPGSQL;
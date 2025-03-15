--SELECT * FROM tab_kardex;
--SELECT fun_act_kardex(1,0,TRUE,1);
CREATE OR REPLACE FUNCTION fun_act_kardex(wid_producto tab_kardex.id_producto%TYPE,
                                          wcantidad tab_kardex.cantidad%TYPE,
                                          wtipo_movim tab_kardex.tipo_movim%TYPE,
                                          wind_tipomov tab_kardex.ind_tipomov%TYPE)
                                          RETURNS VARCHAR AS
$BODY$
	DECLARE wfecha_movim 		tab_kardex.fecha_movim%TYPE;
	DECLARE wtotal_existencias 	tab_productos.total_existencias%TYPE;
	BEGIN
        wfecha_movim = CURRENT_TIMESTAMP;

	    SELECT a.id_producto,a.total_existencias INTO wid_producto,wtotal_existencias FROM tab_productos a
		WHERE a.id_producto = wid_producto;
		IF NOT FOUND OR wid_producto = NULL THEN
        	RETURN 'Dont be brutation... Go back to elementary school';
    	ELSE
        	RAISE NOTICE 'Existe el producto %',wid_producto;
    	END IF;
		IF wcantidad < 1 THEN
			RETURN 'No hay cantidad en el producto.. Qué carajos le voy a sumar o restar???, tan toche';
		END IF;
		IF wtipo_movim IS TRUE THEN
			CASE wind_tipomov
				WHEN 1 THEN			
    				INSERT INTO tab_kardex VALUES((SELECT COALESCE(MAX(id_kardex),0) + 1 FROM tab_kardex),
													wid_producto,wtipo_movim,wfecha_movim,wind_tipomov,
													wcantidad);
					IF FOUND THEN
						wtotal_existencias = wtotal_existencias + wcantidad;
						UPDATE tab_productos SET total_existencias = wtotal_existencias
						WHERE id_producto = wid_producto;
						IF FOUND THEN
							RETURN 'Hemos terminado bien la vuelta con Entrada por Compra... Berraquitos';
						ELSE
							RETURN 'La Ca...';
						END IF;
					ELSE
						RETURN 'La Ca.. en la Inserción, revise bien calabazo...';
					END IF;
				WHEN 3 THEN
                    INSERT INTO tab_transito VALUES((SELECT COALESCE(MAX(id_entrada),0) + 1 FROM tab_transito),
													wid_producto,
                                                    wfecha_movim,
                                                    wcantidad);
                    IF FOUND THEN 
                        RETURN 'El producto está en la bodega de tránsito.. vamos bien..';
                    ELSE 
                        RETURN 'paila';
                    END  IF;
			END CASE;
		ELSE
-- ACÁ EVALUAREMOS LA SALIDA EN GENERAL
		END IF;
		END;
$BODY$
LANGUAGE PLPGSQL;
CREATE OR REPLACE FUNCTION fun_fact(wid_cliente tab_clientes.id_cliente%TYPE,
                                    wid_producto tab_productos.id_producto%TYPE,
                                    wcant tab_det_fact.val_cantidad%TYPE,
                                    wind_descto BOOLEAN,
                                    wind_forma_pago tab_enc_fact.ind_forma_pago%TYPE,
                                    wnum_caja tab_enc_fact.num_caja%TYPE) RETURNS BOOLEAN AS
$$
    DECLARE wnom_completo   VARCHAR;
    DECLARE wreg_pmtros     RECORD;
    DECLARE wreg_productos  RECORD;
    DECLARE wreg_clientes   RECORD;
    DECLARE wid_factura     tab_enc_fact.id_factura%TYPE;
    BEGIN
-- TRAEMOS LOS ATRIBUTOS DE PARÁMETROS PARA TENERLOS SIEMPRE PRESENTE EN LA FUNCIÓN PRINCIPAL
        SELECT a.id_empresa,a.nom_empresa,a.dir_empresa,a.val_poriva,a.val_pordesc,a.val_puntos,a.val_inifact,a.val_finfact,
               a.val_actfac,a.id_ciudad,b.nom_ciudad INTO wreg_pmtros FROM tab_pmtros a, tab_ciudades b
        WHERE a.id_ciudad = b.id_ciudad;

-- VALIDO EL CLIENTE. SI NO EXISTE HAY ERROR
        SELECT id_cliente,nom_cliente,ape_cliente,ind_estado INTO wreg_clientes FROM tab_clientes
        WHERE id_cliente = wid_cliente;
        IF FOUND THEN
            IF wreg_clientes.ind_estado IS FALSE THEN
                RAISE 'Ese cliente nos debe plata o es una rata... no le facturamos...';
                RETURN FALSE;
            END IF;
        ELSE
            SELECT id_cliente,nom_cliente,ape_cliente,ind_estado INTO wreg_clientes FROM tab_clientes
            WHERE id_cliente = 22222222;
            IF FOUND THEN
                wnom_completo = wreg_clientes.nom_cliente || ' ' || wreg_clientes.ape_cliente;
                RAISE NOTICE 'Nombre del Cliente es %',nombre_completo;
            ELSE
                RAISE NOTICE 'Hay un error grave.. eL CÓDIGO 22222222 NO EXISTE... Vaya BRUTO QUE SOS';
                RETURN FALSE;
            END IF;
        END IF;

-- VALIDAMOS EL PRODUCTO Y TODO LO REFERENTE A EL PARA FACTURAR
        SELECT id_producto,nombre_producto,val_venta,total_existencias INTO wreg_productos FROM tab_productos
        WHERE id_producto = wid_producto;
        IF FOUND THEN
            IF wcant <= wreg_productos.total_existencias THEN
-- ARMAR EL ENCABEZADO DE LA FACTURA
                IF wreg_pmtros.val_actfact >= wreg_pmtros.val_finfact THEN
                    RAISE NOTICE '¡¡ ALERTA... UYYYYY ÚLTIMA FACTURA !!, no podrá seguir facturando... Vaya a la DIAN';
                END IF;
                wid_factura = wreg_pmtros.val_actfact;
                wreg_pmtros.val_actfact = wreg.val_actfact + 1;
                UPDATE tab_pmtros SET val_actfact = wreg_pmtros.actfact;
                IF FOUND THEN
                    RAISE NOTICE 'Número de fact. % actualizada en Pmtros. Vamos bien, dijo el borracho',wreg_val_actfact;
                ELSE
                    RAISE NOTICE 'Se totió la vuelta al actualizar pmtros...';
                    RETURN FALSE;
                END IF;
-- INSERT INTO tab_enc_fact VALUES 
                INSERT INTO tab_enc_fact VALUES(wid_factura,CURRENT_DATE,CURRENT_TIME,wreg_clientes.id_cliente,
                                                wreg_pmtros.id_ciudad,wnum_caja,0,TRUE,TRUE);
                IF FOUND THEN
                    RAISE NOTICE 'Encabezado de la factura % para el cliente %-% y producto %-% quedó listo...',wid_factura,
                                 wreg_clientes.id_cliente,wnom_completo,wid_producto,wreg_productos.nombre_producto;
                ELSE
                    RAISE NOTICE 'ERROR armando el Encabezado de la factura. Vaya para la nocturna y aprenda.....';
                    RETURN FALSE;
                END IF;
            END IF;
        ELSE
            RAISE NOTICE 'El producto no existe... Mire a ver si hace funcionar esta vaina con más productos..';
            RETURN FALSE;
		END IF;
    END;
$$
LANGUAGE PLPGSQL;
-- HASTA ACÁ ES LA FUNCIÓN PRINCIPAL
--SELECT fun_listar_facturas();
--SELECT id_factura,id_producto,val_neto FROM tab_det_fact;
CREATE OR REPLACE FUNCTION fun_listar_facturas() RETURNS BOOLEAN AS
$$
    DECLARE wcur_enc    REFCURSOR;
    DECLARE wreg_enc    RECORD;
    DECLARE wcur_det    REFCURSOR;
    DECLARE wreg_det    RECORD;
    DECLARE wval_tot_b  tab_enc_fact.val_tot_fact%TYPE;
    DECLARE wval_tot_n  tab_enc_fact.val_tot_fact%TYPE;
    DECLARE wsum_fac_b  tab_enc_fact.val_tot_fact%TYPE;
    DECLARE wsum_fac_n  tab_enc_fact.val_tot_fact%TYPE;
    DECLARE wq_enc      VARCHAR;
    DECLARE wq_det      TEXT;
    DECLARE wnom_cli    VARCHAR;
    BEGIN
        wval_tot_b = 0;
        wval_tot_n = 0;
        wsum_fac_b = 0;
        wsum_fac_n = 0;

        wq_enc = 'SELECT a.id_factura,a.fec_factura,a.val_hora_fact,a.id_cliente,b.nom_cliente,b.ape_cliente,
                         b.tel_cliente,a.id_ciudad FROM tab_enc_fact a, tab_clientes b
                  WHERE a.id_cliente = b.id_cliente';
-- INICIA EL PROCESO DEL CURSOR DE DETALLE DE FATURAS
        OPEN wcur_enc FOR EXECUTE wq_enc;
            FETCH wcur_enc INTO wreg_enc;
            WHILE FOUND LOOP
                wnom_cli = wreg_enc.nom_cliente || ' ' || wreg_enc.ape_cliente;
                RAISE NOTICE 'Factura No. % del cliente %',wreg_enc.id_factura,wnom_cli;
-- INICIA EL PROCESO DEL CURSOR DE DETALLE DE FATURAS
				wq_det = 'SELECT a.id_factura,a.id_producto,b.nombre_producto,a.val_cantidad,a.val_descuento,a.val_iva,
                                 a.val_bruto,a.val_neto FROM tab_det_fact a, tab_productos b
                          WHERE a.id_factura = '|| QUOTE_LITERAL(wreg_enc.id_factura) ||' AND a.id_producto = b.id_producto';
                OPEN wcur_det FOR EXECUTE wq_det;
                    FETCH wcur_det INTO wreg_det;
                    WHILE FOUND LOOP
                        wsum_fac_b = wsum_fac_b + wreg_det.val_bruto;
                        wsum_fac_n = wsum_fac_n + wreg_det.val_neto;
                        RAISE NOTICE '     Producto: % - Cantidad: % - descuento: % - Iva: % - V_Bruto: % - V_Neto: %',
                                    wreg_det.nombre_producto,wreg_det.val_cantidad,wreg_det.val_descuento,wreg_det.val_iva,
                                    wreg_det.val_bruto,wreg_det.val_neto;
                        FETCH wcur_det INTO wreg_det;
                    END LOOP;
                CLOSE wcur_det;
                RAISE NOTICE '                                                                   T_Bruto: % - T_Neto: %',wsum_fac_b,wsum_fac_n;
                wsum_fac_b = 0;
                wsum_fac_n = 0;
-- INICIA TERMINA EL PROCESO DEL CURSOR DE DETALLE DE FATURAS
                FETCH wcur_enc INTO wreg_enc;
            END LOOP;
        CLOSE wcur_enc;
		RETURN TRUE;
    END;
$$
LANGUAGE PLPGSQL;
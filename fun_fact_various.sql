CREATE OR REPLACE FUNCTION new_fun_fact(
                                    wid_cliente tab_clientes.id_cliente%TYPE,
                                    wid_producto INTEGER[],
                                    wcant INTEGER[],
                                    wind_descto BOOLEAN,
                                    wind_forma_pago tab_enc_fact.ind_forma_pago%TYPE,
                                    wnum_caja tab_enc_fact.num_caja%TYPE
) RETURNS BOOLEAN AS 


$$
BEGIN
    DECLARE wnom_completo   VARCHAR;
    DECLARE wreg_pmtros     RECORD;
    DECLARE wreg_productos  RECORD;
    DECLARE wreg_clientes   RECORD;
    DECLARE wid_factura     tab_enc_fact.id_factura%TYPE;
    DECLARE wproduct_length  INTEGER;

wproduct_length:= cardinality(wid_producto);
END;
$$
LANGUAGE PLPGSQL;
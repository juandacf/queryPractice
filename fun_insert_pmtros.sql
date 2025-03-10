CREATE OR REPLACE FUNCTION fun_insert_pmtros(wid_empresa tab_pmtros.id_empresa%TYPE,
											 wnom_empresa  tab_pmtros.nom_empresa%TYPE,
											 wval_ivarefu tab_pmtros.val_ivarefu%TYPE,
											 wval_iva_car tab_pmtros.val_iva_car%TYPE,
											 wval_iva_otro tab_pmtros.val_iva_otro%TYPE,
											 wval_descuento tab_pmtros.val_descuento%TYPE,
											 wval_puntos tab_pmtros.val_puntos%TYPE) RETURNS VARCHAR AS 

$$
	BEGIN
		INSERT INTO tab_pmtros VALUES (wid_empresa,wnom_empresa,wval_ivarefu, wval_iva_car, wval_iva_otro, wval_descuento,wval_puntos );
	END;
$$
LANGUAGE PLPGSQL;
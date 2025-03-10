CREATE OR REPLACE FUNCTION fun_insert_pmtros(wid_empresa tab_pmtros.id_empresa%TYPE,
											 wnom_empresa  tab_pmtros.nom_empresa%TYPE,
											 wval_ivarefu tab_pmtros.val_ivarefu%TYPE,
											 wval_iva_car tab_pmtros.val_iva_car%TYPE,
											 wval_iva_otro tab_pmtros.val_iva_otro%TYPE,
											 wval_descuento tab_pmtros.val_descuento%TYPE,
											 wval_puntos tab_pmtros.val_puntos%TYPE) RETURNS VARCHAR AS 

$$
	BEGIN
		IF (SELECT id_empresa FROM tab_pmtros WHERE id_empresa = wid_empresa ) IS NULL THEN

		INSERT INTO tab_pmtros VALUES (wid_empresa,wnom_empresa,wval_ivarefu, wval_iva_car, wval_iva_otro, wval_descuento,wval_puntos );

		ELSE 
						UPDATE tab_pmtros SET 
			nom_empresa = wnom_empresa,
			val_ivarefu = wval_ivarefu,
			val_iva_car = wval_iva_car,
			val_iva_otro = wval_iva_otro,
			val_descuento = wval_descuento, 
			val_puntos = wval_puntos

			WHERE tab_pmtros.id_empresa = wid_empresa;
		END IF;
		RETURN 'hola';
	END;
$$
LANGUAGE PLPGSQL;

SELECT fun_insert_pmtros (1007669080, 'juanSAS', 19,29,0,10,5000);
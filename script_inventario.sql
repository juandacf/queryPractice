DROP TABLE IF EXISTS tab_det_fact;
DROP TABLE IF EXISTS tab_enc_fact;
DROP TABLE IF EXISTS tab_clientes;
DROP TABLE IF EXISTS tab_transito;
DROP TABLE IF EXISTS tab_kardex;
DROP TABLE IF EXISTS tab_productos_proveedores;
DROP TABLE IF EXISTS tab_productos;
DROP TABLE IF EXISTS tab_proveedores;
DROP TABLE IF EXISTS tab_marcas;
DROP TABLE IF EXISTS tab_subcategorias_3;
DROP TABLE IF EXISTS tab_subcategorias_2;
DROP TABLE IF EXISTS tab_categorias;
DROP TABLE IF EXISTS tab_unidades_medida;
DROP TABLE IF EXISTS tab_pmtros;
DROP TABLE IF EXISTS tab_ciudades;

CREATE TABLE IF NOT EXISTS tab_ciudades
(
    id_ciudad       DECIMAL(4)      NOT NULL,
    nom_ciudad      VARCHAR         NOT NULL,
    PRIMARY KEY(id_ciudad)
);
INSERT INTO tab_ciudades VALUES(1,'Bogotá D.C.');

CREATE TABLE IF NOT EXISTS tab_pmtros
(
    id_empresa      DECIMAL(10,0)   NOT NULL,
    nom_empresa     VARCHAR         NOT NULL,
    dir_empresa     VARCHAR         NOT NULL,
    tel_empresa     DECIMAL(10)     NOT NULL,
    val_poriva      DECIMAL(2,0)    NOT NULL    DEFAULT 19,
    val_pordesc     DECIMAL(3,0)    NOT NULL    CHECK (val_pordesc >= 0 AND val_pordesc <= 100),
    val_puntos      DECIMAL(3,0)    NOT NULL    DEFAULT 10,
    val_inifact     DECIMAL(12)     NOT NULL    CHECK(val_inifact >= 1 AND val_inifact <= val_finfact),
    val_finfact     DECIMAL(12)     NOT NULL    CHECK(val_finfact >= val_inifact),
    val_actfact     DECIMAL(12)     NOT NULL    CHECK (val_actfact >= val_inifact AND val_actfact <= val_finfact),
    id_ciudad       DECIMAL(4)      NOT NULL,
    val_observa     TEXT            NOT NULL,
    PRIMARY KEY(id_empresa),
    FOREIGN KEY(id_ciudad)  REFERENCES tab_ciudades(id_ciudad)
);
INSERT INTO tab_pmtros VALUES(222222222,'Cosita Rica, mamá','Cra. 27 # 15-08',6076800600,19,10,10,5000,6000,5000,1,
                              'Este en un documento valor. Si no se paga nos mandan a la cana... Así que a pagar, RATA');

CREATE TABLE IF NOT EXISTS tab_unidades_medida
(
    id_unidad_medida     DECIMAL(12)    PRIMARY KEY,
    nombre_unidad_medida VARCHAR        NOT NULL UNIQUE,
    estado               BOOLEAN        DEFAULT TRUE NOT NULL
);

CREATE TABLE IF NOT EXISTS tab_categorias
(
    id_categoria         DECIMAL(12)    NOT NULL,
    nombre_categoria     VARCHAR        NOT NULL UNIQUE,
    estado_categoria     BOOLEAN        DEFAULT TRUE NOT NULL,
    PRIMARY KEY (id_categoria)
);

CREATE TABLE IF NOT EXISTS tab_subcategorias_2
(
    id_categoria          DECIMAL(12)    NOT NULL,
    id_subcategoria_2     DECIMAL(12)    NOT NULL,
    nombre_subcategoria_2 VARCHAR        NOT NULL UNIQUE,
    estado_subcategoria_2 BOOLEAN        DEFAULT TRUE NOT NULL,
    PRIMARY KEY (id_categoria, id_subcategoria_2),
    FOREIGN KEY (id_categoria) REFERENCES tab_categorias(id_categoria)
);

CREATE TABLE IF NOT EXISTS tab_subcategorias_3
(
    id_categoria          DECIMAL(12)    NOT NULL,
    id_subcategoria_2     DECIMAL(12)    NOT NULL,
    id_subcategoria_3     DECIMAL(12)    NOT NULL,
    nombre_subcategoria_3 VARCHAR        NOT NULL UNIQUE,
    estado_subcategoria_3 BOOLEAN        DEFAULT TRUE NOT NULL,
    PRIMARY KEY (id_categoria, id_subcategoria_2, id_subcategoria_3),
    FOREIGN KEY (id_categoria) REFERENCES tab_categorias(id_categoria),
    FOREIGN KEY (id_categoria, id_subcategoria_2) REFERENCES tab_subcategorias_2(id_categoria, id_subcategoria_2)
);

CREATE TABLE IF NOT EXISTS tab_marcas
(
    id_marca             DECIMAL(12)    PRIMARY KEY,
    nombre_marca         VARCHAR        NOT NULL UNIQUE,
    estado_marca         BOOLEAN        DEFAULT TRUE NOT NULL
);

CREATE TABLE IF NOT EXISTS tab_proveedores
(
    id_proveedor         DECIMAL(12)    PRIMARY KEY,
    nombre_proveedor     VARCHAR        NOT NULL UNIQUE,
    estado_proveedor     BOOLEAN        DEFAULT TRUE NOT NULL
);

CREATE TABLE IF NOT EXISTS tab_productos 
(
    id_producto           DECIMAL(12)    NOT NULL,
    id_categoria          DECIMAL(12)    NOT NULL,
    id_subcategorias_2    DECIMAL(12),
    id_subcategorias_3    DECIMAL(12),
    nombre_producto       VARCHAR        NOT NULL CHECK(LENGTH(nombre_producto) >= 2),
    costo_unitario        DECIMAL(10)    NOT NULL CHECK(costo_unitario >= 0),
    fecha_caducidad       DATE           CHECK(fecha_caducidad >= CURRENT_DATE),
    stock_maximo          INT            NOT NULL CHECK(stock_maximo >= stock_minimo),
    stock_minimo          INT            NOT NULL CHECK(stock_minimo <= stock_maximo),
    punto_reorden         INT            NOT NULL CHECK (punto_reorden > stock_minimo AND punto_reorden < stock_maximo),
    presentacion          VARCHAR,
    valor_unidad_medida   DECIMAL(10,2),
    direccion_imagen      VARCHAR,
    estado                BOOLEAN        DEFAULT TRUE NOT NULL,
    id_marca              DECIMAL(12)    NOT NULL,
    id_unidad_medida      DECIMAL(12)    NOT NULL,
    total_existencias     INT            NOT NULL,
    val_venta             DECIMAL(10)    NOT NULL GENERATED ALWAYS AS (costo_unitario * 1.5) STORED,
    PRIMARY KEY (id_producto),
    FOREIGN KEY (id_marca) REFERENCES tab_marcas(id_marca),
    FOREIGN KEY (id_categoria, id_subcategorias_2, id_subcategorias_3) REFERENCES tab_subcategorias_3(id_categoria, id_subcategoria_2, id_subcategoria_3),
    FOREIGN KEY (id_unidad_medida) REFERENCES tab_unidades_medida(id_unidad_medida)
);
CREATE UNIQUE INDEX idx_nom_prod ON tab_productos(nombre_producto);

CREATE TABLE IF NOT EXISTS tab_productos_proveedores
(
    id_proveedor          DECIMAL(12)    NOT NULL,
    id_producto           DECIMAL(12)    NOT NULL,
    PRIMARY KEY (id_proveedor, id_producto),
    FOREIGN KEY (id_proveedor) REFERENCES tab_proveedores(id_proveedor),
    FOREIGN KEY (id_producto) REFERENCES tab_productos(id_producto)
);

CREATE TABLE IF NOT EXISTS tab_kardex
(
    id_kardex        DECIMAL(12),
    id_producto      DECIMAL(12)    NOT NULL,
    tipo_movim       BOOLEAN        NOT NULL, -- TRUE=ENTRADA / FALSE=SALIDA,
    fecha_movim      TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    ind_tipomov      DECIMAL(1)     NOT NULL CHECK(ind_tipomov >= 1 AND ind_tipomov <= 9),
-- CONCEPTO PUEDE SER:  1:Entrada por Compra
--                      2:Salida por venta
--                      3:Entrada devolución por daño de cliente
--                      4:Entrada por devolución cambio
--                      5:Salida por devolución daño a Proveedor
--                      6:Salida por devolución cambio
    cantidad         DECIMAL(4)     NOT NULL CHECK(cantidad>= 1 AND cantidad <= 9999),
    PRIMARY KEY(id_kardex),
    FOREIGN KEY (id_producto) REFERENCES tab_productos(id_producto)
);
CREATE INDEX idx_tipo_movim  ON tab_kardex(tipo_movim);
CREATE INDEX idx_ind_tipomov ON tab_kardex(ind_tipomov);
CREATE INDEX idx_fecha_movim ON tab_kardex(fecha_movim);

CREATE TABLE tab_transito
(
    id_entrada      DECIMAL(12)     NOT NULL,
    id_producto     DECIMAL(12)     NOT NULL,
    fec_entrada     TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    val_entrada     DECIMAL(4)      NOT NULL,
    PRIMARY KEY(id_entrada),
    FOREIGN KEY(id_producto) REFERENCES tab_productos(id_producto)
);

CREATE TABLE IF NOT EXISTS tab_clientes
(
    id_cliente      DECIMAL(12)     NOT NULL,
    nom_cliente     VARCHAR         NOT NULL,
    ape_cliente     VARCHAR         NOT NULL,
    dir_cliente     VARCHAR         NOT NULL,
    tel_cliente     DECIMAL(10)     NOT NULL,
    val_puntos      DECIMAL(6)      NOT NULL,
    ind_estado      BOOLEAN         NOT NULL DEFAULT TRUE,
    PRIMARY KEY(id_cliente)
);
INSERT INTO tab_clientes VALUES(22222222,'Cliente','Genérico','Calle 2 carrera 2',3111111111,0,TRUE);

CREATE TABLE IF NOT EXISTS tab_enc_fact
(
    id_factura      DECIMAL(7,0)    NOT NULL CHECK(id_factura >= 1),
    fec_factura     DATE            NOT NULL,
    val_hora_fact   TIME WITHOUT TIME ZONE NOT NULL,
    id_cliente      DECIMAL(12)     NOT NULL,
    id_ciudad       DECIMAL(4)      NOT NULL,
    num_caja        DECIMAL(2)      NOT NULL,
    val_tot_fact    DECIMAL(8)      NOT NULL,
    ind_estado      BOOLEAN         NOT NULL,
    ind_forma_pago  BOOLEAN         NOT NULL,
    PRIMARY KEY(id_factura),
    FOREIGN KEY(id_cliente) REFERENCES tab_clientes(id_cliente),
    FOREIGN KEY(id_ciudad)  REFERENCES tab_ciudades(id_ciudad)
);

CREATE TABLE IF NOT EXISTS tab_det_fact
(
    id_factura      DECIMAL(7,0)    NOT NULL CHECK(id_factura >= 1),
    id_producto     DECIMAL(12)     NOT NULL,
    val_cantidad    DECIMAL(3)      NOT NULL CHECK(val_cantidad >=1),
    val_descuento   DECIMAL(6)      NOT NULL,
    val_iva         DECIMAL(6,0)    NOT NULL,
    val_bruto       DECIMAL(12)     NOT NULL,
    val_neto        DECIMAL(12)     NOT NULL,
	PRIMARY KEY(id_factura,id_producto),
    FOREIGN KEY(id_factura)  REFERENCES tab_enc_fact(id_factura),
    FOREIGN KEY(id_producto) REFERENCES tab_productos(id_producto)
);

-- Inserciones sin el campo stock_actual
INSERT INTO tab_unidades_medida (id_unidad_medida, nombre_unidad_medida) VALUES
(1, 'Kilogramo'),
(2, 'Litro'),
(3, 'Gramo'),
(4, 'Mililitro'),
(5, 'Paquete'),
(6, 'Unidad'),
(7, 'Tamaño'),
(8, 'Botella'),
(9, 'Caja'),
(10, 'Lata'),
(11, 'Paquete de 20'),
(12, 'Paquete de 12'),
(13, 'Taza'),
(14, 'Cucharada'),
(15, 'Cucharadita');

INSERT INTO tab_categorias (id_categoria, nombre_categoria) VALUES
(1, 'Lácteos'),
(2, 'Bebidas'),
(3, 'Cereales y Granos'),
(4, 'Alimentos'),
(5, 'Snacks'),
(6, 'Aceites'),
(7, 'Productos de Higiene'),
(8, 'Limpieza'),
(9, 'Café'),
(10, 'Chocolates');

INSERT INTO tab_subcategorias_2 (id_categoria, id_subcategoria_2, nombre_subcategoria_2) VALUES
(1, 1, 'Leche Entera'),
(1, 2, 'Leche Descremada'),
(1, 3, 'Yogur Natural'),
(1, 4, 'Yogur de Frutas'),
(1, 5, 'Queso Fresco'),
(1, 6, 'Queso Duro'),
(2, 7, 'Gaseosas'),
(2, 8, 'Tés'),
(3, 9, 'Arroz Blanco'),
(3, 10, 'Arroz Integral'),
(3, 11, 'Frijoles Negros'),
(3, 12, 'Frijoles Rojos'),
(3, 13, 'Harina de Trigo'),
(3, 14, 'Harina de Maíz'),
(4, 15, 'Salsas de Tomate'),
(4, 16, 'Salsas Picantes'),
(5, 17, 'Galletas Saladas'),
(5, 18, 'Galletas Dulces'),
(6, 19, 'Aceite de Girasol'),
(6, 20, 'Aceite de Oliva'),
(7, 21, 'Pañales Desechables'),
(7, 22, 'Pañales Ecológicos'),
(7, 23, 'Toallas Always'),
(7, 24, 'Toallas Ultra'),
(8, 25, 'Limpiadores Multiusos'),
(8, 26, 'Limpiadores de Baño'),
(9, 27, 'Café Instantáneo'),
(9, 28, 'Café Molido'),
(10, 29, 'Chocolate Jet'),
(10, 30, 'Chocolate Jet con Almendras');

INSERT INTO tab_subcategorias_3 (id_categoria, id_subcategoria_2, id_subcategoria_3, nombre_subcategoria_3) VALUES
(1, 1, 1, 'Leche Entera Pasteurizada'),
(1, 1, 2, 'Leche Entera UHT'),
(1, 3, 3, 'Yogur Natural Sin Azúcar'),
(1, 3, 4, 'Yogur Natural Endulzado'),
(1, 5, 5, 'Queso Fresco Campesino'),
(1, 5, 6, 'Queso Fresco Light'),
(2, 7, 7, 'Gaseosa Regular'),
(2, 7, 8, 'Gaseosa Sin Azúcar'),
(2, 8, 9, 'Té Frío Saborizado'),
(2, 8, 10, 'Té Frío Natural'),
(2, 7, 11, 'Jugo Saborizado'),
(2, 7, 12, 'Cerveza Clásica'),
(2, 7, 13, 'Cerveza Light'),
(2, 7, 14, 'Cerveza Radler'),
(3, 9, 11, 'Arroz Blanco Premium'),
(3, 9, 12, 'Arroz Blanco Estándar'),
(3, 10, 13, 'Arroz Integral Orgánico'),
(3, 11, 14, 'Frijoles Negros de Exportación'),
(3, 12, 15, 'Frijoles Rojos Tradicionales'),
(3, 13, 16, 'Harina de Trigo Refinada'),
(3, 14, 17, 'Harina de Maíz Precocida'),
(4, 15, 18, 'Salsa de Tomate Clásica'),
(4, 16, 19, 'Salsa Picante Suave'),
(4, 15, 20, 'Sopa en Polvo'),
(4, 15, 21, 'Caldo Concentrado'),
(4, 15, 22, 'Sazonador en Polvo'),
(5, 17, 20, 'Galletas Saladas Clásicas'),
(5, 18, 21, 'Galletas Dulces con Chocolate'),
(5, 18, 22, 'Galletas Dulces Rellenas'),
(5, 17, 23, 'Bolsas de Snack'),
(6, 19, 23, 'Aceite de Girasol Refinado'),
(6, 20, 24, 'Aceite de Maíz Premium'),
(7, 21, 25, 'Pañales Desechables Tamaño 4'),
(7, 21, 26, 'Pañales Desechables Tamaño 5'),
(7, 22, 27, 'Pañales Ecológicos Tamaño 4'),
(7, 23, 28, 'Toallas Always Diurnas'),
(7, 24, 29, 'Toallas Ultra Nocturnas'),
(7, 21, 34, 'Jabón en Barra'),
(7, 21, 35, 'Crema Hidratante'),
(7, 21, 36, 'Gel Limpiador'),
(8, 25, 30, 'Limpiador Multiusos Floral'),
(9, 28, 31, 'Café Molido Tostado'),
(10, 29, 32, 'Chocolate Jet Clásico'),
(10, 30, 33, 'Chocolate Jet con Almendras');

INSERT INTO tab_marcas (id_marca, nombre_marca) VALUES
(1, 'Colanta'),
(2, 'Alquería'),
(3, 'Alpina'),
(4, 'Coca-Cola'),
(5, 'Postobón'),
(6, 'Águila'),
(7, 'Arroz Diana'),
(8, 'Harina Pan'),
(9, 'Frijoles La Fama'),
(10, 'Fruco'),
(11, 'Maggi'),
(12, 'Knorr'),
(13, 'Saltín Noel'),
(14, 'Galletas Dux'),
(15, 'Ramo'),
(16, 'Aceite de Girasol'),
(17, 'Aceite de Maíz'),
(18, 'Familia'),
(19, 'Pampers'),
(20, 'Always'),
(21, 'Asepxia'),
(22, 'Fabuloso'),
(23, 'Café Sello Rojo'),
(24, 'Chocolates Jet');

INSERT INTO tab_proveedores (id_proveedor, nombre_proveedor) VALUES
(1, 'Proveedores Colanta S.A.S.'),
(2, 'Distribuciones Alquería Ltda.'),
(3, 'Alpina Alimentos S.A.'),
(4, 'Coca-Cola Femsa'),
(5, 'Postobón S.A.'),
(6, 'Cervecería Águila S.A.'),
(7, 'Arroz Diana S.A.S.'),
(8, 'Harinas Pan S.A.S.'),
(9, 'Frijoles La Fama S.A.S.'),
(10, 'Salsas Fruco S.A.S.'),
(11, 'Maggi Colombia S.A.S.'),
(12, 'Knorr S.A.S.'),
(13, 'Galletas Saltín Noel S.A.S.'),
(14, 'Galletas Dux S.A.S.'),
(15, 'Ramo S.A.S.'),
(16, 'Aceites de Girasol S.A.S.'),
(17, 'Aceites de Maíz S.A.S.'),
(18, 'Familia S.A.S.'),
(19, 'Proveedores Pampers S.A.S.'),
(20, 'Always S.A.S.'),
(21, 'Asepxia S.A.S.'),
(22, 'Fabuloso S.A.S.'),
(23, 'Café Sello Rojo S.A.S.'),
(24, 'Chocolates Jet S.A.S.'),
(25, 'Distribuciones Multimarca S.A.S.'),
(26, 'Alimentos y Bebidas S.A.S.'),
(27, 'Grupo de Proveedores S.A.S.'),
(28, 'Comercializadora de Alimentos S.A.S.'),
(29, 'Proveedores de Productos de Consumo S.A.S.'),
(30, 'Alianzas Comerciales S.A.S.');

INSERT INTO tab_productos VALUES
(1, 1, 1, 1, 'Leche Colanta', 2.50, '2025-12-31', 100, 20, 30, '1L', 2.50, 'ruta/a/imagen/leche_colanta.jpg', TRUE, 1, 2, 100),
(2, 1, 3, 3, 'Yogur Colanta', 1.80, '2025-06-30', 80, 15, 25, '1L', 1.80, 'ruta/a/imagen/yogur_colanta.jpg', TRUE, 1, 2, 20),
(3, 1, 5, 5, 'Queso Colanta', 3.00, '2025-05-15', 50, 10, 15, '500g', 6.00, 'ruta/a/imagen/queso_colanta.jpg', TRUE, 1, 3, 80),
(4, 1, 1, 1, 'Leche Alquería', 2.50, '2025-12-31', 100, 20, 30, '1L', 2.50, 'ruta/a/imagen/leche_alqueria.jpg', TRUE, 2, 2, 160),
(5, 1, 3, 3, 'Yogur Alquería', 1.80, '2025-06-30', 80, 15, 25, '1L', 1.80, 'ruta/a/imagen/yogur_alqueria.jpg', TRUE, 2, 2, 140),
(6, 1, 5, 5, 'Queso Alquería', 3.00, '2025-05-15', 50, 10, 15, '500g', 6.00, 'ruta/a/imagen/queso_alqueria.jpg', TRUE, 2, 3, 20),
(7, 1, 1, 1, 'Leche Alpina', 2.50, '2025-12-31', 100, 20, 30, '1L', 2.50, 'ruta/a/imagen/leche_alpina.jpg', TRUE, 3, 2, 0),
(8, 1, 3, 3, 'Yogur Alpina', 1.80, '2025-06-30', 80, 15, 25, '1L', 1.80, 'ruta/a/imagen/yogur_alpina.jpg', TRUE, 3, 2, 50),
(9, 1, 5, 5, 'Queso Alpina', 3.00, '2025-05-15', 50, 10, 15, '500g', 6.00, 'ruta/a/imagen/queso_alpina.jpg', TRUE, 3, 3, 60),
(10, 2, 7, 7, 'Coca-Cola', 1.50, '2026-01-01', 200, 50, 75, '1.5L', 1.50, 'ruta/a/imagen/coca_cola.jpg', TRUE, 4, 2, 100),
(11, 2, 7, 8, 'Coca-Cola Zero', 1.50, '2026-01-01', 200, 50, 75, '1.5L', 1.50, 'ruta/a/imagen/coca_cola_zero.jpg', TRUE, 4, 2, 70),
(12, 2, 7, 8, 'Coca-Cola Light', 1.50, '2026-01-01', 200, 50, 75, '1.5L', 1.50, 'ruta/a/imagen/coca_cola_light.jpg', TRUE, 4, 2, 50),
(13, 2, 7, 11, 'Jugo Postobón', 1.20, '2025-11-30', 150, 30, 50, '1L', 1.20, 'ruta/a/imagen/jugo_postobon.jpg', TRUE, 5, 2, 190),
(14, 2, 7, 7, 'Gaseosa Postobón', 1.50, '2026-01-01', 200, 50, 75, '1.5L', 1.50, 'ruta/a/imagen/gaseosa_postobon.jpg', TRUE, 5, 2, 220),
(15, 2, 8, 9, 'Té Postobón', 1.00, '2025-12-31', 100, 20, 30, '1L', 1.00, 'ruta/a/imagen/te_postobon.jpg', TRUE, 5, 2, 70),
(16, 2, 7, 12, 'Cerveza Águila', 1.80, '2026-03-01', 100, 20, 30, '330ml', 1.80, 'ruta/a/imagen/cerveza_aguila.jpg', TRUE, 6, 4, 120),
(17, 2, 7, 13, 'Cerveza Águila Light', 1.80, '2026-03-01', 100, 20, 30, '330ml', 1.80, 'ruta/a/imagen/cerveza_aguila_light.jpg', TRUE, 6, 4, 10),
(18, 2, 7, 14, 'Cerveza Águila Radler', 1.80, '2026-03-01', 100, 20, 30, '330ml', 1.80, 'ruta/a/imagen/cerveza_aguila_radler.jpg', TRUE, 6, 4, 70),
(19, 3, 9, 11, 'Arroz Diana', 1.00, '2026-12-31', 300, 100, 150, '1kg', 1.00, 'ruta/a/imagen/arroz_diana.jpg', TRUE, 7, 1, 300),
(20, 3, 10, 13, 'Arroz Diana Integral', 1.20, '2026-12-31', 300, 100, 150, '1kg', 1.20, 'ruta/a/imagen/arroz_diana_integral.jpg', TRUE, 7, 1, 120),
(21, 3, 9, 12, 'Arroz Diana Extra', 1.50, '2026-12-31', 300, 100, 150, '1kg', 1.50, 'ruta/a/imagen/arroz_diana_extra.jpg', TRUE, 7, 1, 100),
(22, 3, 13, 16, 'Harina Pan', 1.50, '2026-06-30', 150, 50, 75, '1kg', 1.50, 'ruta/a/imagen/harina_pan.jpg', TRUE, 8, 1, 130),
(23, 3, 14, 17, 'Harina Pan Integral', 1.70, '2026-06-30', 150, 50, 75, '1kg', 1.70, 'ruta/a/imagen/harina_pan_integral.jpg', TRUE, 8, 1, 70),
(24, 3, 14, 17, 'Harina Pan Premezclada', 1.60, '2026-06-30', 150, 50, 75, '1kg', 1.60, 'ruta/a/imagen/harina_pan_premezclada.jpg', TRUE, 8, 1, 80),
(25, 3, 12, 15, 'Frijoles La Fama', 1.20, '2026-01-01', 200, 50, 75, '1kg', 1.20, 'ruta/a/imagen/frijoles_la_fama.jpg', TRUE, 9, 1, 30),
(26, 3, 11, 14, 'Frijoles La Fama Negros', 1.30, '2026-01-01', 200, 50, 75, '1kg', 1.30, 'ruta/a/imagen/frijoles_la_fama_negros.jpg', TRUE, 9, 1, 100),
(27, 3, 12, 15, 'Frijoles La Fama Rojos', 1.25, '2026-01-01', 200, 50, 75, '1kg', 1.25, 'ruta/a/imagen/frijoles_la_fama_rojos.jpg', TRUE, 9, 1, 100),
(28, 4, 15, 18, 'Salsa Fruco', 1.00, '2026-12-31', 150, 30, 50, '500g', 2.00, 'ruta/a/imagen/salsa_fruco.jpg', TRUE, 10, 3, 60),
(29, 4, 16, 19, 'Salsa Fruco Picante', 1.20, '2026-12-31', 150, 30, 50, '500g', 2.20, 'ruta/a/imagen/salsa_fruco_picante.jpg', TRUE, 10, 3, 60),
(30, 4, 15, 18, 'Salsa Fruco de Ajo', 1.10, '2026-12-31', 150, 30, 50, '500g', 2.10, 'ruta/a/imagen/salsa_fruco_ajo.jpg', TRUE, 10, 3, 60),
(31, 4, 15, 20, 'Sopa Maggi', 0.80, '2026-11-30', 100, 20, 30, '100g', 0.80, 'ruta/a/imagen/sopa_maggi.jpg', TRUE, 11, 3, 40),
(32, 4, 15, 21, 'Caldo Maggi', 1.00, '2026-11-30', 100, 20, 30, '100g', 1.00, 'ruta/a/imagen/caldo_maggi.jpg', TRUE, 11, 3, 40),
(33, 4, 15, 22, 'Sazonador Maggi', 1.20, '2026-11-30', 100, 20, 30, '100g', 1.20, 'ruta/a/imagen/sazonador_maggi.jpg', TRUE, 11, 3, 40),
(34, 4, 15, 21, 'Caldo Knorr', 1.00, '2026-11-30', 100, 20, 30, '100g', 1.00, 'ruta/a/imagen/caldo_knorr.jpg', TRUE, 12, 3, 40),
(35, 4, 15, 22, 'Sazonador Knorr', 1.20, '2026-11-30', 100, 20, 30, '100g', 1.20, 'ruta/a/imagen/sazonador_knorr.jpg', TRUE, 12, 3, 40),
(36, 4, 15, 20, 'Sopa Knorr', 0.90, '2026-11-30', 100, 20, 30, '100g', 0.90, 'ruta/a/imagen/sopa_knorr.jpg', TRUE, 12, 3, 40),
(37, 5, 17, 20, 'Galletas Saltín Noel', 1.50, '2026-10-15', 200, 50, 75, '200g', 7.50, 'ruta/a/imagen/galletas_saltin_noel.jpg', TRUE, 13, 3, 100),
(38, 5, 17, 20, 'Galletas Saltín Noel Integral', 1.70, '2026-10-15', 200, 50, 75, '200g', 7.70, 'ruta/a/imagen/galletas_saltin_noel_integral.jpg', TRUE, 13, 3, 100),
(39, 5, 18, 21, 'Galletas Saltín Noel con Chocolate', 1.80, '2026-10-15', 200, 50, 75, '200g', 7.80, 'ruta/a/imagen/galletas_saltin_noel_chocolate.jpg', TRUE, 13, 3, 100),
(40, 5, 18, 21, 'Galletas Dux', 1.70, '2026-09-30', 150, 30, 50, '150g', 11.33, 'ruta/a/imagen/galletas_dux.jpg', TRUE, 14, 3, 80),
(41, 5, 18, 21, 'Galletas Dux de Chocolate', 1.90, '2026-09-30', 150, 30, 50, '150g', 12.00, 'ruta/a/imagen/galletas_dux_chocolate.jpg', TRUE, 14, 3, 80),
(42, 5, 18, 22, 'Galletas Dux Rellenas', 2.00, '2026-09-30', 150, 30, 50, '150g', 12.50, 'ruta/a/imagen/galletas_dux_rellenas.jpg', TRUE, 14, 3, 80),
(43, 5, 17, 23, 'Bolsas Ramo', 2.00, '2026-12-31', 100, 20, 30, '1kg', 2.00, 'ruta/a/imagen/bolsas_ramo.jpg', TRUE, 15, 1, 50),
(44, 5, 17, 23, 'Bolsas Ramo Ecológicas', 2.50, '2026-12-31', 100, 20, 30, '1kg', 2.50, 'ruta/a/imagen/bolsas_ramo_ecologicas.jpg', TRUE, 15, 1, 50),
(45, 5, 17, 23, 'Bolsas Ramo Reutilizables', 3.00, '2026-12-31', 100, 20, 30, '1kg', 3.00, 'ruta/a/imagen/bolsas_ramo_reutilizables.jpg', TRUE, 15, 1, 50),
(46, 6, 19, 23, 'Aceite de Girasol', 3.50, '2026-05-15', 200, 50, 75, '1L', 3.50, 'ruta/a/imagen/aceite_girasol.jpg', TRUE, 16, 2, 100),
(47, 6, 19, 23, 'Aceite de Girasol Orgánico', 4.00, '2026-05-15', 200, 50, 75, '1L', 4.00, 'ruta/a/imagen/aceite_girasol_organico.jpg', TRUE, 16, 2, 100),
(48, 6, 19, 23, 'Aceite de Girasol Premium', 4.50, '2026-05-15', 200, 50, 75, '1L', 4.50, 'ruta/a/imagen/aceite_girasol_premium.jpg', TRUE, 16, 2, 100),
(49, 6, 20, 24, 'Aceite de Maíz', 3.20, '2026-04-30', 150, 30, 50, '1L', 3.20, 'ruta/a/imagen/aceite_maiz.jpg', TRUE, 17, 2, 80),
(50, 6, 20, 24, 'Aceite de Maíz Orgánico', 3.70, '2026-04-30', 150, 30, 50, '1L', 3.70, 'ruta/a/imagen/aceite_maiz_organico.jpg', TRUE, 17, 2, 80),
(51, 6, 20, 24, 'Aceite de Maíz Premium', 4.00, '2026-04-30', 150, 30, 50, '1L', 4.00, 'ruta/a/imagen/aceite_maiz_premium.jpg', TRUE, 17, 2, 80),
(52, 7, 21, 25, 'Pañales Pampers', 25.00, '2026-12-31', 100, 20, 30, 'Tamaño 4', 25.00, 'ruta/a/imagen/panales_pampers.jpg', TRUE, 19, 7, 50),
(53, 7, 21, 26, 'Pañales Pampers Premium', 30.00, '2026-12-31', 100, 20, 30, 'Tamaño 5', 30.00, 'ruta/a/imagen/panales_pampers_premium.jpg', TRUE, 19, 7, 50),
(54, 7, 22, 27, 'Pañales Pampers Ecológicos', 28.00, '2026-12-31', 100, 20, 30, 'Tamaño 4', 28.00, 'ruta/a/imagen/panales_pampers_ecologicos.jpg', TRUE, 19, 7, 50),
(55, 7, 23, 28, 'Toallas Always', 15.00, '2026-11-30', 100, 20, 30, 'Paquete de 20', 15.00, 'ruta/a/imagen/toallas_always.jpg', TRUE, 20, 11, 40),
(56, 7, 24, 29, 'Toallas Always Ultra', 18.00, '2026-11-30', 100, 20, 30, 'Paquete de 20', 18.00, 'ruta/a/imagen/toallas_always_ultra.jpg', TRUE, 20, 11, 40),
(57, 7, 23, 28, 'Toallas Always Nocturnas', 20.00, '2026-11-30', 100, 20, 30, 'Paquete de 20', 20.00, 'ruta/a/imagen/toallas_always_nocturnas.jpg', TRUE, 20, 11, 40),
(58, 7, 21, 34, 'Jabón Asepxia', 2.50, '2026-10-15', 150, 30, 50, '100g', 2.50, 'ruta/a/imagen/jabon_asepxia.jpg', TRUE, 21, 3, 60),
(59, 7, 21, 35, 'Crema Asepxia', 3.00, '2026-10-15', 150, 30, 50, '50g', 3.00, 'ruta/a/imagen/crema_asepxia.jpg', TRUE, 21, 3, 60),
(60, 7, 21, 36, 'Gel Asepxia', 3.50, '2026-10-15', 150, 30, 50, '100g', 3.50, 'ruta/a/imagen/gel_asepxia.jpg', TRUE, 21, 3, 60),
(61, 8, 25, 30, 'Limpiador Fabuloso', 3.00, '2026-09-30', 200, 50, 75, '1L', 3.00, 'ruta/a/imagen/limpiador_fabuloso.jpg', TRUE, 22, 2, 100),
(62, 8, 25, 30, 'Limpiador Fabuloso Fragancia Floral', 3.50, '2026-09-30', 200, 50, 75, '1L', 3.50, 'ruta/a/imagen/limpiador_fabuloso_floral.jpg', TRUE, 22, 2, 100),
(63, 8, 25, 30, 'Limpiador Fabuloso Multiusos', 3.20, '2026-09-30', 200, 50, 75, '1L', 3.20, 'ruta/a/imagen/limpiador_fabuloso_multiusos.jpg', TRUE, 22, 2, 100),
(64, 9, 28, 31, 'Café Sello Rojo', 4.00, '2026-12-31', 100, 20, 30, '250g', 16.00, 'ruta/a/imagen/cafe_sello_rojo.jpg', TRUE, 23, 3, 50),
(66, 10, 29, 32, 'Chocolate Jet', 1.50, '2026-06-30', 150, 30, 50, '100g', 15.00, 'ruta/a/imagen/chocolate_jet.jpg', TRUE, 24, 3, 80),
(67, 10, 30, 33, 'Chocolate Jet con Almendras', 1.80, '2026-06-30', 150, 30, 50, '100g', 18.00, 'ruta/a/imagen/chocolate_jet_almendras.jpg', TRUE, 24, 3, 70),
(68, 10, 29, 32, 'Chocolate Jet Relleno', 2.00, '2026-06-30', 150, 30, 50, '100g', 20.00, 'ruta/a/imagen/chocolate_jet_relleno.jpg', TRUE, 24, 3, 60);

INSERT INTO tab_productos_proveedores (id_proveedor, id_producto) VALUES
(1, 1), (1, 2), (1, 3),
(2, 4), (2, 5), (2, 6),
(3, 7), (3, 8), (3, 9),
(4, 10), (4, 11), (4, 12),
(5, 13), (5, 14), (5, 15),
(6, 16), (6, 17), (6, 18),
(7, 19), (7, 20), (7, 21),
(8, 22), (8, 23), (8, 24),
(9, 25), (9, 26), (9, 27),
(10, 28), (10, 29), (10, 30),
(11, 31), (11, 32), (11, 33),
(12, 34), (12, 35), (12, 36),
(13, 37), (13, 38), (13, 39),
(14, 40), (14, 41), (14, 42),
(15, 43), (15, 44), (15, 45),
(16, 46), (16, 47), (16, 48),
(17, 49), (17, 50), (17, 51),
(18, 52), (18, 53), (18, 54),
(19, 55), (19, 56), (19, 57),
(20, 58), (20, 59), (20, 60),
(21, 61), (21, 62), (21, 63),
(22, 64),
(23, 66), (23, 67), (23, 68);
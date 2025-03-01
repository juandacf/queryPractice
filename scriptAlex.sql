DROP TABLE IF EXISTS tab_kardexs;
DROP TABLE IF EXISTS tab_productos_proveedores;
DROP TABLE IF EXISTS tab_productos;
DROP TABLE IF EXISTS tab_proveedores;
DROP TABLE IF EXISTS tab_marcas;
DROP TABLE IF EXISTS tab_subcategorias_2;
DROP TABLE IF EXISTS tab_subcategorias;
DROP TABLE IF EXISTS tab_categorias;
DROP TABLE IF EXISTS tab_unidades_medida;

CREATE TABLE IF NOT EXISTS tab_unidades_medida 
(
    id_unidad_medida     DECIMAL(12)    PRIMARY KEY,
    nombre_unidad_medida VARCHAR        NOT NULL UNIQUE,
    estado               BOOLEAN        DEFAULT TRUE NOT NULL
);

CREATE TABLE IF NOT EXISTS tab_categorias 
(
    id_categoria         DECIMAL(12)    PRIMARY KEY,
    nombre_categoria     VARCHAR        NOT NULL UNIQUE,
    estado_categoria     BOOLEAN        DEFAULT TRUE NOT NULL
);

CREATE TABLE IF NOT EXISTS tab_subcategorias 
(
    id_subcategoria      DECIMAL(12)    PRIMARY KEY,
    nombre_subcategoria  VARCHAR        NOT NULL UNIQUE,
    estado_subcategoria  BOOLEAN        DEFAULT TRUE NOT NULL,
    id_categoria         DECIMAL(12)    NOT NULL,
    FOREIGN KEY (id_categoria) REFERENCES tab_categorias(id_categoria)
);

CREATE TABLE IF NOT EXISTS tab_subcategorias_2 
(
    id_subcategoria_2    DECIMAL(12)    PRIMARY KEY,
    nombre_subcategoria_2 VARCHAR       NOT NULL UNIQUE,
    estado_subcategoria_2 BOOLEAN       DEFAULT TRUE NOT NULL,
    id_categoria          DECIMAL(12)   NOT NULL,
    id_subcategoria       DECIMAL(12)   NOT NULL,
    FOREIGN KEY (id_categoria) REFERENCES tab_categorias(id_categoria),
    FOREIGN KEY (id_subcategoria) REFERENCES tab_subcategorias(id_subcategoria)
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
    id_producto          DECIMAL(12)    PRIMARY KEY,
    nombre_producto      VARCHAR        NOT NULL UNIQUE,
    costo_unitario       DECIMAL(10,2)  NOT NULL,
    fecha_caducidad      DATE,
    stock_maximo         INT            NOT NULL,
    stock_minimo         INT            NOT NULL,
    punto_reorden        INT            NOT NULL CHECK (punto_reorden > stock_minimo AND punto_reorden < stock_maximo),
    presentacion         VARCHAR,
    valor_unidad_medida  DECIMAL(10,2),
    direccion_imagen     VARCHAR,
    estado               BOOLEAN        DEFAULT TRUE NOT NULL,
    stock_actual         INT            NOT NULL,
    id_marca             DECIMAL(12)    NOT NULL,
    id_categoria         DECIMAL(12)    NOT NULL,
    id_subcategoria      DECIMAL(12),
    id_subcategoria_2    DECIMAL(12),
    id_unidad_medida     DECIMAL(12)    NOT NULL,
    total_existencias    INT            NOT NULL,
    FOREIGN KEY (id_marca) REFERENCES tab_marcas(id_marca),
    FOREIGN KEY (id_categoria) REFERENCES tab_categorias(id_categoria),
    FOREIGN KEY (id_subcategoria) REFERENCES tab_subcategorias(id_subcategoria),
    FOREIGN KEY (id_subcategoria_2) REFERENCES tab_subcategorias_2(id_subcategoria_2),
    FOREIGN KEY (id_unidad_medida) REFERENCES tab_unidades_medida(id_unidad_medida)
);

CREATE TABLE IF NOT EXISTS tab_productos_proveedores 
(
    id_proveedor         DECIMAL(12)    NOT NULL,
    id_producto          DECIMAL(12)    NOT NULL,
    PRIMARY KEY (id_proveedor, id_producto),
    FOREIGN KEY (id_proveedor) REFERENCES tab_proveedores(id_proveedor),
    FOREIGN KEY (id_producto) REFERENCES tab_productos(id_producto)
);

CREATE TABLE IF NOT EXISTS tab_kardexs 
(
    id_kardex            DECIMAL(12)    PRIMARY KEY,
    tipo_movimiento      VARCHAR        NOT NULL CHECK (tipo_movimiento IN ('Entrada', 'Salida')),
    concepto             VARCHAR        NOT NULL,
    cantidad             DECIMAL(7)     NOT NULL,
    fecha_movimiento     DATE           NOT NULL,
    id_producto          DECIMAL(12)    NOT NULL,
    FOREIGN KEY (id_producto) REFERENCES tab_productos(id_producto)
);

CREATE INDEX idx_productos_nombre ON tab_productos(nombre_producto);
CREATE INDEX idx_productos_estado ON tab_productos(estado);
CREATE INDEX idx_proveedores_nombre ON tab_proveedores(nombre_proveedor);
CREATE INDEX idx_proveedores_estado ON tab_proveedores(estado_proveedor);
CREATE INDEX idx_marcas_nombre ON tab_marcas(nombre_marca);
CREATE INDEX idx_marcas_estado ON tab_marcas(estado_marca);
CREATE INDEX idx_categorias_nombre ON tab_categorias(nombre_categoria);
CREATE INDEX idx_categorias_estado ON tab_categorias(estado_categoria);
CREATE INDEX idx_subcategorias_nombre ON tab_subcategorias(nombre_subcategoria);
CREATE INDEX idx_subcategorias_estado ON tab_subcategorias(estado_subcategoria);
CREATE INDEX idx_kardexs_fecha_movimiento ON tab_kardexs(fecha_movimiento);

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

INSERT INTO tab_subcategorias (id_subcategoria, nombre_subcategoria, id_categoria) VALUES
(1, 'Leche', 1),
(2, 'Yogur', 1),
(3, 'Queso', 1),
(4, 'Refrescos', 2),
(5, 'Jugos', 2),
(6, 'Cervezas', 2),
(7, 'Arroz', 3),
(8, 'Frijoles', 3),
(9, 'Harinas', 3),
(10, 'Salsas', 4),
(11, 'Galletas', 5),
(12, 'Aceites', 6),
(13, 'Pañales', 7),
(14, 'Toallas Femeninas', 7),
(15, 'Limpiadores', 8),
(16, 'Café Molido', 9),
(17, 'Chocolate en Barra', 10);

INSERT INTO tab_subcategorias_2 (id_subcategoria_2, nombre_subcategoria_2, id_categoria, id_subcategoria) VALUES
(1, 'Leche Entera', 1, 1),
(2, 'Leche Descremada', 1, 1),
(3, 'Yogur Natural', 1, 2),
(4, 'Yogur de Frutas', 1, 2),
(5, 'Queso Fresco', 1, 3),
(6, 'Queso Duro', 1, 3),
(7, 'Gaseosas', 2, 4),
(8, 'Tés', 2, 5),
(9, 'Arroz Blanco', 3, 7),
(10, 'Arroz Integral', 3, 7),
(11, 'Frijoles Negros', 3, 8),
(12, 'Frijoles Rojos', 3, 8),
(13, 'Harina de Trigo', 3, 9),
(14, 'Harina de Maíz', 3, 9),
(15, 'Salsas de Tomate', 4, 10),
(16, 'Salsas Picantes', 4, 10),
(17, 'Galletas Saladas', 5, 11),
(18, 'Galletas Dulces', 5, 11),
(19, 'Aceite de Girasol', 6, 12),
(20, 'Aceite de Oliva', 6, 12),
(21, 'Pañales Desechables', 7, 13),
(22, 'Pañales Ecológicos', 7, 13),
(23, 'Toallas Always', 7, 14),
(24, 'Toallas Ultra', 7, 14),
(25, 'Limpiadores Multiusos', 8, 15),
(26, 'Limpiadores de Baño', 8, 15),
(27, 'Café Instantáneo', 9, 16),
(28, 'Café Molido', 9, 16),
(29, 'Chocolate Jet', 10, 17),
(30, 'Chocolate Jet con Almendras', 10, 17);

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


INSERT INTO tab_productos (id_producto, nombre_producto, costo_unitario, fecha_caducidad, stock_maximo, stock_minimo, punto_reorden, presentacion, valor_unidad_medida, direccion_imagen, stock_actual, id_marca, id_categoria, id_subcategoria, id_subcategoria_2, id_unidad_medida, total_existencias) VALUES
(1, 'Leche Colanta', 2.50, '2025-12-31', 100, 20, 30, '1L', 2.50, 'ruta/a/imagen/leche_colanta.jpg', 50, 1, 1, 1, 1, 2, 100), -- 100+150 entradas - 50-100 salidas = 100
(2, 'Yogur Colanta', 1.80, '2025-06-30', 80, 15, 25, '1L', 1.80, 'ruta/a/imagen/yogur_colanta.jpg', 40, 1, 1, 2, 3, 2, 20), -- 80 entradas - 30-30 salidas = 20
(3, 'Queso Colanta', 3.00, '2025-05-15', 50, 10, 15, '500g', 6.00, 'ruta/a/imagen/queso_colanta.jpg', 20, 1, 1, 3, 5, 3, 80), -- 50+50 entradas - 20 salidas = 80
(4, 'Leche Alquería', 2.50, '2025-12-31', 100, 20, 30, '1L', 2.50, 'ruta/a/imagen/leche_alqueria.jpg', 50, 2, 1, 1, 1, 2, 160), -- 100+100 entradas - 40 salidas = 160
(5, 'Yogur Alquería', 1.80, '2025-06-30', 80, 15, 25, '1L', 1.80, 'ruta/a/imagen/yogur_alqueria.jpg', 40, 2, 1, 2, 3, 2, 140), -- 80+100 entradas - 20-20 salidas = 140
(6, 'Queso Alquería', 3.00, '2025-05-15', 50, 10, 15, '500g', 6.00, 'ruta/a/imagen/queso_alqueria.jpg', 20, 2, 1, 3, 5, 3, 20), -- 50 entradas - 10-20 salidas = 20
(7, 'Leche Alpina', 2.50, '2025-12-31', 100, 20, 30, '1L', 2.50, 'ruta/a/imagen/leche_alpina.jpg', 50, 3, 1, 1, 1, 2, 0), -- 100 entradas - 50-50 salidas = 0
(8, 'Yogur Alpina', 1.80, '2025-06-30', 80, 15, 25, '1L', 1.80, 'ruta/a/imagen/yogur_alpina.jpg', 40, 3, 1, 2, 3, 2, 50), -- 80 entradas - 30 salidas = 50
(9, 'Queso Alpina', 3.00, '2025-05-15', 50, 10, 15, '500g', 6.00, 'ruta/a/imagen/queso_alpina.jpg', 20, 3, 1, 3, 5, 3, 60), -- 50+70 entradas - 20-40 salidas = 60
(10, 'Coca-Cola', 1.50, '2026-01-01', 200, 50, 75, '1.5L', 1.50, 'ruta/a/imagen/coca_cola.jpg', 100, 4, 2, 4, 7, 2, 100), -- 200 entradas - 100 salidas = 100
(11, 'Coca-Cola Zero', 1.50, '2026-01-01', 200, 50, 75, '1.5L', 1.50, 'ruta/a/imagen/coca_cola_zero.jpg', 100, 4, 2, 4, 7, 2, 70), -- 150 entradas - 80 salidas = 70
(12, 'Coca-Cola Light', 1.50, '2026-01-01', 200, 50, 75, '1.5L', 1.50, 'ruta/a/imagen/coca_cola_light.jpg', 100, 4, 2, 4, 7, 2, 50), -- 100 entradas - 50 salidas = 50
(13, 'Jugo Postobón', 1.20, '2025-11-30', 150, 30, 50, '1L', 1.20, 'ruta/a/imagen/jugo_postobon.jpg', 60, 5, 2, 5, NULL, 2, 190), -- 150+200 entradas - 60-100 salidas = 190
(14, 'Gaseosa Postobón', 1.50, '2026-01-01', 200, 50, 75, '1.5L', 1.50, 'ruta/a/imagen/gaseosa_postobon.jpg', 100, 5, 2, 4, 7, 2, 220), -- 200+150+150 entradas - 100-80-100 salidas = 220
(15, 'Té Postobón', 1.00, '2025-12-31', 100, 20, 30, '1L', 1.00, 'ruta/a/imagen/te_postobon.jpg', 50, 5, 2, 5, 8, 2, 70), -- 100 entradas - 30 salidas = 70
(16, 'Cerveza Águila', 1.80, '2026-03-01', 100, 20, 30, '330ml', 1.80, 'ruta/a/imagen/cerveza_aguila.jpg', 40, 6, 2, 6, NULL, 4, 120), -- 100+100 entradas - 40 salidas = 120
(17, 'Cerveza Águila Light', 1.80, '2026-03-01', 100, 20, 30, '330ml', 1.80, 'ruta/a/imagen/cerveza_aguila_light.jpg', 40, 6, 2, 6, NULL, 4, 10), -- 80 entradas - 30-40 salidas = 10
(18, 'Cerveza Águila Radler', 1.80, '2026-03-01', 100, 20, 30, '330ml', 1.80, 'ruta/a/imagen/cerveza_aguila_radler.jpg', 40, 6, 2, 6, NULL, 4, 70), -- 60+60 entradas - 20-30 salidas = 70
(19, 'Arroz Diana', 1.00, '2026-12-31', 300, 100, 150, '1kg', 1.00, 'ruta/a/imagen/arroz_diana.jpg', 200, 7, 3, 7, 9, 1, 300), -- 300+200 entradas - 100-100 salidas = 300
(20, 'Arroz Diana Integral', 1.20, '2026-12-31', 300, 100, 150, '1kg', 1.20, 'ruta/a/imagen/arroz_diana_integral.jpg', 200, 7, 3, 7, 10, 1, 120), -- 200 entradas - 80 salidas = 120
(21, 'Arroz Diana Extra', 1.50, '2026-12-31', 300, 100, 150, '1kg', 1.50, 'ruta/a/imagen/arroz_diana_extra.jpg', 200, 7, 3, 7, 9, 1, 100), -- 150 entradas - 50 salidas = 100
(22, 'Harina Pan', 1.50, '2026-06-30', 150, 50, 75, '1kg', 1.50, 'ruta/a/imagen/harina_pan.jpg', 80, 8, 3, 9, 13, 1, 130), -- 150+100 entradas - 70-50 salidas = 130
(23, 'Harina Pan Integral', 1.70, '2026-06-30', 150, 50, 75, '1kg', 1.70, 'ruta/a/imagen/harina_pan_integral.jpg', 80, 8, 3, 9, 14, 1, 70), -- 100+80 entradas - 50-60 salidas = 70
(24, 'Harina Pan Premezclada', 1.60, '2026-06-30', 150, 50, 75, '1kg', 1.60, 'ruta/a/imagen/harina_pan_premezclada.jpg', 80, 8, 3, 9, 14, 1, 80), -- 120 entradas - 40 salidas = 80
(25, 'Frijoles La Fama', 1.20, '2026-01-01', 200, 50, 75, '1kg', 1.20, 'ruta/a/imagen/frijoles_la_fama.jpg', 100, 9, 3, 8, 12, 1, 30), -- 150 entradas - 70-50 salidas = 30
(26, 'Frijoles La Fama Negros', 1.30, '2026-01-01', 200, 50, 75, '1kg', 1.30, 'ruta/a/imagen/frijoles_la_fama_negros.jpg', 100, 9, 3, 8, 11, 1, 100), -- 100 entradas - 0 salidas = 100
(27, 'Frijoles La Fama Rojos', 1.25, '2026-01-01', 200, 50, 75, '1kg', 1.25, 'ruta/a/imagen/frijoles_la_fama_rojos.jpg', 100, 9, 3, 8, 12, 1, 100), -- Sin movimientos, stock_actual = 100
(28, 'Salsa Fruco', 1.00, '2026-12-31', 150, 30, 50, '500g', 2.00, 'ruta/a/imagen/salsa_fruco.jpg', 60, 10, 4, 10, 15, 3, 60), -- Sin movimientos, stock_actual = 60
(29, 'Salsa Fruco Picante', 1.20, '2026-12-31', 150, 30, 50, '500g', 2.20, 'ruta/a/imagen/salsa_fruco_picante.jpg', 60, 10, 4, 10, 16, 3, 60), -- Sin movimientos, stock_actual = 60
(30, 'Salsa Fruco de Ajo', 1.10, '2026-12-31', 150, 30, 50, '500g', 2.10, 'ruta/a/imagen/salsa_fruco_ajo.jpg', 60, 10, 4, 10, 15, 3, 60), -- Sin movimientos, stock_actual = 60
(31, 'Sopa Maggi', 0.80, '2026-11-30', 100, 20, 30, '100g', 0.80, 'ruta/a/imagen/sopa_maggi.jpg', 40, 11, 4, 10, NULL, 3, 40), -- Sin movimientos, stock_actual = 40
(32, 'Caldo Maggi', 1.00, '2026-11-30', 100, 20, 30, '100g', 1.00, 'ruta/a/imagen/caldo_maggi.jpg', 40, 11, 4, 10, NULL, 3, 40), -- Sin movimientos, stock_actual = 40
(33, 'Sazonador Maggi', 1.20, '2026-11-30', 100, 20, 30, '100g', 1.20, 'ruta/a/imagen/sazonador_maggi.jpg', 40, 11, 4, 10, NULL, 3, 40), -- Sin movimientos, stock_actual = 40
(34, 'Caldo Knorr', 1.00, '2026-11-30', 100, 20, 30, '100g', 1.00, 'ruta/a/imagen/caldo_knorr.jpg', 40, 12, 4, 10, NULL, 3, 40), -- Sin movimientos, stock_actual = 40
(35, 'Sazonador Knorr', 1.20, '2026-11-30', 100, 20, 30, '100g', 1.20, 'ruta/a/imagen/sazonador_knorr.jpg', 40, 12, 4, 10, NULL, 3, 40), -- Sin movimientos, stock_actual = 40
(36, 'Sopa Knorr', 0.90, '2026-11-30', 100, 20, 30, '100g', 0.90, 'ruta/a/imagen/sopa_knorr.jpg', 40, 12, 4, 10, NULL, 3, 40), -- Sin movimientos, stock_actual = 40
(37, 'Galletas Saltín Noel', 1.50, '2026-10-15', 200, 50, 75, '200g', 7.50, 'ruta/a/imagen/galletas_saltin_noel.jpg', 100, 13, 5, 11, 17, 3, 100), -- Sin movimientos, stock_actual = 100
(38, 'Galletas Saltín Noel Integral', 1.70, '2026-10-15', 200, 50, 75, '200g', 7.70, 'ruta/a/imagen/galletas_saltin_noel_integral.jpg', 100, 13, 5, 11, 17, 3, 100), -- Sin movimientos, stock_actual = 100
(39, 'Galletas Saltín Noel con Chocolate', 1.80, '2026-10-15', 200, 50, 75, '200g', 7.80, 'ruta/a/imagen/galletas_saltin_noel_chocolate.jpg', 100, 13, 5, 11, 18, 3, 100), -- Sin movimientos, stock_actual = 100
(40, 'Galletas Dux', 1.70, '2026-09-30', 150, 30, 50, '150g', 11.33, 'ruta/a/imagen/galletas_dux.jpg', 80, 14, 5, 11, 18, 3, 80), -- Sin movimientos, stock_actual = 80
(41, 'Galletas Dux de Chocolate', 1.90, '2026-09-30', 150, 30, 50, '150g', 12.00, 'ruta/a/imagen/galletas_dux_chocolate.jpg', 80, 14, 5, 11, 18, 3, 80), -- Sin movimientos, stock_actual = 80
(42, 'Galletas Dux Rellenas', 2.00, '2026-09-30', 150, 30, 50, '150g', 12.50, 'ruta/a/imagen/galletas_dux_rellenas.jpg', 80, 14, 5, 11, 18, 3, 80), -- Sin movimientos, stock_actual = 80
(43, 'Bolsas Ramo', 2.00, '2026-12-31', 100, 20, 30, '1kg', 2.00, 'ruta/a/imagen/bolsas_ramo.jpg', 50, 15, 5, 11, NULL, 1, 50), -- Sin movimientos, stock_actual = 50
(44, 'Bolsas Ramo Ecológicas', 2.50, '2026-12-31', 100, 20, 30, '1kg', 2.50, 'ruta/a/imagen/bolsas_ramo_ecologicas.jpg', 50, 15, 5, 11, NULL, 1, 50), -- Sin movimientos, stock_actual = 50
(45, 'Bolsas Ramo Reutilizables', 3.00, '2026-12-31', 100, 20, 30, '1kg', 3.00, 'ruta/a/imagen/bolsas_ramo_reutilizables.jpg', 50, 15, 5, 11, NULL, 1, 50), -- Sin movimientos, stock_actual = 50
(46, 'Aceite de Girasol', 3.50, '2026-05-15', 200, 50, 75, '1L', 3.50, 'ruta/a/imagen/aceite_girasol.jpg', 100, 16, 6, 12, 19, 2, 100), -- Sin movimientos, stock_actual = 100
(47, 'Aceite de Girasol Orgánico', 4.00, '2026-05-15', 200, 50, 75, '1L', 4.00, 'ruta/a/imagen/aceite_girasol_organico.jpg', 100, 16, 6, 12, 19, 2, 100), -- Sin movimientos, stock_actual = 100
(48, 'Aceite de Girasol Premium', 4.50, '2026-05-15', 200, 50, 75, '1L', 4.50, 'ruta/a/imagen/aceite_girasol_premium.jpg', 100, 16, 6, 12, 19, 2, 100), -- Sin movimientos, stock_actual = 100
(49, 'Aceite de Maíz', 3.20, '2026-04-30', 150, 30, 50, '1L', 3.20, 'ruta/a/imagen/aceite_maiz.jpg', 80, 17, 6, 12, 20, 2, 80), -- Sin movimientos, stock_actual = 80
(50, 'Aceite de Maíz Orgánico', 3.70, '2026-04-30', 150, 30, 50, '1L', 3.70, 'ruta/a/imagen/aceite_maiz_organico.jpg', 80, 17, 6, 12, 20, 2, 80), -- Sin movimientos, stock_actual = 80
(51, 'Aceite de Maíz Premium', 4.00, '2026-04-30', 150, 30, 50, '1L', 4.00, 'ruta/a/imagen/aceite_maiz_premium.jpg', 80, 17, 6, 12, 20, 2, 80), -- Sin movimientos, stock_actual = 80
(52, 'Pañales Pampers', 25.00, '2026-12-31', 100, 20, 30, 'Tamaño 4', 25.00, 'ruta/a/imagen/panales_pampers.jpg', 50, 19, 7, 13, 21, 7, 50), -- Sin movimientos, stock_actual = 50
(53, 'Pañales Pampers Premium', 30.00, '2026-12-31', 100, 20, 30, 'Tamaño 5', 30.00, 'ruta/a/imagen/panales_pampers_premium.jpg', 50, 19, 7, 13, 21, 7, 50), -- Sin movimientos, stock_actual = 50
(54, 'Pañales Pampers Ecológicos', 28.00, '2026-12-31', 100, 20, 30, 'Tamaño 4', 28.00, 'ruta/a/imagen/panales_pampers_ecologicos.jpg', 50, 19, 7, 13, 22, 7, 50), -- Sin movimientos, stock_actual = 50
(55, 'Toallas Always', 15.00, '2026-11-30', 100, 20, 30, 'Paquete de 20', 15.00, 'ruta/a/imagen/toallas_always.jpg', 40, 20, 7, 14, 23, 11, 40), -- Sin movimientos, stock_actual = 40
(56, 'Toallas Always Ultra', 18.00, '2026-11-30', 100, 20, 30, 'Paquete de 20', 18.00, 'ruta/a/imagen/toallas_always_ultra.jpg', 40, 20, 7, 14, 24, 11, 40), -- Sin movimientos, stock_actual = 40
(57, 'Toallas Always Nocturnas', 20.00, '2026-11-30', 100, 20, 30, 'Paquete de 20', 20.00, 'ruta/a/imagen/toallas_always_nocturnas.jpg', 40, 20, 7, 14, 23, 11, 40), -- Sin movimientos, stock_actual = 40
(58, 'Jabón Asepxia', 2.50, '2026-10-15', 150, 30, 50, '100g', 2.50, 'ruta/a/imagen/jabon_asepxia.jpg', 60, 21, 7, NULL, NULL, 3, 60), -- Sin movimientos, stock_actual = 60
(59, 'Crema Asepxia', 3.00, '2026-10-15', 150, 30, 50, '50g', 3.00, 'ruta/a/imagen/crema_asepxia.jpg', 60, 21, 7, NULL, NULL, 3, 60), -- Sin movimientos, stock_actual = 60
(60, 'Gel Asepxia', 3.50, '2026-10-15', 150, 30, 50, '100g', 3.50, 'ruta/a/imagen/gel_asepxia.jpg', 60, 21, 7, NULL, NULL, 3, 60), -- Sin movimientos, stock_actual = 60
(61, 'Limpiador Fabuloso', 3.00, '2026-09-30', 200, 50, 75, '1L', 3.00, 'ruta/a/imagen/limpiador_fabuloso.jpg', 100, 22, 8, 15, 25, 2, 100), -- Sin movimientos, stock_actual = 100
(62, 'Limpiador Fabuloso Fragancia Floral', 3.50, '2026-09-30', 200, 50, 75, '1L', 3.50, 'ruta/a/imagen/limpiador_fabuloso_floral.jpg', 100, 22, 8, 15, 25, 2, 100), -- Sin movimientos, stock_actual = 100
(63, 'Limpiador Fabuloso Multiusos', 3.20, '2026-09-30', 200, 50, 75, '1L', 3.20, 'ruta/a/imagen/limpiador_fabuloso_multiusos.jpg', 100, 22, 8, 15, 25, 2, 100), -- Sin movimientos, stock_actual = 100
(64, 'Café Sello Rojo', 4.00, '2026-12-31', 100, 20, 30, '250g', 16.00, 'ruta/a/imagen/cafe_sello_rojo.jpg', 50, 23, 9, 16, 28, 3, 50), -- Sin movimientos, stock_actual = 50
(66, 'Chocolate Jet', 1.50, '2026-06-30', 150, 30, 50, '100g', 15.00, 'ruta/a/imagen/chocolate_jet.jpg', 80, 24, 10, 17, 29, 3, 80), -- Sin movimientos, stock_actual = 80
(67, 'Chocolate Jet con Almendras', 1.80, '2026-06-30', 150, 30, 50, '100g', 18.00, 'ruta/a/imagen/chocolate_jet_almendras.jpg', 70, 24, 10, 17, 30, 3, 70), -- Sin movimientos, stock_actual = 70
(68, 'Chocolate Jet Relleno', 2.00, '2026-06-30', 150, 30, 50, '100g', 20.00, 'ruta/a/imagen/chocolate_jet_relleno.jpg', 60, 24, 10, 17, 29, 3, 60); -- Sin movimientos, stock_actual = 60

INSERT INTO tab_productos_proveedores (id_proveedor, id_producto) VALUES
(1, 1), (1, 2), (1, 3), (2, 4), (2, 5), (2, 6), (3, 7), (3, 8), (3, 9),
(4, 10), (4, 11), (4, 12), (5, 13), (5, 14), (5, 15), (6, 16), (6, 17), (6, 18),
(7, 19), (7, 20), (7, 21), (8, 22), (8, 23), (8, 24), (9, 25), (9, 26), (9, 27),
(10, 28), (10, 29), (10, 30), (11, 31), (11, 32), (11, 33), (12, 34), (12, 35), (12, 36),
(13, 37), (13, 38), (13, 39), (14, 40), (14, 41), (14, 42), (15, 43), (15, 44), (15, 45),
(16, 46), (16, 47), (16, 48), (17, 49), (17, 50), (17, 51), (18, 52), (18, 53), (18, 54),
(19, 55), (19, 56), (19, 57), (20, 58), (20, 59), (20, 60), (21, 61), (21, 62), (21, 63),
(22, 64), (23, 66), (23, 67), (23, 68);

INSERT INTO tab_kardexs (id_kardex, tipo_movimiento, concepto, cantidad, fecha_movimiento, id_producto) VALUES
(1, 'Entrada', 'Compra de Leche Colanta', 100, '2023-01-10', 1),
(2, 'Entrada', 'Compra de Yogur Colanta', 80, '2023-01-12', 2),
(3, 'Entrada', 'Compra de Queso Colanta', 50, '2023-01-15', 3),
(4, 'Entrada', 'Compra de Leche Alquería', 100, '2023-01-20', 4),
(5, 'Entrada', 'Compra de Yogur Alquería', 80, '2023-01-22', 5),
(6, 'Entrada', 'Compra de Queso Alquería', 50, '2023-01-25', 6),
(7, 'Entrada', 'Compra de Leche Alpina', 100, '2023-01-30', 7),
(8, 'Entrada', 'Compra de Yogur Alpina', 80, '2023-02-01', 8),
(9, 'Entrada', 'Compra de Queso Alpina', 50, '2023-02-05', 9),
(10, 'Entrada', 'Compra de Coca-Cola', 200, '2023-02-10', 10),
(11, 'Entrada', 'Compra de Coca-Cola Zero', 150, '2023-02-12', 11),
(12, 'Entrada', 'Compra de Coca-Cola Light', 100, '2023-02-15', 12),
(13, 'Entrada', 'Compra de Jugo Postobón', 150, '2023-02-20', 13),
(14, 'Entrada', 'Compra de Gaseosa Postobón', 200, '2023-02-22', 14),
(15, 'Entrada', 'Compra de Té Postobón', 100, '2023-02-25', 15),
(16, 'Entrada', 'Compra de Cerveza Águila', 100, '2023-03-01', 16),
(17, 'Entrada', 'Compra de Cerveza Águila Light', 80, '2023-03-03', 17),
(18, 'Entrada', 'Compra de Cerveza Águila Radler', 60, '2023-03-05', 18),
(19, 'Entrada', 'Compra de Arroz Diana', 300, '2023-03-10', 19),
(20, 'Entrada', 'Compra de Arroz Diana Integral', 200, '2023-03-12', 20),
(21, 'Entrada', 'Compra de Arroz Diana Extra', 150, '2023-03-15', 21),
(22, 'Entrada', 'Compra de Harina Pan', 150, '2023-03-20', 22),
(23, 'Entrada', 'Compra de Harina Pan Integral', 100, '2023-03-22', 23),
(24, 'Entrada', 'Compra de Harina Pan Premezclada', 120, '2023-03-25', 24),
(25, 'Salida', 'Venta de Leche Colanta', 50, '2023-01-15', 1),
(26, 'Salida', 'Venta de Yogur Colanta', 30, '2023-01-18', 2),
(27, 'Salida', 'Venta de Queso Colanta', 20, '2023-01-20', 3),
(28, 'Salida', 'Venta de Leche Alquería', 40, '2023-01-25', 4),
(29, 'Salida', 'Venta de Yogur Alquería', 20, '2023-01-28', 5),
(30, 'Salida', 'Venta de Queso Alquería', 10, '2023-01-30', 6),
(31, 'Salida', 'Venta de Leche Alpina', 50, '2023-02-05', 7),
(32, 'Salida', 'Venta de Yogur Alpina', 30, '2023-02-08', 8),
(33, 'Salida', 'Venta de Queso Alpina', 20, '2023-02-10', 9),
(34, 'Salida', 'Venta de Coca-Cola', 100, '2023-02-15', 10),
(35, 'Salida', 'Venta de Coca-Cola Zero', 80, '2023-02-18', 11),
(36, 'Salida', 'Venta de Coca-Cola Light', 50, '2023-02-20', 12),
(37, 'Salida', 'Venta de Jugo Postobón', 60, '2023-02-25', 13),
(38, 'Salida', 'Venta de Gaseosa Postobón', 100, '2023-02-28', 14),
(39, 'Salida', 'Venta de Té Postobón', 30, '2023-03-02', 15),
(40, 'Salida', 'Venta de Cerveza Águila', 40, '2023-03-05', 16),
(41, 'Salida', 'Venta de Cerveza Águila Light', 30, '2023-03-07', 17),
(42, 'Salida', 'Venta de Cerveza Águila Radler', 20, '2023-03-10', 18),
(43, 'Salida', 'Venta de Arroz Diana', 100, '2023-03-12', 19),
(44, 'Salida', 'Venta de Arroz Diana Integral', 80, '2023-03-15', 20),
(45, 'Salida', 'Venta de Arroz Diana Extra', 50, '2023-03-18', 21),
(46, 'Salida', 'Venta de Harina Pan', 70, '2023-03-22', 22),
(47, 'Salida', 'Venta de Harina Pan Integral', 50, '2023-03-25', 23),
(48, 'Salida', 'Venta de Harina Pan Premezclada', 40, '2023-03-28', 24),
(49, 'Entrada', 'Compra de Leche Colanta', 150, '2023-04-01', 1),
(50, 'Entrada', 'Compra de Yogur Alquería', 100, '2023-04-02', 5),
(51, 'Entrada', 'Compra de Queso Alpina', 70, '2023-04-03', 9),
(52, 'Entrada', 'Compra de Jugo Postobón', 200, '2023-04-04', 13),
(53, 'Entrada', 'Compra de Gaseosa Postobón', 150, '2023-04-05', 14),
(54, 'Entrada', 'Compra de Cerveza Águila', 100, '2023-04-06', 16),
(55, 'Entrada', 'Compra de Arroz Diana', 200, '2023-04-07', 19),
(56, 'Entrada', 'Compra de Harina Pan', 100, '2023-04-08', 22),
(57, 'Entrada', 'Compra de Frijoles La Fama', 150, '2023-04-09', 25),
(58, 'Salida', 'Venta de Leche Alpina', 50, '2023-04-10', 7),
(59, 'Salida', 'Venta de Yogur Colanta', 30, '2023-04-11', 2),
(60, 'Salida', 'Venta de Queso Alquería', 20, '2023-04-12', 6),
(61, 'Salida', 'Venta de Jugo Postobón', 100, '2023-04-13', 13),
(62, 'Salida', 'Venta de Gaseosa Postobón', 80, '2023-04-14', 14),
(63, 'Salida', 'Venta de Cerveza Águila Light', 40, '2023-04-15', 17),
(64, 'Salida', 'Venta de Arroz Diana', 100, '2023-04-16', 19),
(65, 'Salida', 'Venta de Harina Pan', 50, '2023-04-17', 22),
(66, 'Salida', 'Venta de Frijoles La Fama', 70, '2023-04-18', 25),
(67, 'Entrada', 'Compra de Cerveza Águila Radler', 60, '2023-04-19', 18),
(68, 'Entrada', 'Compra de Leche Alquería', 100, '2023-04-20', 4),
(69, 'Entrada', 'Compra de Queso Colanta', 50, '2023-04-21', 3),
(70, 'Entrada', 'Compra de Harina Pan Integral', 80, '2023-04-22', 23),
(71, 'Entrada', 'Compra de Frijoles La Fama Negros', 100, '2023-04-23', 26),
(72, 'Entrada', 'Compra de Gaseosa Postobón', 150, '2023-04-24', 14),
(73, 'Salida', 'Venta de Cerveza Águila Radler', 30, '2023-04-25', 18),
(74, 'Salida', 'Venta de Leche Colanta', 100, '2023-04-26', 1),
(75, 'Salida', 'Venta de Queso Alpina', 40, '2023-04-27', 9),
(76, 'Salida', 'Venta de Harina Pan Integral', 60, '2023-04-28', 23),
(77, 'Salida', 'Venta de Frijoles La Fama', 50, '2023-04-29', 25),
(78, 'Salida', 'Venta de Gaseosa Postobón', 100, '2023-04-30', 14);

/* Queries 
SELECT
	k.tipo_movimiento,
	count(k.tipo_movimiento) total_movimientos,
	sum(k.cantidad) suma_total_productos,
	avg(k.cantidad) promedio
FROM tab_kardexs k
GROUP BY
	k.tipo_movimiento;
*/
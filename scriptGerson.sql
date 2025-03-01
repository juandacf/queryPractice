DROP TABLE IF EXISTS  tab_prod_prov;
DROP VIEW vista_kardex;
DROP TABLE IF EXISTS  tab_kardex;
DROP TABLE IF EXISTS  tab_productos;
DROP TABLE IF EXISTS  tab_proveedores;
DROP TABLE IF EXISTS  tab_unidad;
DROP TABLE IF EXISTS  tab_subcategorias3;
DROP TABLE IF EXISTS  tab_subcategorias;
DROP TABLE IF EXISTS  tab_categorias;
DROP TABLE IF EXISTS  tab_marcas;

CREATE TABLE IF NOT EXISTS tab_marcas(
    id_marca                INTEGER                 NOT NULL,           -- ID de la marca   
    nom_marca               VARCHAR                 NOT NULL,           -- Nombre de la marca
    est_marca               BOOLEAN                 DEFAULT TRUE ,           -- Estado activo/inactivo
    PRIMARY KEY(id_marca)
);
CREATE TABLE IF NOT EXISTS tab_categorias(
    id_categoria            INTEGER                 NOT NULL,           -- id de la categoria
    nom_categoria           VARCHAR                 NOT NULL,           -- Nombre de la categoria
    estado_categoria        BOOLEAN                 DEFAULT TRUE,           -- Estado activo/inactivo
    PRIMARY KEY(id_categoria)
);
CREATE TABLE IF NOT EXISTS tab_subcategorias(
    id_categoria            INTEGER                 NOT NULL,           
    id_subcategoria         INTEGER                 NOT NULL,           -- id de la subcategoria
    nom_subcategoria        VARCHAR                 NOT NULL,           -- Nombre de la subcategoria
    estado_subcategoria     BOOLEAN                 DEFAULT TRUE,           -- Estado activo/inactivo
    PRIMARY KEY(id_categoria,id_subcategoria),                          -- Llave compuesta
	FOREIGN KEY (id_categoria)           				 REFERENCES tab_categorias(id_categoria) 
);		
CREATE TABLE IF NOT EXISTS tab_subcategorias3(
    id_categoria             INTEGER                NOT NULL,           
    id_subcategoria          INTEGER                NOT NULL,
    id_subcategoria3         INTEGER                NOT NULL,           -- id subcategoria 3    
    nom_subcategoria3        VARCHAR                NOT NULL,           -- Nombre de la subcategoria 3
    estado_subcategoria3     BOOLEAN                DEFAULT TRUE,           -- Estado activo/inactivo
    PRIMARY KEY(id_categoria,id_subcategoria,id_subcategoria3),
    FOREIGN KEY (id_categoria, id_subcategoria)        REFERENCES tab_subcategorias(id_categoria,id_subcategoria)
);
CREATE TABLE IF NOT EXISTS tab_unidad(
    id_unidad               DECIMAL(2,0)            NOT NULL,           -- Id de la tabla unidades de medida
    nom_unidad              VARCHAR                 NOT NULL,           -- Nombre de la unidad de medida
    estado_unidad           BOOLEAN                 DEFAULT TRUE,           -- Estado activo/inactivo
    PRIMARY KEY(id_unidad)
);
CREATE TABLE IF NOT EXISTS tab_proveedores(
    id_proveedores          INTEGER                 NOT NULL,           -- Identificacion de proveedores
    nom_proovedor           VARCHAR                 NOT NULL,           -- Nombre del proveedor
    estado_proveedor        BOOLEAN                 DEFAULT TRUE,           -- Estado activo/inactivo
    PRIMARY KEY(id_proveedores)
 );
 CREATE TABLE IF NOT EXISTS tab_productos(
    id_categoria            INTEGER                 NOT NULL,       
    id_subcategoria         INTEGER                 NOT NULL,
    id_subcategoria3        INTEGER                 NOT NULL,   
    id_producto             INTEGER                 NOT NULL,           -- Id compuesto del producto
    nom_producto            VARCHAR                 NOT NULL,           -- Nombre del producto
    id_marca                INTEGER                 NOT NULL,                
    costo_unitario          INTEGER                 NOT NULL,           -- Costo unitario del producto(ponderado)
    ind_caduca              BOOLEAN                 NOT NULL,           -- Atributo que identifica si es un producto perecedero o no
    stock_min               INTEGER                 NOT NULL,           -- Cantidad minima de prodcuto que debo tener en el stock
    stock_max               INTEGER                 NOT NULL,           -- Cantidad maxima de producto que debo tener en el stock
    punto_reorden           INTEGER                 NOT NULL,           -- Cantidad media en el cual manda una alerta para reordenar el producto
    pres_producto           VARCHAR                 NOT NULL,           -- Presentacion del producto, añadir opciones (Caja,Empaque,Botella)
    id_unidad               DECIMAl(2,0) ,   
    val_u_medida            INTEGER ,           -- Valor o cantidad que se le da al producto ejemplo: 500 mg, 2 litros
    cantidad_producto       INTEGER                 NOT NULL,           -- Cantidad de producto que tengo en el inventario
    est_productos           BOOLEAN                 DEFAULT TRUE,           -- Estado activo/inactivo
    img_producto            VARCHAR,                                    -- Imagen de referencia del producto
    PRIMARY KEY(id_categoria,id_subcategoria,id_subcategoria3,id_producto),
    FOREIGN KEY (id_categoria,id_subcategoria,id_subcategoria3)            REFERENCES tab_subcategorias3(id_categoria,  id_subcategoria, id_subcategoria3),
	FOREIGN KEY (id_unidad)                   								REFERENCES tab_unidad(id_unidad),
    FOREIGN KEY (id_marca)                  						        REFERENCES tab_marcas(id_marca),
    CONSTRAINT chk_punto_reorden CHECK (punto_reorden >= stock_min AND punto_reorden <= stock_max)
 );

 CREATE TABLE IF NOT EXISTS tab_kardex(
    id SERIAL PRIMARY KEY,           -- Identificador del Kardex
	id_categoria            INTEGER                 NOT NULL,       
    id_subcategoria         INTEGER                 NOT NULL,
    id_subcategoria3        INTEGER                 NOT NULL,   
    id_producto             INTEGER                 NOT NULL,           -- Id del producto en el que va a haber movimiento
    tipo_movimiento         BOOLEAN                 NOT NULL,           -- Tipo de movimiento, entrada o salida
    concepto_movimiento     VARCHAR                 NOT NULL,           -- 4 opciones: Compra, venta, 
    cantidad_movimiento     INTEGER                 NOT NULL,           -- Cantidad de productos que entran o salen
    fecha_movimiento        TIMESTAMP               NOT NULL,           -- Fecha en la que se realizo el movimiento
	CONSTRAINT chk_concepto_movimiento 
	CHECK (concepto_movimiento IN ('Compra', 'Venta', 'Devolucion a proveedor', 'Devolucion de cliente')),
	CONSTRAINT chk_tipo_movimiento 
        CHECK (
            (concepto_movimiento = 'Compra' AND tipo_movimiento = TRUE) OR 
            (concepto_movimiento = 'Venta' AND tipo_movimiento = FALSE) OR
            (concepto_movimiento = 'Devolucion a proveedor' AND tipo_movimiento = FALSE) OR
            (concepto_movimiento = 'Devolucion de cliente' AND tipo_movimiento = TRUE )
        ),
	CONSTRAINT chk_cantidadmovimiento CHECK(cantidad_movimiento>=0),
    FOREIGN KEY(id_producto,id_categoria,id_subcategoria,id_subcategoria3)   
	REFERENCES tab_productos(id_producto,id_categoria,id_subcategoria,id_subcategoria3)
 ); 
 
 -- Tabla para normalizar la relacion productos/proveedor
 CREATE TABLE IF NOT EXISTS tab_prod_prov(
    id_producto             INTEGER                 NOT NULL,
    id_proveedores          INTEGER                 NOT NULL,
	id_categoria            INTEGER                 NOT NULL,       
    id_subcategoria         INTEGER                 NOT NULL,
    id_subcategoria3        INTEGER                 NOT NULL,   
    id_prod_prov            INTEGER                 NOT NULL,
	PRIMARY KEY(id_categoria,id_subcategoria,id_subcategoria3,id_producto,id_proveedores,id_prod_prov),
    FOREIGN KEY(id_producto,id_categoria,id_subcategoria,id_subcategoria3)   	REFERENCES tab_productos(id_producto,id_categoria,id_subcategoria,id_subcategoria3),
	FOREIGN KEY(id_proveedores)				REFERENCES tab_proveedores(id_proveedores)
 );

CREATE OR REPLACE FUNCTION actualizar_stock()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.tipo_movimiento = TRUE THEN
        UPDATE tab_productos
        SET cantidad_producto = cantidad_producto + NEW.cantidad_movimiento
        WHERE id_producto = NEW.id_producto
        AND id_categoria = NEW.id_categoria
        AND id_subcategoria = NEW.id_subcategoria
        AND id_subcategoria3 = NEW.id_subcategoria3;
    ELSE
        IF (SELECT cantidad_producto FROM tab_productos
            WHERE id_producto = NEW.id_producto
            AND id_categoria = NEW.id_categoria
            AND id_subcategoria = NEW.id_subcategoria
            AND id_subcategoria3 = NEW.id_subcategoria3) >= NEW.cantidad_movimiento THEN

 
            UPDATE tab_productos
            SET cantidad_producto = cantidad_producto - NEW.cantidad_movimiento
            WHERE id_producto = NEW.id_producto
            AND id_categoria = NEW.id_categoria
            AND id_subcategoria = NEW.id_subcategoria
            AND id_subcategoria3 = NEW.id_subcategoria3;
        ELSE
            RAISE EXCEPTION 'No hay suficiente stock para realizar esta operación';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
 

   CREATE TRIGGER trigger_actualizar_stock
   AFTER INSERT OR UPDATE ON tab_kardex
   FOR EACH ROW EXECUTE FUNCTION actualizar_stock();
    

-- TABLA DE MARCAS
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (1, 'Alpina');
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (2, 'Bimbo');
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (3, 'Colanta');
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (4, 'Postobón');
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (5, 'Coca-Cola');
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (6, 'Pepsi');
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (7, 'Ramo');
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (8, 'Noel');
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (9, 'Diana');
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (10, 'Zenú');
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (11, 'Super Ricas');
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (12, 'Yogo Yogo');
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (13, 'Tostao');
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (14, 'Doria');
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (15, 'La Constancia');
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (16, 'Familia');
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (17, 'Ajinomoto');
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (18, 'La Fazenda');
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (19, 'San Jorge');
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (20, 'Pasta La Muñeca');
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (21, 'Arroz Roa');
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (22, 'Arroz Florhuila');
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (23, 'Fruco');
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (24, 'Sello Rojo');
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (25, 'Oma');
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (26, 'Juan Valdez');
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (27, 'Nestlé');
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (28, 'Milo');
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (29, 'Nutresa');
INSERT INTO tab_marcas (id_marca, nom_marca) VALUES (30, 'Corona');


-- Poblar la tabla de Categorías
INSERT INTO tab_categorias (id_categoria, nom_categoria) VALUES
(1, 'Alimentos y Bebidas'),
(2, 'Productos de Limpieza'),
(3, 'Higiene y Cuidado Personal'),
(4, 'Mascotas'),
(5, 'Hogar y Ferretería'),
(6, 'Bebés y Niños'),
(7, 'Papelería y Oficina');

-- Poblar la tabla de Subcategorías
INSERT INTO tab_subcategorias (id_categoria, id_subcategoria, nom_subcategoria) VALUES
(1, 1, 'Lácteos'),
(1, 2, 'Carnes y Embutidos'),
(1, 3, 'Frutas y Verduras'),
(1, 4, 'Panadería y Repostería'),
(1, 5, 'Bebidas'),
(2, 6, 'Limpieza del Hogar'),
(2, 7, 'Cuidado de Ropa'),
(2, 8, 'Desechables y Accesorios'),
(3, 9, 'Cuidado del Cabello'),
(3, 10, 'Cuidado de la Piel'),
(3, 11, 'Higiene Oral'),
(3, 12, 'Productos Femeninos'),
(4, 13, 'Alimentos para Mascotas'),
(4, 14, 'Cuidado e Higiene'),
(4, 15, 'Accesorios para Mascotas'),
(5, 16, 'Electrodomésticos Pequeños'),
(5, 17, 'Herramientas'),
(5, 18, 'Decoración y Organización'),
(6, 19, 'Alimentos y Fórmulas Infantiles'),
(6, 20, 'Pañales y Toallitas'),
(6, 21, 'Juguetes'),
(7, 22, 'Útiles Escolares');

-- Poblar la tabla de Subcategorías3
INSERT INTO tab_subcategorias3 (id_categoria, id_subcategoria, id_subcategoria3, nom_subcategoria3) VALUES
(1, 1, 1, 'Leche'),
(1, 1, 2, 'Yogur'),
(1, 1, 3, 'Quesos'),
(1, 1, 4, 'Mantequilla y Margarina'),
(1, 2, 5, 'Carne de res'),
(1, 2, 6, 'Carne de cerdo'),
(1, 2, 7, 'Pollo'),
(1, 2, 8, 'Embutidos'),
(1, 3, 9, 'Frutas frescas'),
(1, 3, 10, 'Verduras frescas'),
(1, 3, 11, 'Frutas secas'),
(1, 3, 12, 'Hierbas y especias'),
(1, 4, 13, 'Pan fresco'),
(1, 4, 14, 'Bollería'),
(1, 4, 15, 'Pasteles y tartas'),
(1, 4, 16, 'Galletas y bizcochos'),
(1, 5, 17, 'Aguas'),
(1, 5, 18, 'Jugos y néctares'),
(1, 5, 19, 'Refrescos y gaseosas'),
(1, 5, 20, 'Bebidas energéticas'),
(1, 5, 21, 'Alcohol');
-- Subcategorías3 para "Limpieza del Hogar" (2,6)
INSERT INTO tab_subcategorias3 (id_categoria, id_subcategoria, id_subcategoria3, nom_subcategoria3) VALUES
(2, 6, 22, 'Detergente (líquido, en polvo, cápsulas)'),
(2, 6, 23, 'Desinfectante multiusos'),
(2, 6, 24, 'Limpiadores de baño'),
(2, 6, 25, 'Limpiavidrios');

-- Subcategorías3 para "Cuidado de Ropa" (2,7)
INSERT INTO tab_subcategorias3 (id_categoria, id_subcategoria, id_subcategoria3, nom_subcategoria3) VALUES
(2, 7, 26, 'Suavizantes'),
(2, 7, 27, 'Quitamanchas'),
(2, 7, 28, 'Blanqueadores'),
(2, 7, 29, 'Almidón para planchar');

-- Subcategorías3 para "Desechables y Accesorios" (2,8)
INSERT INTO tab_subcategorias3 (id_categoria, id_subcategoria, id_subcategoria3, nom_subcategoria3) VALUES
(2, 8, 30, 'Bolsas de basura'),
(2, 8, 31, 'Servilletas'),
(2, 8, 32, 'Toallas de papel'),
(2, 8, 33, 'Platos y cubiertos desechables');

-- Subcategorías3 para "Cuidado del Cabello" (3,9)
INSERT INTO tab_subcategorias3 (id_categoria, id_subcategoria, id_subcategoria3, nom_subcategoria3) VALUES
(3, 9, 34, 'Champú (normal, anticaspa, hidratante)'),
(3, 9, 35, 'Acondicionador'),
(3, 9, 36, 'Gel y cera para peinar'),
(3, 9, 37, 'Tinturas para el cabello');

-- Subcategorías3 para "Cuidado de la Piel" (3,10)
INSERT INTO tab_subcategorias3 (id_categoria, id_subcategoria, id_subcategoria3, nom_subcategoria3) VALUES
(3, 10, 38, 'Jabón (líquido, en barra, antibacterial)'),
(3, 10, 39, 'Crema hidratante'),
(3, 10, 40, 'Protector solar'),
(3, 10, 41, 'Exfoliantes');

-- Subcategorías3 para "Higiene Oral" (3,11)
INSERT INTO tab_subcategorias3 (id_categoria, id_subcategoria, id_subcategoria3, nom_subcategoria3) VALUES
(3, 11, 42, 'Pasta dental'),
(3, 11, 43, 'Enjuague bucal'),
(3, 11, 44, 'Cepillos de dientes (manual, eléctrico)'),
(3, 11, 45, 'Hilo dental');

-- Subcategorías3 para "Productos Femeninos" (3,12)
INSERT INTO tab_subcategorias3 (id_categoria, id_subcategoria, id_subcategoria3, nom_subcategoria3) VALUES
(3, 12, 46, 'Toallas sanitarias'),
(3, 12, 47, 'Tampones'),
(3, 12, 48, 'Copas menstruales'),
(3, 12, 49, 'Toallas húmedas íntimas');

-- Subcategorías3 para "Alimentos para Mascotas" (4,13)
INSERT INTO tab_subcategorias3 (id_categoria, id_subcategoria, id_subcategoria3, nom_subcategoria3) VALUES
(4, 13, 50, 'Alimento para perros (croquetas, húmedo)'),
(4, 13, 51, 'Alimento para gatos (seco, húmedo)'),
(4, 13, 52, 'Alimento para aves'),
(4, 13, 53, 'Alimento para roedores');

-- Subcategorías3 para "Cuidado e Higiene de Mascotas" (4,14)
INSERT INTO tab_subcategorias3 (id_categoria, id_subcategoria, id_subcategoria3, nom_subcategoria3) VALUES
(4, 14, 54, 'Champú para mascotas'),
(4, 14, 55, 'Productos antipulgas'),
(4, 14, 56, 'Arenas para gatos'),
(4, 14, 57, 'Pañales para mascotas');

-- Subcategorías3 para "Accesorios para Mascotas" (4,15)
INSERT INTO tab_subcategorias3 (id_categoria, id_subcategoria, id_subcategoria3, nom_subcategoria3) VALUES
(4, 15, 58, 'Juguetes (pelotas, mordedores)'),
(4, 15, 59, 'Collares y correas'),
(4, 15, 60, 'Camas y cojines'),
(4, 15, 61, 'Platos y bebederos');

-- Subcategorías3 para "Electrodomésticos Pequeños" (5,16)
INSERT INTO tab_subcategorias3 (id_categoria, id_subcategoria, id_subcategoria3, nom_subcategoria3) VALUES
(5, 16, 62, 'Licuadoras'),
(5, 16, 63, 'Tostadoras'),
(5, 16, 64, 'Microondas'),
(5, 16, 65, 'Cafeteras');

-- Subcategorías3 para "Herramientas" (5,17)
INSERT INTO tab_subcategorias3 (id_categoria, id_subcategoria, id_subcategoria3, nom_subcategoria3) VALUES
(5, 17, 66, 'Destornilladores'),
(5, 17, 67, 'Martillos'),
(5, 17, 68, 'Taladros'),
(5, 17, 69, 'Llaves inglesas');

-- Subcategorías3 para "Decoración y Organización" (5,18)
INSERT INTO tab_subcategorias3 (id_categoria, id_subcategoria, id_subcategoria3, nom_subcategoria3) VALUES
(5, 18, 70, 'Cuadros y portarretratos'),
(5, 18, 71, 'Organizadores de plástico'),
(5, 18, 72, 'Alfombras'),
(5, 18, 73, 'Cortinas');

-- Subcategorías3 para "Alimentos y Fórmulas Infantiles" (6,19)
INSERT INTO tab_subcategorias3 (id_categoria, id_subcategoria, id_subcategoria3, nom_subcategoria3) VALUES
(6, 19, 74, 'Leche infantil'),
(6, 19, 75, 'Cereales para bebés'),
(6, 19, 76, 'Compotas y purés');

-- Subcategorías3 para "Pañales y Toallitas" (6,20)
INSERT INTO tab_subcategorias3 (id_categoria, id_subcategoria, id_subcategoria3, nom_subcategoria3) VALUES
(6, 20, 77, 'Pañales desechables (diferentes tamaños)'),
(6, 20, 78, 'Toallitas húmedas'),
(6, 20, 79, 'Crema para rozaduras');

-- Subcategorías3 para "Útiles Escolares" (7,22)
INSERT INTO tab_subcategorias3 (id_categoria, id_subcategoria, id_subcategoria3, nom_subcategoria3) VALUES
(7, 22, 80, 'Cuadernos (rayados, cuadriculados)'),
(7, 22, 81, 'Lápices y bolígrafos'),
(7, 22, 82, 'Colores y marcadores'),
(7, 22, 83, 'Mochilas y estuches');


-- Poblar la tabla de Proveedores
INSERT INTO tab_proveedores (id_proveedores, nom_proovedor) VALUES
(1, 'Distribuidora Alimentos S.A.'),
(2, 'Carnes Premium Ltda.'),
(3, 'Frutas del Valle SAS'),
(4, 'Panadería La Espiga'),
(5, 'Bebidas y Licores Express'),
(6, 'Limpieza Total SRL'),
(7, 'Ropa Brillante S.A.'),
(8, 'Empaques Desechables S.A.'),
(9, 'Cuidado Personal Plus'),
(10, 'Distribuidora Higiene Oral'),
(11, 'Feminine Care Solutions'),
(12, 'Mascotas Felices Ltda.'),
(13, 'Accesorios para Mascotas Express'),
(14, 'Electrodomésticos Hogar SAS'),
(15, 'Ferretería y Herramientas SAS'),
(16, 'Decoraciones y Diseño Hogar'),
(17, 'Alimentos Infantiles NutriKids'),
(18, 'Pañales y Bebés Care'),
(19, 'Juguetes Divertidos SAS'),
(20, 'Papelería y Oficina Express');

-- Poblar tabla de unidades (sin "Unidades")
INSERT INTO tab_unidad (id_unidad, nom_unidad) VALUES
(1, 'Litros'),
(2, 'Kilogramos'),
(3, 'Miligramos');

INSERT INTO tab_productos (
    id_categoria, id_subcategoria, id_subcategoria3, id_producto, nom_producto, id_marca, 
    costo_unitario, ind_caduca, stock_min, stock_max, punto_reorden, pres_producto, 
    id_unidad, val_u_medida, cantidad_producto, img_producto
) VALUES
-- Categoría 1: Alimentos y Bebidas
(1, 1, 1, 1, 'Leche Entera Alpina', 1, 3500, TRUE, 10, 100, 25, 'Botella', 1, 1, 50, 'leche_alpina.jpg'),
(1, 1, 2, 1, 'Yogur Natural Yogo Yogo', 12, 2000, TRUE, 15, 150, 30, 'Empaque', NULL, NULL, 75, 'yogur_yogoyogo.jpg'),
(1, 1, 3, 1, 'Queso Colanta', 3, 12000, TRUE, 5, 50, 10, 'Empaque', 2, 1, 25, 'queso_colanta.jpg'),
(1, 1, 4, 1, 'Mantequilla La Fazenda', 18, 4500, TRUE, 10, 80, 15, 'Empaque', NULL, NULL, 40, 'mantequilla_fazenda.jpg'),
(1, 2, 5, 1, 'Carne de Res San Jorge', 19, 25000, TRUE, 5, 30, 8, 'Empaque', 2, 1, 15, 'carne_sanjorge.jpg'),
(1, 2, 6, 1, 'Carne de Cerdo Zenú', 10, 22000, TRUE, 5, 30, 8, 'Empaque', 2, 1, 12, 'carne_zenu.jpg'),
(1, 2, 7, 1, 'Pollo Ramo', 7, 18000, TRUE, 5, 40, 10, 'Empaque', 2, 1, 20, 'pollo_ramo.jpg'),
(1, 2, 8, 1, 'Salchichas Zenú', 10, 8000, TRUE, 10, 100, 20, 'Empaque', NULL, NULL, 50, 'salchichas_zenu.jpg'),
(1, 3, 9, 1, 'Manzanas Frescas', 29, 5000, TRUE, 20, 200, 40, 'Caja', 2, 1, 100, 'manzanas.jpg'),
(1, 3, 10, 1, 'Zanahorias Frescas', 29, 3000, TRUE, 20, 200, 40, 'Caja', 2, 1, 80, 'zanahorias.jpg'),
(1, 3, 11, 1, 'Almendras Nutresa', 29, 15000, FALSE, 10, 50, 15, 'Empaque', 2, 1, 30, 'almendras_nutresa.jpg'),
(1, 3, 12, 1, 'Orégano Ajinomoto', 17, 2000, FALSE, 20, 100, 30, 'Empaque', 3, 500, 60, 'oregano_ajinomoto.jpg'),
(1, 4, 13, 1, 'Pan Bimbo', 2, 3000, TRUE, 20, 200, 40, 'Empaque', NULL, NULL, 100, 'pan_bimbo.jpg'),
(1, 4, 14, 1, 'Croissant Ramo', 7, 5000, TRUE, 15, 150, 30, 'Caja', NULL, NULL, 70, 'croissant_ramo.jpg'),
(1, 4, 15, 1, 'Tarta Noel', 8, 15000, TRUE, 5, 50, 10, 'Caja', NULL, NULL, 25, 'tarta_noel.jpg'),
(1, 4, 16, 1, 'Galletas Super Ricas', 11, 4000, FALSE, 20, 200, 40, 'Empaque', NULL, NULL, 90, 'galletas_superricas.jpg'),
(1, 5, 17, 1, 'Agua Cristal', 4, 1500, FALSE, 30, 300, 60, 'Botella', 1, 1, 150, 'agua_cristal.jpg'),
(1, 5, 18, 1, 'Jugo Fruco', 23, 2500, FALSE, 20, 200, 40, 'Botella', 1, 1, 100, 'jugo_fruco.jpg'),
(1, 5, 19, 1, 'Coca-Cola', 5, 3000, FALSE, 30, 300, 60, 'Botella', 1, 1, 200, 'cocacola.jpg'),
(1, 5, 20, 1, 'Red Bull', 27, 7000, FALSE, 10, 100, 20, 'Botella', 1, 1, 50, 'redbull.jpg'),
(1, 5, 21, 1, 'Aguardiente Antioqueño', 15, 25000, FALSE, 5, 50, 10, 'Botella', 1, 1, 20, 'aguardiente.jpg'),
-- Categoría 2: Productos de Limpieza
(2, 6, 22, 1, 'Detergente La Constancia', 15, 8000, FALSE, 10, 100, 20, 'Empaque', 2, 1, 50, 'detergente_constancia.jpg'),
(2, 6, 23, 1, 'Desinfectante Familia', 16, 6000, FALSE, 10, 100, 20, 'Botella', 1, 1, 40, 'desinfectante_familia.jpg'),
(2, 6, 24, 1, 'Limpiador Baño Familia', 16, 5000, FALSE, 10, 100, 20, 'Botella', 1, 1, 30, 'limpiador_bano.jpg'),
(2, 6, 25, 1, 'Limpiavidrios Familia', 16, 4000, FALSE, 10, 100, 20, 'Botella', 1, 1, 35, 'limpiavidrios.jpg'),
(2, 7, 26, 1, 'Suavizante Familia', 16, 7000, FALSE, 10, 100, 20, 'Botella', 1, 1, 45, 'suavizante_familia.jpg'),
(2, 7, 27, 1, 'Quitamanchas Familia', 16, 6000, FALSE, 10, 100, 20, 'Botella', 1, 1, 40, 'quitamanchas.jpg'),
(2, 7, 28, 1, 'Blanqueador Familia', 16, 5000, FALSE, 10, 100, 20, 'Botella', 1, 1, 30, 'blanqueador.jpg'),
(2, 7, 29, 1, 'Almidón Familia', 16, 3000, FALSE, 10, 100, 20, 'Empaque', 2, 1, 25, 'almidon.jpg'),
(2, 8, 30, 1, 'Bolsas de Basura Familia', 16, 4000, FALSE, 20, 200, 40, 'Empaque', NULL, NULL, 100, 'bolsas_basura.jpg'),
(2, 8, 31, 1, 'Servilletas Familia', 16, 2500, FALSE, 20, 200, 40, 'Empaque', NULL, NULL, 120, 'servilletas.jpg'),
(2, 8, 32, 1, 'Toallas de Papel Familia', 16, 5000, FALSE, 20, 200, 40, 'Empaque', NULL, NULL, 80, 'toallas_papel.jpg'),
(2, 8, 33, 1, 'Platos Desechables Familia', 16, 6000, FALSE, 20, 200, 40, 'Empaque', NULL, NULL, 90, 'platos_desechables.jpg'),
-- Categoría 3: Higiene y Cuidado Personal
(3, 9, 34, 1, 'Champú Nestlé', 27, 10000, FALSE, 10, 100, 20, 'Botella', 1, 1, 50, 'champu_nestle.jpg'),
(3, 9, 35, 1, 'Acondicionador Nestlé', 27, 9000, FALSE, 10, 100, 20, 'Botella', 1, 1, 45, 'acondicionador_nestle.jpg'),
(3, 9, 36, 1, 'Gel Nestlé', 27, 7000, FALSE, 10, 100, 20, 'Botella', 1, 1, 40, 'gel_nestle.jpg'),
(3, 9, 37, 1, 'Tinte Nestlé', 27, 15000, FALSE, 5, 50, 10, 'Caja', NULL, NULL, 25, 'tinte_nestle.jpg'),
(3, 10, 38, 1, 'Jabón Nestlé', 27, 3000, FALSE, 20, 200, 40, 'Empaque', NULL, NULL, 100, 'jabon_nestle.jpg'),
(3, 10, 39, 1, 'Crema Nestlé', 27, 12000, FALSE, 10, 100, 20, 'Empaque', NULL, NULL, 50, 'crema_nestle.jpg'),
(3, 10, 40, 1, 'Protector Solar Nestlé', 27, 20000, FALSE, 5, 50, 10, 'Botella', 1, 1, 20, 'protector_solar.jpg'),
(3, 10, 41, 1, 'Exfoliante Nestlé', 27, 15000, FALSE, 5, 50, 10, 'Empaque', NULL, NULL, 25, 'exfoliante_nestle.jpg'),
(3, 11, 42, 1, 'Pasta Dental Nestlé', 27, 5000, FALSE, 20, 200, 40, 'Empaque', NULL, NULL, 100, 'pasta_dental.jpg'),
(3, 11, 43, 1, 'Enjuague Nestlé', 27, 8000, FALSE, 10, 100, 20, 'Botella', 1, 1, 50, 'enjuague_nestle.jpg'),
(3, 11, 44, 1, 'Cepillo Dental Nestlé', 27, 3000, FALSE, 20, 200, 40, 'Empaque', NULL, NULL, 80, 'cepillo_nestle.jpg'),
(3, 11, 45, 1, 'Hilo Dental Nestlé', 27, 4000, FALSE, 20, 200, 40, 'Empaque', NULL, NULL, 90, 'hilo_dental.jpg'),
(3, 12, 46, 1, 'Toallas Sanitarias Nestlé', 27, 6000, FALSE, 20, 200, 40, 'Empaque', NULL, NULL, 100, 'toallas_sanitarias.jpg'),
(3, 12, 47, 1, 'Tampones Nestlé', 27, 7000, FALSE, 20, 200, 40, 'Empaque', NULL, NULL, 80, 'tampones_nestle.jpg'),
(3, 12, 48, 1, 'Copa Menstrual Nestlé', 27, 30000, FALSE, 5, 50, 10, 'Empaque', NULL, NULL, 20, 'copa_menstrual.jpg'),
(3, 12, 49, 1, 'Toallas Húmedas Nestlé', 27, 5000, FALSE, 20, 200, 40, 'Empaque', NULL, NULL, 90, 'toallas_humedas.jpg'),
-- Categoría 4: Mascotas
(4, 13, 50, 1, 'Croquetas para Perros Nestlé', 27, 20000, FALSE, 10, 100, 20, 'Empaque', 2, 1, 50, 'croquetas_perros.jpg'),
(4, 13, 51, 1, 'Alimento Húmedo Gatos Nestlé', 27, 3000, TRUE, 20, 200, 40, 'Empaque', NULL, NULL, 100, 'alimento_gatos.jpg'),
(4, 13, 52, 1, 'Alpiste Nestlé', 27, 5000, FALSE, 10, 100, 20, 'Empaque', 2, 1, 40, 'alpiste.jpg'),
(4, 13, 53, 1, 'Alimento Roedores Nestlé', 27, 6000, FALSE, 10, 100, 20, 'Empaque', 2, 1, 30, 'alimento_roedores.jpg'),
(4, 14, 54, 1, 'Champú Mascotas Nestlé', 27, 10000, FALSE, 10, 100, 20, 'Botella', 1, 1, 50, 'champu_mascotas.jpg'),
(4, 14, 55, 1, 'Antipulgas Nestlé', 27, 15000, FALSE, 5, 50, 10, 'Empaque', NULL, NULL, 20, 'antipulgas.jpg'),
(4, 14, 56, 1, 'Arena Gatos Nestlé', 27, 12000, FALSE, 10, 100, 20, 'Empaque', 2, 1, 40, 'arena_gatos.jpg'),
(4, 14, 57, 1, 'Pañales Mascotas Nestlé', 27, 8000, FALSE, 10, 100, 20, 'Empaque', NULL, NULL, 30, 'pañales_mascotas.jpg'),
(4, 15, 58, 1, 'Pelota Mascotas Nestlé', 27, 3000, FALSE, 20, 200, 40, 'Empaque', NULL, NULL, 100, 'pelota_mascotas.jpg'),
(4, 15, 59, 1, 'Collar Nestlé', 27, 5000, FALSE, 10, 100, 20, 'Empaque', NULL, NULL, 50, 'collar_nestle.jpg'),
(4, 15, 60, 1, 'Cama Mascotas Nestlé', 27, 25000, FALSE, 5, 50, 10, 'Empaque', NULL, NULL, 20, 'cama_mascotas.jpg'),
(4, 15, 61, 1, 'Plato Mascotas Nestlé', 27, 4000, FALSE, 10, 100, 20, 'Empaque', NULL, NULL, 40, 'plato_mascotas.jpg'),
-- Categoría 5: Hogar y Ferretería
(5, 16, 62, 1, 'Licuadora Corona', 30, 80000, FALSE, 5, 50, 10, 'Caja', NULL, NULL, 20, 'licuadora_corona.jpg'),
(5, 16, 63, 1, 'Tostadora Corona', 30, 50000, FALSE, 5, 50, 10, 'Caja', NULL, NULL, 15, 'tostadora_corona.jpg'),
(5, 16, 64, 1, 'Microondas Corona', 30, 200000, FALSE, 2, 20, 5, 'Caja', NULL, NULL, 10, 'microondas_corona.jpg'),
(5, 16, 65, 1, 'Cafetera Oma', 25, 60000, FALSE, 5, 50, 10, 'Caja', NULL, NULL, 25, 'cafetera_oma.jpg'),
(5, 17, 66, 1, 'Destornillador Corona', 30, 10000, FALSE, 10, 100, 20, 'Empaque', NULL, NULL, 50, 'destornillador_corona.jpg'),
(5, 17, 67, 1, 'Martillo Corona', 30, 15000, FALSE, 10, 100, 20, 'Empaque', NULL, NULL, 40, 'martillo_corona.jpg'),
(5, 17, 68, 1, 'Taladro Corona', 30, 80000, FALSE, 5, 50, 10, 'Caja', NULL, NULL, 20, 'taladro_corona.jpg'),
(5, 17, 69, 1, 'Llave Inglesa Corona', 30, 20000, FALSE, 10, 100, 20, 'Empaque', NULL, NULL, 30, 'llave_corona.jpg'),
(5, 18, 70, 1, 'Cuadro Decorativo Corona', 30, 30000, FALSE, 5, 50, 10, 'Empaque', NULL, NULL, 25, 'cuadro_corona.jpg'),
(5, 18, 71, 1, 'Organizador Corona', 30, 15000, FALSE, 10, 100, 20, 'Empaque', NULL, NULL, 40, 'organizador_corona.jpg'),
(5, 18, 72, 1, 'Alfombra Corona', 30, 50000, FALSE, 5, 50, 10, 'Empaque', NULL, NULL, 20, 'alfombra_corona.jpg'),
(5, 18, 73, 1, 'Cortina Corona', 30, 40000, FALSE, 5, 50, 10, 'Empaque', NULL, NULL, 15, 'cortina_corona.jpg'),
-- Categoría 6: Bebés y Niños
(6, 19, 74, 1, 'Leche Infantil Nestlé', 27, 25000, FALSE, 10, 100, 20, 'Empaque', 2, 1, 50, 'leche_infantil.jpg'),
(6, 19, 75, 1, 'Cereal Nestlé', 27, 15000, FALSE, 10, 100, 20, 'Empaque', 2, 1, 40, 'cereal_nestle.jpg'),
(6, 19, 76, 1, 'Compota Nestlé', 27, 3000, TRUE, 20, 200, 40, 'Empaque', NULL, NULL, 100, 'compota_nestle.jpg'),
(6, 20, 77, 1, 'Pañales Nestlé', 27, 20000, FALSE, 10, 100, 20, 'Empaque', NULL, NULL, 50, 'pañales_nestle.jpg'),
(6, 20, 78, 1, 'Toallitas Nestlé', 27, 8000, FALSE, 20, 200, 40, 'Empaque', NULL, NULL, 100, 'toallitas_nestle.jpg'),
(6, 20, 79, 1, 'Crema Rozaduras Nestlé', 27, 10000, FALSE, 10, 100, 20, 'Empaque', NULL, NULL, 40, 'crema_rozaduras.jpg'),
-- Categoría 7: Papelería y Oficina
(7, 22, 80, 1, 'Cuaderno Norma', 29, 5000, FALSE, 20, 200, 40, 'Empaque', NULL, NULL, 100, 'cuaderno_norma.jpg'),
(7, 22, 81, 1, 'Bolígrafo Norma', 29, 1000, FALSE, 50, 500, 100, 'Empaque', NULL, NULL, 200, 'boligrafo_norma.jpg'),
(7, 22, 82, 1, 'Marcadores Norma', 29, 3000, FALSE, 20, 200, 40, 'Empaque', NULL, NULL, 80, 'marcadores_norma.jpg'),
(7, 22, 83, 1, 'Mochila Norma', 29, 30000, FALSE, 5, 50, 10, 'Empaque', NULL, NULL, 20, 'mochila_norma.jpg');

-- Poblar tabla tab_prod_prov (relación productos-proveedores)
INSERT INTO tab_prod_prov (
    id_categoria, id_subcategoria, id_subcategoria3, id_producto, id_proveedores, id_prod_prov
) VALUES
-- Categoría 1: Alimentos y Bebidas
(1, 1, 1, 1, 1, 1),   -- Leche Entera Alpina - Distribuidora Alimentos S.A.
(1, 1, 2, 1, 1, 2),   -- Yogur Natural Yogo Yogo - Distribuidora Alimentos S.A.
(1, 1, 3, 1, 1, 3),   -- Queso Colanta - Distribuidora Alimentos S.A.
(1, 1, 4, 1, 1, 4),   -- Mantequilla La Fazenda - Distribuidora Alimentos S.A.
(1, 2, 5, 1, 2, 5),   -- Carne de Res San Jorge - Carnes Premium Ltda.
(1, 2, 6, 1, 2, 6),   -- Carne de Cerdo Zenú - Carnes Premium Ltda.
(1, 2, 7, 1, 2, 7),   -- Pollo Ramo - Carnes Premium Ltda.
(1, 2, 8, 1, 2, 8),   -- Salchichas Zenú - Carnes Premium Ltda.
(1, 3, 9, 1, 3, 9),   -- Manzanas Frescas - Frutas del Valle SAS
(1, 3, 10, 1, 3, 10), -- Zanahorias Frescas - Frutas del Valle SAS
(1, 3, 11, 1, 1, 11), -- Almendras Nutresa - Distribuidora Alimentos S.A.
(1, 3, 12, 1, 1, 12), -- Orégano Ajinomoto - Distribuidora Alimentos S.A.
(1, 4, 13, 1, 4, 13), -- Pan Bimbo - Panadería La Espiga
(1, 4, 14, 1, 4, 14), -- Croissant Ramo - Panadería La Espiga
(1, 4, 15, 1, 4, 15), -- Tarta Noel - Panadería La Espiga
(1, 4, 16, 1, 4, 16), -- Galletas Super Ricas - Panadería La Espiga
(1, 5, 17, 1, 5, 17), -- Agua Cristal - Bebidas y Licores Express
(1, 5, 18, 1, 5, 18), -- Jugo Fruco - Bebidas y Licores Express
(1, 5, 19, 1, 5, 19), -- Coca-Cola - Bebidas y Licores Express
(1, 5, 20, 1, 5, 20), -- Red Bull - Bebidas y Licores Express
(1, 5, 21, 1, 5, 21), -- Aguardiente Antioqueño - Bebidas y Licores Express
-- Categoría 2: Productos de Limpieza
(2, 6, 22, 1, 6, 22), -- Detergente La Constancia - Limpieza Total SRL
(2, 6, 23, 1, 6, 23), -- Desinfectante Familia - Limpieza Total SRL
(2, 6, 24, 1, 6, 24), -- Limpiador Baño Familia - Limpieza Total SRL
(2, 6, 25, 1, 6, 25), -- Limpiavidrios Familia - Limpieza Total SRL
(2, 7, 26, 1, 7, 26), -- Suavizante Familia - Ropa Brillante S.A.
(2, 7, 27, 1, 7, 27), -- Quitamanchas Familia - Ropa Brillante S.A.
(2, 7, 28, 1, 7, 28), -- Blanqueador Familia - Ropa Brillante S.A.
(2, 7, 29, 1, 7, 29), -- Almidón Familia - Ropa Brillante S.A.
(2, 8, 30, 1, 8, 30), -- Bolsas de Basura Familia - Empaques Desechables S.A.
(2, 8, 31, 1, 8, 31), -- Servilletas Familia - Empaques Desechables S.A.
(2, 8, 32, 1, 8, 32), -- Toallas de Papel Familia - Empaques Desechables S.A.
(2, 8, 33, 1, 8, 33), -- Platos Desechables Familia - Empaques Desechables S.A.
-- Categoría 3: Higiene y Cuidado Personal
(3, 9, 34, 1, 9, 34), -- Champú Nestlé - Cuidado Personal Plus
(3, 9, 35, 1, 9, 35), -- Acondicionador Nestlé - Cuidado Personal Plus
(3, 9, 36, 1, 9, 36), -- Gel Nestlé - Cuidado Personal Plus
(3, 9, 37, 1, 9, 37), -- Tinte Nestlé - Cuidado Personal Plus
(3, 10, 38, 1, 9, 38), -- Jabón Nestlé - Cuidado Personal Plus
(3, 10, 39, 1, 9, 39), -- Crema Nestlé - Cuidado Personal Plus
(3, 10, 40, 1, 9, 40), -- Protector Solar Nestlé - Cuidado Personal Plus
(3, 10, 41, 1, 9, 41), -- Exfoliante Nestlé - Cuidado Personal Plus
(3, 11, 42, 1, 10, 42), -- Pasta Dental Nestlé - Distribuidora Higiene Oral
(3, 11, 43, 1, 10, 43), -- Enjuague Nestlé - Distribuidora Higiene Oral
(3, 11, 44, 1, 10, 44), -- Cepillo Dental Nestlé - Distribuidora Higiene Oral
(3, 11, 45, 1, 10, 45), -- Hilo Dental Nestlé - Distribuidora Higiene Oral
(3, 12, 46, 1, 11, 46), -- Toallas Sanitarias Nestlé - Feminine Care Solutions
(3, 12, 47, 1, 11, 47), -- Tampones Nestlé - Feminine Care Solutions
(3, 12, 48, 1, 11, 48), -- Copa Menstrual Nestlé - Feminine Care Solutions
(3, 12, 49, 1, 11, 49), -- Toallas Húmedas Nestlé - Feminine Care Solutions
-- Categoría 4: Mascotas
(4, 13, 50, 1, 12, 50), -- Croquetas para Perros Nestlé - Mascotas Felices Ltda.
(4, 13, 51, 1, 12, 51), -- Alimento Húmedo Gatos Nestlé - Mascotas Felices Ltda.
(4, 13, 52, 1, 12, 52), -- Alpiste Nestlé - Mascotas Felices Ltda.
(4, 13, 53, 1, 12, 53), -- Alimento Roedores Nestlé - Mascotas Felices Ltda.
(4, 14, 54, 1, 12, 54), -- Champú Mascotas Nestlé - Mascotas Felices Ltda.
(4, 14, 55, 1, 12, 55), -- Antipulgas Nestlé - Mascotas Felices Ltda.
(4, 14, 56, 1, 12, 56), -- Arena Gatos Nestlé - Mascotas Felices Ltda.
(4, 14, 57, 1, 12, 57), -- Pañales Mascotas Nestlé - Mascotas Felices Ltda.
(4, 15, 58, 1, 13, 58), -- Pelota Mascotas Nestlé - Accesorios para Mascotas Express
(4, 15, 59, 1, 13, 59), -- Collar Nestlé - Accesorios para Mascotas Express
(4, 15, 60, 1, 13, 60), -- Cama Mascotas Nestlé - Accesorios para Mascotas Express
(4, 15, 61, 1, 13, 61), -- Plato Mascotas Nestlé - Accesorios para Mascotas Express
-- Categoría 5: Hogar y Ferretería
(5, 16, 62, 1, 14, 62), -- Licuadora Corona - Electrodomésticos Hogar SAS
(5, 16, 63, 1, 14, 63), -- Tostadora Corona - Electrodomésticos Hogar SAS
(5, 16, 64, 1, 14, 64), -- Microondas Corona - Electrodomésticos Hogar SAS
(5, 16, 65, 1, 14, 65), -- Cafetera Oma - Electrodomésticos Hogar SAS
(5, 17, 66, 1, 15, 66), -- Destornillador Corona - Ferretería y Herramientas SAS
(5, 17, 67, 1, 15, 67), -- Martillo Corona - Ferretería y Herramientas SAS
(5, 17, 68, 1, 15, 68), -- Taladro Corona - Ferretería y Herramientas SAS
(5, 17, 69, 1, 15, 69), -- Llave Inglesa Corona - Ferretería y Herramientas SAS
(5, 18, 70, 1, 16, 70), -- Cuadro Decorativo Corona - Decoraciones y Diseño Hogar
(5, 18, 71, 1, 16, 71), -- Organizador Corona - Decoraciones y Diseño Hogar
(5, 18, 72, 1, 16, 72), -- Alfombra Corona - Decoraciones y Diseño Hogar
(5, 18, 73, 1, 16, 73), -- Cortina Corona - Decoraciones y Diseño Hogar
-- Categoría 6: Bebés y Niños
(6, 19, 74, 1, 17, 74), -- Leche Infantil Nestlé - Alimentos Infantiles NutriKids
(6, 19, 75, 1, 17, 75), -- Cereal Nestlé - Alimentos Infantiles NutriKids
(6, 19, 76, 1, 17, 76), -- Compota Nestlé - Alimentos Infantiles NutriKids
(6, 20, 77, 1, 18, 77), -- Pañales Nestlé - Pañales y Bebés Care
(6, 20, 78, 1, 18, 78), -- Toallitas Nestlé - Pañales y Bebés Care
(6, 20, 79, 1, 18, 79), -- Crema Rozaduras Nestlé - Pañales y Bebés Care
-- Categoría 7: Papelería y Oficina
(7, 22, 80, 1, 20, 80), -- Cuaderno Norma - Papelería y Oficina Express
(7, 22, 81, 1, 20, 81), -- Bolígrafo Norma - Papelería y Oficina Express
(7, 22, 82, 1, 20, 82), -- Marcadores Norma - Papelería y Oficina Express
(7, 22, 83, 1, 20, 83); -- Mochila Norma - Papelería y Oficina Express

CREATE VIEW vista_kardex AS
SELECT k.id, 
       p.nom_producto, 
       k.tipo_movimiento, 
       k.cantidad_movimiento, 
       k.fecha_movimiento 
FROM tab_kardex k
INNER JOIN tab_productos p 
    ON k.id_producto = p.id_producto 
    AND k.id_categoria = p.id_categoria 
    AND k.id_subcategoria = p.id_subcategoria 
    AND k.id_subcategoria3 = p.id_subcategoria3;
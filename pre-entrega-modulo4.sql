--Creamos la base de datos
create database retail_project;

--Creamos el schema donde estan todas nuestras tablas
create schema retail;

-- Tabla clientes
CREATE TABLE clientes (
    id_clientes SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    edad INT NOT NULL CHECK (edad > 18)
);

-- Creamos la tabla categorias
CREATE TABLE categorias (
    id_categoria SERIAL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL
);

-- Tabla productos
CREATE TABLE productos (
    id_productos SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    id_categoria INT NOT NULL,
    precio DECIMAL(10,2) NOT NULL CHECK (precio > 0),
    stock INT NOT NULL CHECK (stock > 0),
    FOREIGN KEY (id_categoria)
        REFERENCES categorias (id_categoria)
);

-- Tabla ventas
CREATE TABLE ventas (
    id_venta SERIAL PRIMARY KEY,
    id_productos INT NOT NULL,
    id_clientes INT NOT NULL,
    FOREIGN KEY (id_productos)
        REFERENCES productos (id_productos),
    FOREIGN KEY (id_clientes)
        REFERENCES clientes (id_clientes)
);


BEGIN;

-- Insertamos 5 clientes
INSERT INTO clientes (nombre, email, edad)
VALUES
    ('Juan Perez', 'juan.perez@gmail.com', 30),
    ('Maria Gonzalez', 'maria.gonzalez@gmail.com', 25),
    ('Carlos Lopez', 'carlos.lopez@gmail.com', 35),
    ('Ana Martinez', 'ana.martinez@gmail.com', 28),
    ('Lucia Rodriguez', 'lucia.rodriguez@gmail.com', 22);


-- Insertamos las categorias
INSERT INTO categorias (nombre)
VALUES
    ('Accesorios'),
    ('Monitores'),
    ('Audio');

-- Insertamos 5 productos
INSERT INTO productos (nombre, id_categoria, precio, stock)
VALUES
    ('Teclado mecanico', 1, 45000.00, 15),
    ('Mouse inalambrico', 1, 25000.00, 20),
    ('Monitor 24 pulgadas', 2, 180000.00, 10),
    ('Auriculares Bluetooth', 3, 55000.00, 25),
    ('Webcam HD', 1, 35000.00, 12);


-- Insertamos 5 ventas
INSERT INTO ventas (id_productos, id_clientes)
VALUES
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 5);

COMMIT;

ALTER TABLE retail.ventas
ADD COLUMN fecha_venta DATE DEFAULT CURRENT_DATE;

-- Rentabilidad por categoría
-- Permite identificar qué categorías generan mayores ingresos y volumen de ventas.
SELECT c.nombre AS categoria, COUNT(v.id_venta) AS unidades_vendidas, SUM(p.precio) AS ingreso_total
FROM ventas v
INNER JOIN productos p ON v.id_productos = p.id_productos
INNER JOIN categorias c ON p.id_categoria = c.id_categoria
GROUP BY c.nombre
HAVING COUNT(v.id_venta) > 1
ORDER BY ingreso_total DESC;


-- Clientes sin compras
-- Permite detectar clientes registrados que todavía no realizaron compras para diseñar estrategias de marketing
-- y promociones que incentiven su primera compra.
SELECT c.id_clientes, c.nombre, COALESCE(COUNT(v.id_venta), 0) AS total_compras
FROM clientes c
LEFT JOIN ventas v ON c.id_clientes = v.id_clientes
GROUP BY c.id_clientes, c.nombre
HAVING COUNT(v.id_venta) = 0;


--Top de compras por cliente
-- Permite conocer qué productos compra más cada cliente y cuándo realizó su última compra para personalizar ofertas 
-- y fortalecer la fidelización.
SELECT c.nombre AS cliente, p.nombre AS producto, COUNT(v.id_venta) AS veces_comprado, MAX(v.fecha_venta) AS ultima_transaccion
FROM retail.clientes c
INNER JOIN retail.ventas v
    ON c.id_clientes = v.id_clientes
INNER JOIN retail.productos p
    ON v.id_productos = p.id_productos
GROUP BY c.id_clientes, c.nombre, p.id_productos, p.nombre
ORDER BY c.nombre,
    veces_comprado DESC, ultima_transaccion DESC;

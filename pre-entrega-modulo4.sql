

-- 1. CREACIÓN DE BASE DE DATOS

CREATE DATABASE retail_project;

-- 2. CREACIÓN DEL SCHEMA


CREATE SCHEMA retail;

-- 3. CREACIÓN DE TABLAS


-- Tabla clientes
CREATE TABLE retail.clientes (
    id_clientes SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    edad INT NOT NULL CHECK (edad > 18)
);

-- Tabla categorias
CREATE TABLE retail.categorias (
    id_categoria SERIAL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL
);

-- Tabla productos
CREATE TABLE retail.productos (
    id_productos SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    id_categoria INT NOT NULL,
    precio DECIMAL(10,2) NOT NULL CHECK (precio > 0),
    stock INT NOT NULL CHECK (stock > 0),

    FOREIGN KEY (id_categoria)
        REFERENCES retail.categorias (id_categoria)
);

-- Tabla ventas
CREATE TABLE retail.ventas (
    id_venta SERIAL PRIMARY KEY,
    id_productos INT NOT NULL,
    id_clientes INT NOT NULL,
    fecha_venta DATE DEFAULT CURRENT_DATE,

    FOREIGN KEY (id_productos)
        REFERENCES retail.productos (id_productos),

    FOREIGN KEY (id_clientes)
        REFERENCES retail.clientes (id_clientes)
);

-- 4. INSERCIÓN DE DATOS

BEGIN;

-- Insertamos 5 clientes
INSERT INTO retail.clientes (nombre, email, edad)
VALUES
    ('Juan Perez', 'juan.perez@gmail.com', 30),
    ('Maria Gonzalez', 'maria.gonzalez@gmail.com', 25),
    ('Carlos Lopez', 'carlos.lopez@gmail.com', 35),
    ('Ana Martinez', 'ana.martinez@gmail.com', 28),
    ('Lucia Rodriguez', 'lucia.rodriguez@gmail.com', 22);

-- Insertamos las categorias
INSERT INTO retail.categorias (nombre)
VALUES
    ('Accesorios'),
    ('Monitores'),
    ('Audio');

-- Insertamos 5 productos
INSERT INTO retail.productos (nombre, id_categoria, precio, stock)
VALUES
    ('Teclado mecanico', 1, 45000.00, 15),
    ('Mouse inalambrico', 1, 25000.00, 20),
    ('Monitor 24 pulgadas', 2, 180000.00, 10),
    ('Auriculares Bluetooth', 3, 55000.00, 25),
    ('Webcam HD', 1, 35000.00, 12);

-- Insertamos 5 ventas
INSERT INTO retail.ventas (id_productos, id_clientes)
VALUES
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 5);

COMMIT;

-- 5. CONSULTAS SQL

-- Rentabilidad por categoría
-- Identifica qué categorías generan mayores ingresos
-- y volumen de ventas.


-- Se utiliza HAVING COUNT(v.id_venta) > 1 para considerar
-- únicamente categorías con más de una venta.
-- Este umbral permite enfocar el análisis en categorías
-- que presentan cierta recurrencia comercial, evitando
-- considerar categorías con una única operación.
--
-- El umbral es una decisión analítica para este ejercicio
-- y puede modificarse según los objetivos del negocio.

SELECT
    c.nombre AS categoria,
    COUNT(v.id_venta) AS unidades_vendidas,
    SUM(p.precio) AS ingreso_total
FROM retail.ventas v
INNER JOIN retail.productos p
    ON v.id_productos = p.id_productos
INNER JOIN retail.categorias c
    ON p.id_categoria = c.id_categoria
GROUP BY c.nombre
HAVING COUNT(v.id_venta) > 1
ORDER BY ingreso_total DESC;


-- Clientes sin compras
-- Detecta clientes registrados que todavía no realizaron compras.

SELECT
    c.id_clientes,
    c.nombre,
    COUNT(v.id_venta) AS total_compras
FROM retail.clientes c
LEFT JOIN retail.ventas v
    ON c.id_clientes = v.id_clientes
GROUP BY c.id_clientes, c.nombre
HAVING COUNT(v.id_venta) = 0;

-- Top de compras por cliente
-- Identifica el producto más comprado por cada cliente
-- y muestra la fecha de su última compra.

SELECT
    cliente,
    producto,
    veces_comprado,
    ultima_transaccion
FROM (
    SELECT
        c.id_clientes,
        c.nombre AS cliente,
        p.nombre AS producto,
        COUNT(v.id_venta) AS veces_comprado,
        MAX(v.fecha_venta) AS ultima_transaccion,

        ROW_NUMBER() OVER (
            PARTITION BY c.id_clientes
            ORDER BY
                COUNT(v.id_venta) DESC,
                MAX(v.fecha_venta) DESC,
                p.id_productos ASC
        ) AS rn

    FROM retail.clientes c

    INNER JOIN retail.ventas v
        ON c.id_clientes = v.id_clientes

    INNER JOIN retail.productos p
        ON v.id_productos = p.id_productos

    GROUP BY
        c.id_clientes,
        c.nombre,
        p.id_productos,
        p.nombre

) AS t

WHERE rn = 1

ORDER BY cliente;



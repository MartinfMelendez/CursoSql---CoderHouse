--Creamos la base de datos
create database Coderhouse;

--Creamos el schema donde estan todas nuestras tablas
create schema retail;

--Creamos la tabla clientes
create table clientes (
id_clientes SERIAL primary key,
nombre varchar(100) not null,
email varchar(100) unique not null);

--Creamos la tabla productos
create table productos(
id_productos SERIAL primary key,
nombre varchar(100) not null,
precio decimal check(precio > 0),
stock int check (stock > 0)
);

--Creamos la tabla ventas
create table ventas(
id_venta SERIAL primary key,
id_productos int,
id_clientes int,
foreign key (id_productos) references productos (id_productos),
foreign key (id_clientes) references clientes (id_clientes));



begin;
	--Insertamos 5 registros en la tabla clientes
INSERT INTO clientes (nombre, email) 
VALUES
('Juan Perez', 'juan.perez@gmail.com'),
('Maria Gonzalez', 'maria.gonzalez@gmail.com'),
('Carlos Lopez', 'carlos.lopez@gmail.com'),
('Ana Martinez', 'ana.martinez@gmail.com'),
('Lucia Rodriguez', 'lucia.rodriguez@gmail.com');
	commit;



begin;
-- 5 productos
INSERT INTO productos (nombre, precio, stock) VALUES
('Teclado mecanico', 45000.00, 15),
('Mouse inalambrico', 25000.00, 20),
('Monitor 24 pulgadas', 180000.00, 10),
('Auriculares Bluetooth', 55000.00, 25),
('Webcam HD', 35000.00, 12);
commit;

begin;
-- 5 ventas
INSERT INTO ventas (id_productos, id_clientes) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);
commit;

--Verificamos que el where traiga los datos que realmente vamos a modificar
select precio * 1.10 from productos 
where precio <= 45000

--Realizamos la actualizacion de los precios de los productos correspondientes
begin;
update productos
set precio = precio * 1.10
where precio <= 45000
commit;

--Buscamos el id de Juan Perez
select id_clientes, nombre from clientes c
where c.nombre  = 'Juan Perez'

--Eliminamos utilizando el id
begin;
delete from clientes
where id_clientes = 1 
commit;
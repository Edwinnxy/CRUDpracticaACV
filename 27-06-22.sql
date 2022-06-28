create database DBVentas

use DBVentas

create table Cliente(
id_cli int identity (1,1) not null primary key,
nombre_cli varchar(20),
apellido_cli varchar(20),
correo_cli varchar(20),
direccion_cli varchar(20),
telefono_cli nvarchar(20)
);

create table Venta(
id_venta int identity (1,1) not null primary key,
id_cli int not null,
id_prod int not null,
cantidad int,
fecha date,
total_venta decimal(11,2),
CONSTRAINT fk_cliente FOREIGN KEY (id_cli) REFERENCES Cliente(id_cli),
);
alter table Venta
  add constraint fk_produ_venta
  foreign key (id_prod)
  references Producto (id_prod);



create table Categoria(
id_catego int identity (1,1) not null primary key,
nombre varchar(50),
descripcion varchar(250),
)

create table Producto(
id_prod int identity (1,1) primary key,
id_catego int not null,
nombre_pro varchar (50),
precio decimal (11,2),
stock int,
descripcion varchar(250)

CONSTRAINT fk_categorio FOREIGN KEY (id_catego) REFERENCES Categoria(id_catego)
);


create table Detalle_Venta(
id_detalleventa int identity (1,1) not null primary key,
id_venta int not null,
id_prod int not null,
id_cli int not null,
cantidad int,
precio decimal (11,2)

CONSTRAINT fk_venta FOREIGN KEY (id_venta) REFERENCES Venta(id_venta),
);

---PROCEDIMINETOS ALMACENADOS
go
CREATE PROCEDURE SP_insercion_de_Cliente (
@nombre varchar(20),
@apellido varchar(20),
@correo varchar(20),
@direccion varchar(20),
@telefono nvarchar(20)
)as
begin
insert into Cliente (nombre_cli,apellido_cli,correo_cli,direccion_cli,telefono_cli)
values(@nombre,@apellido,@correo,@direccion,@telefono)
end

exec SP_insercion_de_Cliente 'Hugo','Carrion','ejem2131@gmail.com',' Av Nicolás de Piérola N° 589',996436781
select * from Cliente

go
CREATE PROCEDURE SP_actualizar_Cliente
@id_cli int,
@nombre varchar(20),
@apellido varchar(20),
@correo varchar(20),
@direccion varchar(20),
@telefono nvarchar(20)
as
update Cliente set 
nombre_cli=@nombre,
apellido_cli=@apellido,
correo_cli=@correo,
direccion_cli=@direccion,
telefono_cli=@telefono where id_cli=@id_cli;

exec SP_actualizar_Cliente 4,'Hugo','Luja','ejem123@gmail.com','Av Nicolás de Piérola',966436789


go
CREATE PROCEDURE SP_eliminar_Cliente(
@id_cli int)
as
delete from Cliente where id_cli=@id_cli

exec SP_eliminar_Cliente 3


go
CREATE PROCEDURE SP_insercion_de_Categoria (
@nombre varchar(20),
@descripcion varchar(250)
)as
begin
insert into Categoria(nombre,descripcion)
values(@nombre,@descripcion)
end

exec SP_insercion_de_Categoria 'Ropa','prendas de vestir. Se trata de productos confeccionados 
con distintas clases de tejidos para cubrirse el cuerpo y abrigarse.'
select * from Categoria

go
CREATE PROCEDURE SP_actualizar_Categoria
@id_catego int,
@nombre varchar(20),
@descripcion varchar(250)
as
update Categoria set 
nombre=@nombre,
descripcion=@descripcion
where id_catego=@id_catego;

exec SP_actualizar_Categoria 4,'Ropa','Las personas se visten de diferente manera de acuerdo a la ocasión, el clima y su estado de ánimo.'

go
CREATE PROCEDURE SP_eliminar_Categoria(
@id_catego int)
as
delete from Categoria where id_catego=@id_catego
exec SP_eliminar_Categoria 2

go
CREATE PROCEDURE SP_insercion_de_Producto (
@id_catego int,
@nombre varchar(20),
@precio decimal(11,2),
@stock int,
@descripcion varchar(250)
)as
begin
insert into Producto(id_catego,nombre_pro,precio,stock,descripcion)
values(@id_catego,@nombre,@precio,@stock,@descripcion)
end

exec SP_insercion_de_Producto 4,'polo',40,22,'renda de punto para el tronco que tiene la 
misma forma que una camiseta o playera, pero además tiene cuello.'

select * from Producto

go
CREATE PROCEDURE SP_actualizar_Producto
@id_prod int,
@id_catego int,
@nombre varchar(50),
@precio decimal(11,2),
@stock int,
@descripcion varchar(250)
as
update Producto set 
id_catego=@id_catego,
nombre_pro=@nombre,
precio=@precio,
stock=@stock,
descripcion=@descripcion
where id_prod=@id_prod;

exec SP_actualizar_Producto 4,4,'Camisa',45,82,'Prenda de vestir de tela que cubre el torso , abotonada por delante , generalmente con cuello y mangas '

go
CREATE PROCEDURE SP_eliminar_Producto(
@id_prod int)
as
delete from Producto where id_prod=@id_prod
exec SP_eliminar_Producto 2

go
CREATE PROCEDURE SP_insercion_de_Venta (
@id_cli int,
@total decimal(11,2),
@id_pro int,
@cantidad int
)as
begin
insert into Venta(id_cli,fecha,total_venta,id_prod,cantidad)
values(@id_cli,getdate(),@total,@id_pro,@cantidad)
end

EXEC SP_insercion_de_Venta 2,90,4,7


drop procedure SP_insercion_de_Venta



select * from Categoria
select * from Producto
select * from Venta


---TRIGGERS
---resta de stock con cantidad de venta
go
CREATE TRIGGER Realizar_Venta 
ON Venta FOR INSERT AS 
BEGIN 
DECLARE @producto AS INT
DECLARE @cantidad AS INT

SET @producto = (SELECT id_prod FROM INSERTED)
SET @cantidad = (SELECT cantidad FROM INSERTED)

UPDATE Producto
SET stock = stock - @cantidad
WHERE id_prod LIKE @producto
end 

exec SP_insercion_de_Venta 1,27,1,1




SELECT * FROM Venta
select * from Producto
---NO SOBREPASAR EL STOCK
go
CREATE TRIGGER Stock_disponible
ON Producto FOR UPDATE AS
IF (SELECT stock FROM INSERTED) < 0
Begin
PRINT 'STOCK NO DISPONIBLE'
ROLLBACK
END
---COPIA DETALLE DE VETA
go
CREATE TRIGGER COPIA_DETALLEDEVENTA 
ON Venta FOR INSERT AS 
BEGIN 
DECLARE @producto AS INT
DECLARE @cantidad AS INT
DECLARE @id_venta AS INT
DECLARE @id_cli AS INT
DECLARE @precio AS DECIMAL(11,2)

SET @producto = (SELECT id_prod FROM INSERTED)
SET @cantidad = (SELECT cantidad FROM INSERTED)
SET @id_venta = (SELECT id_venta FROM INSERTED)
SET @id_cli = (SELECT id_cli FROM INSERTED)
SET @precio = (SELECT total_venta FROM INSERTED)

insert into Detalle_venta(id_venta,id_prod,id_cli,cantidad,precio)
values(@id_venta,@producto,@id_cli,@cantidad,@precio)
end 

SELECT * FROM Venta
select * from Producto
select * from Detalle_Venta
select * from Categoria
select * from Cliente

exec SP_insercion_de_Venta 2,9,4,2
exec SP_insercion_de_Producto 3,Microonda,10,15,'dasdasdafasgdssjsldlk'

---FUNCION DE TOTAL GASTOS
go
CREATE FUNCTION totalgastosdecliente(@id_cli int) RETURNS Decimal(11,2)
AS
BEGIN
DECLARE @totalgastos decimal(11,2)
SELECT @totalgastos = SUM(precio) FROM Detalle_Venta WHERE id_cli=@id_cli
RETURN @totalgastos 

end
SELECT nombre_cli as Nombre ,dbo.totalgastosdecliente(2) as total_gastos FROM Cliente WHERE id_cli=2

----FUNCION DEL TOTAL DE COMPRAS DE UN CLIENTE
go
CREATE FUNCTION totalcompras(@id_cli int) RETURNS int
AS
BEGIN
DECLARE @totalcompras int
SELECT @totalcompras = COUNT(id_cli) FROM Detalle_Venta WHERE id_cli=@id_cli
RETURN @totalcompras 
end

SELECT nombre_cli as Nombre ,dbo.totalcompras(1) as total_compras FROM Cliente WHERE id_cli=1



---BACKUP

BACKUP DATABASE DBVentas TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\respaldoDBVentas.bak';
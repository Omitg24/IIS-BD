--GUIÓN 1

--Ejercicio 1
-- Realizar una consulta básica en SQL que devuelva todos los datos sobre los coches que están
-- almacenados en la tabla coches
SELECT * FROM COCHES;

--Ejercicio 2
-- Realizar una consulta básica en SQL que devuelva todos los datos sobre los coches cuyo
-- modelo sea ‘gtd’ que están almacenados en la tabla coches.
SELECT * FROM COCHES WHERE MODELO='gtd';

--Ejercicio 3
-- Insertar un coche en la tabla coches
INSERT INTO COCHES (CODCOCHE, NOMBRECH, MODELO) values ('21', 'Clio', '1.5');

--Ejercicio 4
-- Eliminar un coche de la tabla coches
DELETE FROM COCHES WHERE CODCOCHE = '21';

--Ejercicio 5
-- Actualizar o modificar los datos de un coche de la tabla coches.
UPDATE COCHES SET MODELO='1.8' WHERE CODCOCHE = '21';


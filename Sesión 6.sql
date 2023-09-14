-- PL/SQL Guión 1:
-- Ejercicio 1:
-- Tablas ya creadas

set serveroutput on;

-- Ejercicio 2:
-- Realizar un procedimiento almacenado que muestre en pantalla “Hola Mundo”.
CREATE OR REPLACE PROCEDURE PROCEDURE2 IS
BEGIN
    DBMS_OUTPUT.put_line('HOLA MUNDO');
END;

begin
    SALUDO;
end;

-- Ejercicio 3:
-- Realizar un procedimiento almacenado que reciba un nombre como parámetro y muestre en
-- pantalla “Hola” + nombre.
CREATE OR REPLACE PROCEDURE PROCEDURE3 
    (nombre IN VARCHAR2) IS
BEGIN
    DBMS_OUTPUT.put_line('Hola ' || nombre);
END;

begin
    SALUDO_NOMBRE('Omar');
end;

-- Ejercicio 4:
-- Realizar un procedimiento almacenado que muestre el valor máximo tomado por el atributo
-- cantidad de la tabla distribución.
CREATE OR REPLACE PROCEDURE PROCEDURE4 IS
    cantidad DISTRIBUCION.CANTIDAD%TYPE;
BEGIN
    SELECT MAX(CANTIDAD) INTO cantidad FROM DISTRIBUCION;
    DBMS_OUTPUT.put_line(cantidad);
END;

begin
    MAX_QUANTITY;
end;

-- Ejercicio 5:
-- Realizar un procedimiento almacenado que muestre para un concesionario dado el número
-- total de coches que contiene.
CREATE OR REPLACE PROCEDURE PROCEDURE5 
    (con IN CONCESIONARIOS.CIFC%TYPE) IS
    totalCars DISTRIBUCION.CANTIDAD%TYPE;
BEGIN
    SELECT SUM(CANTIDAD) INTO totalCars FROM DISTRIBUCION WHERE con=CIFC;
    DBMS_OUTPUT.put_line(totalCars);
END;

begin
    TOTAL_CARS(4);
end;

-- Ejercicio 6:
-- Crear una tabla con los siguientes campos: nº total de ventas,nº total de coches, nº total de
-- marcas, nº total de clientes, nº total de concesionarios. Crear un procedimiento almacenado
-- que realice una consulta a la base de datos para cada uno de estos atributos y vaya
-- almacenando los valores en variables para finalmente hacer una inserción de todos los datos en
-- la tabla. Comprobar que la inserción se realiza correctamente.
CREATE TABLE TOTALES (
    ntventas NUMBER,
    ntcoches NUMBER,
    ntmarcas NUMBER,
    ntclientes NUMBER,
    ntconcesionarios NUMBER
);

CREATE OR REPLACE PROCEDURE PROCEDURE6 IS
    nv NUMBER; nc NUMBER; nm NUMBER; ncl NUMBER; nco NUMBER;
BEGIN
    SELECT count(*) INTO nv FROM VENTAS;
    SELECT count(*) INTO nc FROM COCHES;
    SELECT count(*) INTO nm FROM MARCAS;
    SELECT count(*) INTO ncl FROM CLIENTES;
    SELECT count(*) INTO nco FROM CONCESIONARIOS;
    INSERT INTO totales VALUES (nv, nc, nm, ncl, nco);
    COMMIT;
END;
    
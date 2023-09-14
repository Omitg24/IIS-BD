-- PL/SQL Guión 1:
set serveroutput on;

-- Ejercicio 7:
-- Crear una nueva tabla denominada HistoricoClientes cuya clave primaria sea dni.
-- Realizar un procedimiento almacenado que copie el contenido de la tabla Clientes a dicha
-- tabla. Ejecutar el procedimiento almacenado dos veces.
CREATE TABLE HistoricoClientes (
    DNI varchar(9),
    NOMBRE varchar(40),
    APELLIDO varchar(40),
    CIUDAD varchar(25),
    CONSTRAINT PK_HISTORICOCLIENTES PRIMARY KEY (DNI)
);

CREATE OR REPLACE PROCEDURE PROCEDURE7 IS
    dni HISTORICOCLIENTES.DNI%TYPE;
    nombre HISTORICOCLIENTES.NOMBRE%TYPE;
    apellido HISTORICOCLIENTES.APELLIDO%TYPE;
    ciudad HISTORICOCLIENTES.CIUDAD%TYPE;
    CURSOR C1 IS SELECT * FROM CLIENTES;
BEGIN   
    OPEN C1;
    LOOP
        FETCH C1 INTO dni, nombre, apellido, ciudad;
        INSERT INTO HISTORICOCLIENTES VALUES(dni, nombre, apellido, ciudad);
        EXIT WHEN C1%NOTFOUND;
    END LOOP;
    CLOSE C1;

END;

BEGIN
    COPIAR_CLIENTES;
END;

-- Ejercicio 8:
-- Realizar un procedimiento almacenado que muestre en pantalla la información sobre los
-- objetos creados por el usuario.
CREATE OR REPLACE PROCEDURE PROCEDURE78 AS
BEGIN
    FOR I IN (SELECT * FROM USER_OBJECTS) LOOP
        DBMS_OUTPUT.PUT_LINE('Has creado el objeto '||I.OBJECT_NAME||' de tipo '||I.OBJECT_TYPE);
    END LOOP;
END;

CALL MOSTRAR_OBJETOS();
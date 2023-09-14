-- PL/SQL Guión 2:
-- Ejercicio 1:
--Añadir a la tabla COMPRAS un nuevo atributo denominado DatosMayus que almacene el
--nombre y el apellido de los clientes, pero en mayúsculas. Realizar un disparador encargado de
--mantener el valor de dicho atributo.
CREATE TABLE COMPRAS (
    DNI VARCHAR(9),
    NOMBRE VARCHAR(40),
    APELLIDO VARCHAR(40),
    NUMCOCHESCOMPRADOS NUMBER(3)
);
CREATE OR REPLACE PROCEDURE PROCEDURE9 AS
BEGIN
    INSERT INTO COMPRAS(DNI, NOMBRE, APELLIDO, NUMCOCHESCOMPRADOS)
        SELECT cl.dni, nombre, apellido, count(*) as numcoches
        FROM ventas v, clientes cl
        WHERE v.dni=cl.dni
        GROUP BY cl.dni, nombre, apellido;
    COMMIT;
END;
CALL PROCEDURE9();


ALTER TABLE COMPRAS ADD DATOSMAYUS VARCHAR(100);
CREATE OR REPLACE TRIGGER MantenerDatosMayus
    BEFORE INSERT OR UPDATE OF NOMBRE, APELLIDO ON COMPRAS
    FOR EACH ROW
BEGIN
    :NEW.DATOSMAYUS:=UPPER(CONCAT(:NEW.NOMBRE, :NEW.APELLIDO));
END;
INSERT INTO COMPRAS(DNI, NOMBRE, APELLIDO) VALUES('10', 'Paco', 'Fernandez');

-- Ejercicio 2:
--Crear un disparador sobre la tabla VENTAS (del esquema propio) que cada vez que se realice
--una venta incremente en una unidad la cantidad de coches de la tabla COMPRAS.
CREATE OR REPLACE TRIGGER IncrementaCompras
    BEFORE INSERT ON VENTAS
    FOR EACH ROW
BEGIN
    UPDATE COMPRAS SET NUMCOCHESCOMPRADOS = NUMCOCHESCOMPRADOS + 1
        WHERE DNI=:NEW.DNI;
END;
INSERT INTO VENTAS VALUES('1', '2', '1', 'verde');

-- Ejercicio 3:
--Ampliar el disparador anterior para que tenga en cuenta que la eliminación de una venta para
--un cliente supondrá la correspondiente actualización en la tabla COMPRAS.
ALTER TRIGGER IncrementaCompras DISABLE;
CREATE OR REPLACE TRIGGER ActualizaCompras
    BEFORE INSERT OR DELETE ON VENTAS
    FOR EACH ROW
BEGIN
    IF (INSERTING) THEN
        UPDATE COMPRAS SET NUMCOCHESCOMPRADOS = NUMCOCHESCOMPRADOS + 1
            WHERE DNI=:NEW.DNI;
    ELSE IF DELETING THEN
        UPDATE COMPRAS SET NUMCOCHESCOMPRADOS = NUMCOCHESCOMPRADOS - 1
            WHERE DNI=:OLD.DNI;    
    END IF;
END;
INSERT INTO VENTAS VALUES('1', '2', '10', 'azul');
DELETE FROM VENTAS WHERE CODCOCHE = '10';

-- Ejercicio 4:
--Crear una tabla llamada AUDITORIA_CLIENTES con los siguientes atributos: Dniant,
--Nombreant, Apellidoant, Ciudadant, Dniact, Nombreact, Apellidoact,
--Ciudadact, Fechahora. Realizar un disparador que se encargue de mantener esta tabla
--reflejando en ella cualquier cambio que se produzca en la tabla CLIENTES del esquema
--propio. Fechahora reflejará la fecha y la hora en la que se realizó la modificación.
CREATE TABLE AUDITORIA_CLIENTES (
    DNIANT VARCHAR(8),
    NOMBREANT VARCHAR(20),
    APELLIDOANT VARCHAR(20),
    CIUDADANT VARCHAR(20),
    DNIACT VARCHAR(8),
    NOMBREACT VARCHAR(20),
    APELLIDOACT VARCHAR(20),
    CIUDADACT VARCHAR(20),
    FECHAHORA DATE
);
CREATE OR REPLACE TRIGGER MANTENERAUDITORIACLIENTES
    BEFORE INSERT OR DELETE OR UPDATE ON CLIENTES
    FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO AUDITORIA_CLIENTES VALUES (
            NULL, NULL, NULL, NULL,
            :NEW.DNI, :NEW.NOMBRE, :NEW.APELLIDO, :NEW.CIUDAD, SYSDATE);
    ELSIF DELETING THEN
        INSERT INTO AUDITORIA_CLIENTES VALUES (
            :OLD.DNI, :OLD.NOMBRE, :OLD.APELLIDO, :OLD.CIUDAD,
            NULL, NULL, NULL, NULL, SYSDATE);
    ELSE 
        INSERT INTO AUDITORIA_CLIENTES VALUES (
            :OLD.DNI, :OLD.NOMBRE, :OLD.APELLIDO, :OLD.CIUDAD,
            :NEW.DNI, :NEW.NOMBRE, :NEW.APELLIDO, :NEW.CIUDAD, SYSDATE);
    END IF;
END;

-- Ejericio 5:
--Realizar un disparador que disminuya la cantidad de coches almacenados en el concesionario
--cada vez que se vende una unidad de los mismos y siempre que la cantidad existente en el
--concesionario sea superior a una unidad.
CREATE OR REPLACE TRIGGER COMPRUEBASTOCKCOCHES
    BEFORE INSERT OR UPDATE OF CIFC, CODCOCHE ON VENTAS
    FOR EACH ROW
DECLARE
    N DISTRIBUCION.CANTIDAD%TYPE;
BEGIN
    SELECT CANTIDAD INTO N FROM DISTRIBUCION
        WHERE CIFC=:NEW.CIFC AND CODCOCHE=:NEW.CODCOCHE;
    IF N < 1 THEN
        RAISE_APPLICATION_ERROR(-20001, 'No quedan coches de tipo '||:NEW.CODCOCHE||
            ' en el concesionario '||:NEW.CIFC);
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 
            'No existen coches de ese tipo en el concesionario');
END;

CREATE OR REPLACE TRIGGER MANTENSTOCKCOCHES
    AFTER INSERT OR UPDATE OF CIFC, CODCOCHE ON VENTAS
    FOR EACH ROW
BEGIN   
    IF INSERTING THEN
        UPDATE DISTRIBUCION SET CANTIDAD=CANTIDAD-1
            WHERE CIFC=:NEW.CIFC AND CODCOCHE=:NEW.CODCOCHE;
    END IF;
    IF DELETING THEN
        UPDATE DISTRIBUCION SET CANTIDAD=CANTIDAD+1
            WHERE CIFC=:NEW.CIFC AND CODCOCHE=:NEW.CODCOCHE;
    END IF;
END;
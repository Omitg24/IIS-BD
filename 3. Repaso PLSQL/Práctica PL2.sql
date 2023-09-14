-- PRÁCTICA PL2:
SET SERVEROUTPUT ON;
-- Ejercicio 1:
--Añadir a la tabla COMPRAS un nuevo atributo denominado DatosMayus que almacene el
--nombre y el apellido de los clientes, pero en mayúsculas. 
ALTER TABLE COMPRAS2 ADD DATOSMAYUS VARCHAR2(100);
--Realizar un disparador encargado de mantener el valor de dicho atributo.
CREATE OR REPLACE TRIGGER DATOSMAYUS 
    BEFORE INSERT OR UPDATE OF NOMBRE, APELLIDO ON COMPRAS2
    FOR EACH ROW
BEGIN
    :NEW.DATOSMAYUS:=UPPER(CONCAT(:NEW.NOMBRE, :NEW.APELLIDO));
END;
INSERT INTO COMPRAS2(DNI, NOMBRE, APELLIDO, N_COCHES) VALUES(7, 'alba', 'francos', 1);
SELECT * FROM COMPRAS2;

-- Ejercicio 2:
--Crear un disparador sobre la tabla VENTAS (del esquema propio) que cada vez que se realice
--una venta incremente en una unidad la cantidad de coches de la tabla COMPRAS.
CREATE OR REPLACE TRIGGER INCREMENTAR_NCOCHES
    AFTER INSERT OR UPDATE ON VENTAS
    FOR EACH ROW
BEGIN
    UPDATE COMPRAS2 SET N_COCHES=N_COCHES+1 WHERE DNI=:NEW.DNI;
END;
INSERT INTO VENTAS VALUES (1, 1, 12, 'rojo');
-- Ejercicio 3:
--Ampliar el disparador anterior para que tenga en cuenta que la eliminación de una venta para
--un cliente supondrá la correspondiente actualización en la tabla COMPRAS.
CREATE OR REPLACE TRIGGER MODIFICA_NCOCHES
    AFTER INSERT OR UPDATE OR DELETE ON VENTAS
    FOR EACH ROW
BEGIN
    IF INSERTING OR UPDATING THEN
        UPDATE COMPRAS2 SET N_COCHES=N_COCHES+1 WHERE DNI=:NEW.DNI;
    ELSIF DELETING THEN
        UPDATE COMPRAS2 SET N_COCHES=N_COCHES-1 WHERE DNI=:OLD.DNI;
    END IF;
END;
SELECT * FROM COMPRAS2;
INSERT INTO VENTAS VALUES (1, 1, 12, 'rojo');
DELETE FROM VENTAS WHERE CODCOCHE=12 AND COLOR='rojo';

-- Ejercicio 4:
--Crear una tabla llamada AUDITORIA_CLIENTES con los siguientes atributos: Dniant,
--Nombreant, Apellidoant, Ciudadant, Dniact, Nombreact, Apellidoact,
--Ciudadact, Fechahora. Realizar un disparador que se encargue de mantener esta tabla
--reflejando en ella cualquier cambio que se produzca en la tabla CLIENTES del esquema
--propio. Fechahora reflejará la fecha y la hora en la que se realizó la modificación.
CREATE TABLE AUDITORIA_CLIENTES (
    DNIANT VARCHAR2(9),
    NOMBREANT VARCHAR2(40),
    APELLIDOANT VARCHAR2(40),
    CIUDADANT VARCHAR2(25),
    DNIACT VARCHAR2(9),
    NOMBREACT VARCHAR2(40),
    APELLIDOACT VARCHAR2(40),
    CIUDADACT VARCHAR2(25),
    FECHAHORA DATE
);
CREATE OR REPLACE TRIGGER NOTIFICAR_CLIENTES
    AFTER INSERT OR UPDATE OR DELETE ON CLIENTES
    FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO AUDITORIA_CLIENTES VALUES
        (NULL, NULL, NULL, NULL, :NEW.DNI, :NEW.NOMBRE, :NEW.APELLIDO, :NEW.CIUDAD, SYSDATE);
    ELSIF DELETING THEN
        INSERT INTO AUDITORIA_CLIENTES VALUES
        (:OLD.DNI, :OLD.NOMBRE, :OLD.APELLIDO, :OLD.CIUDAD, NULL, NULL, NULL, NULL, SYSDATE);
    ELSIF UPDATING THEN
        INSERT INTO AUDITORIA_CLIENTES VALUES
        (:OLD.DNI, :OLD.NOMBRE, :OLD.APELLIDO, :OLD.CIUDAD, :NEW.DNI, :NEW.NOMBRE, :NEW.APELLIDO, :NEW.CIUDAD, SYSDATE);
    END IF;
END;
SELECT * FROM AUDITORIA_CLIENTES;
INSERT INTO CLIENTES VALUES(7, 'alba', 'francos', 'parís');
UPDATE CLIENTES SET DNI=18 WHERE DNI=7 AND NOMBRE='alba';
DELETE FROM CLIENTES WHERE DNI=18;

-- Ejercicio 5:
--Realizar un disparador que disminuya la cantidad de coches almacenados en el concesionario
--cada vez que se vende una unidad de los mismos y siempre que la cantidad existente en el
--concesionario sea superior a una unidad.
CREATE OR REPLACE TRIGGER COMPRUEBA_CANTIDAD
    BEFORE INSERT OR DELETE OR UPDATE OF CIFC, CODCOCHE ON VENTAS
    FOR EACH ROW
DECLARE
    N_COCHES DISTRIBUCION.CANTIDAD%TYPE;
BEGIN
    SELECT CANTIDAD INTO N_COCHES FROM DISTRIBUCION WHERE CIFC=:NEW.CIFC AND CODCOCHE=:NEW.CODCOCHE;
    IF N_COCHES<1 THEN
        RAISE_APPLICATION_ERROR(-20001, 'No quedan coches de tipo '||:NEW.CODCOCHE||
            ' en el concesionario '||:NEW.CIFC);        
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 
            'No existen coches de ese tipo en el concesionario');
END;
CREATE OR REPLACE TRIGGER ACTUALIZA_COCHES
    AFTER INSERT OR DELETE OR UPDATE OF CIFC, CODCOCHE ON VENTAS
    FOR EACH ROW
BEGIN
    IF INSERTING THEN
        UPDATE DISTRIBUCION SET CANTIDAD=CANTIDAD-1 WHERE CIFC=:NEW.CIFC AND CODCOCHE=:NEW.CODCOCHE;
    END IF;
    IF DELETING THEN
        UPDATE DISTRIBUCION SET CANTIDAD=CANTIDAD+1 WHERE CIFC=:OLD.CIFC AND CODCOCHE=:OLD.CIFC;
    END IF;
END;

-- Ejercicio 6:
--Realizar un disparador que únicamente permita borrar en la tabla COMPRAS al usuario
--propietario del esquema y en las horas comprendidas entre las 11:00 y las 13:00h.
CREATE OR REPLACE TRIGGER BORRAR_USUARIO
    BEFORE DELETE ON COMPRAS2
DECLARE
    USUARIO VARCHAR2(50);    
BEGIN
    SELECT TABLE_OWNER INTO USUARIO FROM USER_TRIGGERS WHERE TRIGGER_NAME='BORRAR_USUARIO';
    
    IF USUARIO<>SYS_CONTEXT('USERENV', 'CURRENT_USER') THEN
        RAISE_APPLICATION_ERROR(-20001, 'El usuario no es el propietario');
    ELSE
        IF TO_CHAR(SYSDATE,'HH24:MI')<'11:00' AND TO_CHAR(SYSDATE,'HH24:MI')>'13:00' THEN
            RAISE_APPLICATION_ERROR(-20002, 'La hora no es la correcta');
        END IF;
    END IF;
END;
-- Ejercicio 7:
--Realizar un disparador que almacene en la tabla AUDITA_COMPRAS la operación que se realiza
--(inserción, borrado, actualización) la fecha en la que se realiza y el usuario que lo hace.
CREATE TABLE AUDITA_COMPRAS (
    OPERACION VARCHAR2(40),
    FECHA DATE,
    USUARIO VARCHAR2(40)
);
CREATE OR REPLACE TRIGGER ALMACENA_OPERACION
    AFTER INSERT OR UPDATE OR DELETE ON COMPRAS2
    FOR EACH ROW
DECLARE
    OP AUDITA_COMPRAS.OPERACION%TYPE;
BEGIN
    IF INSERTING THEN
        OP:='Inserción';
    END IF;
    IF UPDATING THEN
        OP:='Actualización';
    END IF;
    IF DELETING THEN
        OP:='Borrado';
    END IF;
    INSERT INTO AUDITA_COMPRAS VALUES(OP, SYSDATE, SYS_CONTEXT('USERENV', 'CURRENT_USER'));
END;
SELECT * FROM AUDITA_COMPRAS;
INSERT INTO COMPRAS2(DNI, NOMBRE, APELLIDO, N_COCHES) VALUES(7, 'alba', 'francos', 1);
UPDATE COMPRAS2 SET DNI='9' WHERE DNI='7';
DELETE FROM COMPRAS2 WHERE DNI='9';

-- Ejercicio 8:
--Se ha descatalogado el color amarillo de los coches, por tanto, ya no se podrán vender más
--coches de dicho color.
CREATE OR REPLACE TRIGGER DESCATALOGAR_AMARILLO
    BEFORE INSERT OR UPDATE OF COLOR ON VENTAS
    FOR EACH ROW
BEGIN
    IF :NEW.COLOR='amarillo' THEN
        RAISE_APPLICATION_ERROR(-20002, 'Los coches de color amarillo se han descatalogado');
    END IF;
END;
INSERT INTO VENTAS VALUES(1,2,4,'amarillo');

-- Ejercicio 9:
-- Ningún concesionario puede albergar más de 40 coches.
CREATE OR REPLACE TRIGGER CANTIDAD_LIMITE
    BEFORE INSERT ON DISTRIBUCION
    FOR EACH ROW
DECLARE
    N_COCHES DISTRIBUCION.CANTIDAD%TYPE;    
    STOCK DISTRIBUCION.CANTIDAD%TYPE;    
BEGIN
    SELECT SUM(CANTIDAD) INTO N_COCHES FROM DISTRIBUCION WHERE CIFC=:NEW.CIFC;
    IF N_COCHES IS NULL THEN
        N_COCHES:=0;
    END IF;
    STOCK:=N_COCHES+:NEW.CANTIDAD;
    IF STOCK>40 THEN
        RAISE_APPLICATION_ERROR(-20002, 'No se pueden albergar más de 40 coches');
    END IF;
END;

-- Ejercicio 10:
--El concesionario 1 cerró sus puertas ayer y por tanto ya no podrá realizar más ventas.
CREATE OR REPLACE TRIGGER CONCESIONARIO_CERRADO
    BEFORE INSERT OR UPDATE ON VENTAS
    FOR EACH ROW
BEGIN
    IF :NEW.CIFC=1 THEN
        RAISE_APPLICATION_ERROR(-20002, 'El concesionario cerró sus puertas');
    END IF;
END;
INSERT INTO VENTAS VALUES(1, 1, 1, 'rojo');

-- Ejercicio 11:
--Recientemente, se ha detectado una sustancia tóxica en la pintura utilizada para pintar los
--coches rojos. Afortunadamente, se sabe que ningún coche fue vendido hasta el momento con
--pintura tóxica, pero en lo sucesivo se desea llevar un registro de todos los coches que pudieran
--estar pintados con dicha pintura tóxica para proceder a su revisión. La forma de localizarlos es
--sabiendo el cifc y nombre del concesionario donde pudiera haberse vendido, el dni y nombre
--del cliente que pudiera haberlo comprado, el código, el nombre y el modelo del coche, así
--como la fecha y hora en que tuvo lugar la venta.
CREATE TABLE REGISTRO_ROJOS (
    CIFC VARCHAR2(255),
    NOMBREC VARCHAR2(255),
    DNI VARCHAR2(255),
    NOMBRE VARCHAR2(255),
    CODCOCHE INTEGER,
    NOMBRECH VARCHAR2(255),
    MODELO VARCHAR2(255),
    FECHA DATE
);
CREATE OR REPLACE TRIGGER REGISTRAR_ROJOS
    AFTER INSERT OR UPDATE OF COLOR ON VENTAS
    FOR EACH ROW
DECLARE
    NOMC CONCESIONARIOS.NOMBREC%TYPE;
    NOM CLIENTES.NOMBRE%TYPE;
    NOMCH COCHES.NOMBRECH%TYPE;
    MDL COCHES.MODELO%TYPE;
BEGIN    
    IF :NEW.COLOR='rojo' THEN
        SELECT NOMBREC INTO NOMC FROM CONCESIONARIOS WHERE CIFC=:NEW.CIFC;
        SELECT NOMBRE INTO NOM FROM CLIENTES WHERE DNI=:NEW.DNI;
        SELECT NOMBRECH, MODELO INTO NOMCH, MDL FROM COCHES WHERE CODCOCHE=:NEW.CODCOCHE;
        INSERT INTO REGISTRO_ROJOS VALUES
            (:NEW.CIFC, NOMC, :NEW.DNI, NOM, :NEW.CODCOCHE, NOMCH, MDL, SYSDATE);
    END IF;
    IF UPDATING AND :OLD.COLOR='rojo' AND :NEW.COLOR<>'rojo' THEN
        DELETE FROM REGISTRO_ROJOS WHERE
            DNI=:NEW.DNI AND CIFC=:NEW.CIFC AND CODCOCHE=:NEW.CODCOCHE;
    END IF;
END;

-- Ejercicio 12:
--Se ha prohibido por decreto la circulación de coches de color gris, por lo que aquellos coches
--que se vendan de color gris deben pintarse de color blanco si el modelo del coche es gtd y de
--color negro si el modelo es cualquier otro
CREATE OR REPLACE TRIGGER CAMBIAR_COLOR
    BEFORE INSERT OR UPDATE OF COLOR ON VENTAS
    FOR EACH ROW
DECLARE
    MDL COCHES.MODELO%TYPE;
BEGIN
    IF :NEW.COLOR='gris' THEN
        SELECT MODELO INTO MDL FROM COCHES WHERE CODCOCHE=:NEW.CODCOCHE;
        IF MDL='gtd' THEN
            :NEW.COLOR:='blanco';
        ELSE
            :NEW.COLOR:='negro';
        END IF;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'El coche no existe');
END;
-- Práctica PL2:
-- Ejercicio 6:
--Realizar un disparador que únicamente permita borrar en la tabla COMPRAS al usuario
--propietario del esquema y en las horas comprendidas entre las 11:00 y las 13:00h.
CREATE OR REPLACE TRIGGER BorrarConCondicion
    BEFORE DELETE ON COMPRAS
DECLARE
    USUARIO VARCHAR2(50);
    HORAACTUAL VARCHAR2(8);
BEGIN
    USUARIO := SYS_CONTEXT('USERENV', 'CURRENT_USER');
    IF USUARIO<>'UO281847' THEN
        RAISE_APPLICATION_ERROR(-20001, 'El usuario no corresponde al propietario del esquema');
    ELSE
        HORAACTUAL := TO_CHAR(SYSDATE, 'HH24:MI');
        IF HORAACTUAL<'11:00' OR HORAACTUAL>'17:00' THEN
            RAISE_APPLICATION_ERROR(-20002, 'La hora no es correcta');
        END IF;
    END IF;    
EXCEPTION 
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 
            'No está el dato en la tabla COMPRAS');
END;

INSERT INTO COMPRAS(DNI, NOMBRE, APELLIDO, NUMCOCHESCOMPRADOS) VALUES('8', 'Enol', 'García González', '100');
DELETE FROM COMPRAS WHERE DNI='8';

-- Ejercicio 7:
--Realizar un disparador que almacene en la tabla AUDITA_COMPRAS la operación que se realiza
--(inserción, borrado, actualización) la fecha en la que se realiza y el usuario que lo hace.
CREATE TABLE AUDITA_COMPRAS (
    OPERACION VARCHAR2(20),
    FECHA DATE,
    USUARIO VARCHAR2(20)
);

CREATE OR REPLACE TRIGGER MostrarOperacion
    AFTER INSERT OR DELETE OR UPDATE ON COMPRAS
    FOR EACH ROW
DECLARE 
    USUARIO AUDITA_COMPRAS.USUARIO%TYPE;
    OP AUDITA_COMPRAS.OPERACION%TYPE;
BEGIN
    USUARIO := SYS_CONTEXT('USERENV', 'CURRENT_USER');
    IF INSERTING THEN
        OP := 'INSERT';
    END IF;
    IF DELETING THEN
        OP := 'DELETE';
    END IF;    
    IF UPDATING THEN
        OP := 'UPDATE';
    END IF;
    INSERT INTO AUDITA_COMPRAS VALUES(OP, SYSDATE, USUARIO);
END;

INSERT INTO COMPRAS(DNI, NOMBRE, APELLIDO, NUMCOCHESCOMPRADOS) VALUES('8', 'Enol', 'García González', '100');
DELETE FROM COMPRAS WHERE DNI='8';

-- Ejercicio 10:
--El concesionario 1 cerró sus puertas ayer y por tanto ya no podrá realizar más ventas.
CREATE OR REPLACE TRIGGER Concesionario1NoVentas
    BEFORE INSERT OR UPDATE ON VENTAS
    FOR EACH ROW
BEGIN
    IF :NEW.CIFC='1' THEN
        RAISE_APPLICATION_ERROR(-20001, 'El concesionario 1 no puede realizar más ventas');
    END IF;
END;

INSERT INTO VENTAS VALUES ('1', '2', '12', 'rojo');

-- Ejercicio 11:
--Recientemente, se ha detectado una sustancia tóxica en la pintura utilizada para pintar los
--coches rojos. Afortunadamente, se sabe que ningún coche fue vendido hasta el momento con
--tóxica, pero en lo sucesivo se desea llevar un registro de todos los coches que pudieran
--estar pintados con dicha pintura tóxica para proceder a su revisión. La forma de localizarlos es
--el cifc y nombre del concesionario donde pudiera haberse vendido, el dni y nombre
--del cliente que pudiera haberlo comprado, el código, el nombre y el modelo del coche, así
--como la fecha y hora en que tuvo lugar la venta.
CREATE TABLE CONTROLAROJOS (
    CIFC VARCHAR2(255),
    NOMBREC VARCHAR2(255),
    DNI VARCHAR2(255),
    NOMBRE VARCHAR2(255),
    CODCOCHE INTEGER,
    NOMBRECH VARCHAR2(255),
    MODELO VARCHAR2(255),
    FECHA DATE
);
CREATE OR REPLACE TRIGGER AuditoriaCochesRojos 
    AFTER INSERT OR UPDATE OF COLOR ON VENTAS
    FOR EACH ROW
DECLARE 
    NOMC CONCESIONARIOS.NOMBREC%TYPE;
    NOM CLIENTES.NOMBRE%TYPE;
    NOMCH COCHES.NOMBRECH%TYPE;
    MDL COCHES.MODELO%TYPE;
BEGIN
    IF :NEW.COLOR ='rojo' THEN
        SELECT NOMBREC INTO NOMC FROM CONCESIONARIOS WHERE CIFC=:NEW.CIFC;
        SELECT NOMBRE INTO NOM FROM CLIENTES WHERE DNI=:NEW.DNI;
        SELECT NOMBRECH, MODELO INTO NOMCH, MDL FROM COCHES WHERE CODCOCHE=:NEW.CODCOCHE;
        INSERT INTO CONTROLAROJOS VALUES
            (:NEW.CIFC, NOMC, :NEW.DNI, NOM, :NEW.CODCOCHE, NOMCH, MDL, SYSDATE);
    END IF;
    
    IF UPDATING AND :OLD.COLOR = 'rojo' AND :NEW.COLOR<>'rojo' THEN
        DELETE FROM CONTROLAROJOS WHERE CIFC=:NEW.CIFC AND
            CODCOCHE=:NEW.CODCOCHE AND DNI=:NEW.DNI;
    END IF;
END;
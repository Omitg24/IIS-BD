-- PL/SQL Guión 1:
set serveroutput on;

-- Ejercicio 10:
-- Realizar un procedimiento almacenado que dado un código de concesionario devuelve el
-- número ventas que se han realizado en el mismo. Realizar lo mismo empleando una función
-- en vez de un procedimiento
-- PROCEDIMIENTO:
CREATE OR REPLACE PROCEDURE PROCEDURE10
    (CON IN CONCESIONARIOS.CIFC%TYPE, NV OUT NUMBER) AS
BEGIN
    SELECT COUNT(*) INTO NV FROM VENTAS WHERE CIFC=CON;
END;

DECLARE
    NV NUMBER;
BEGIN
    PROCEDURE10('1', NV);
    DBMS_OUTPUT.PUT_LINE('NV: ' ||NV);
END;

-- FUNCION:
CREATE OR REPLACE FUNCTION FUNCTION10 
    (CON IN CONCESIONARIOS.CIFC%TYPE)
RETURN NUMBER AS
    NV NUMBER;
BEGIN 
    SELECT COUNT(*) INTO NV FROM VENTAS WHERE CIFC=CON;
    RETURN NV;
END;

DECLARE
    NV NUMBER;
BEGIN
    NV:=FUNCTION10('1');
    DBMS_OUTPUT.PUT_LINE('NV: ' ||NV);
END;

-- Ejercicio 11:
-- Realizar una función en PL/SQL, que dada una ciudad que se le pasa como parámetro
-- devuelve el número de clientes de dicha ciudad. Realizar lo mismo empleando un
-- procedimiento en vez de una función
-- FUNCIÓN:
CREATE OR REPLACE FUNCTION FUNCTION11 
    (CON IN CLIENTES.CIUDAD%TYPE)
RETURN NUMBER AS
    NC NUMBER;
BEGIN 
    SELECT COUNT(*) INTO NC FROM CLIENTES WHERE CIUDAD=CON;
    RETURN NC;
END;

DECLARE
    NC NUMBER;
BEGIN
    NC:=FUNCTION11('madrid');
    DBMS_OUTPUT.PUT_LINE('NC: ' ||NC);
END;

-- PROCEDIMIENTO:
CREATE OR REPLACE PROCEDURE PROCEDURE11
    (CON IN CLIENTES.CIUDAD%TYPE, NC OUT NUMBER) AS
BEGIN
    SELECT COUNT(*) INTO NC FROM CLIENTES WHERE CIUDAD=CON;
END;

DECLARE
    NC NUMBER;
BEGIN
    PROCEDURE11('madrid', NC);
    DBMS_OUTPUT.PUT_LINE('NC: ' ||NC);
END;

-- Ejercicio 12:
-- Construir un procedimiento almacenado denominado ListarCochesPorCliente que
-- genere un listado que muestre por pantalla los coches que han sido adquiridos por cada cliente
-- de la siguiente forma:
CREATE OR REPLACE PROCEDURE ListarCochesPorCliente AS
    CURSOR C1 IS SELECT * FROM CLIENTES;
    CURSOR C2 (UNDNI VENTAS.DNI%TYPE) IS SELECT C.codcoche, nombrech, modelo, color 
        FROM COCHES C, VENTAS V WHERE C.CODCOCHE=V.CODCOCHE AND V.DNI=UNDNI;
    NUMCOC NUMBER;
    NUMCON NUMBER;
BEGIN  
    FOR I IN C1 LOOP
        SELECT COUNT(*) INTO NUMCOC FROM VENTAS WHERE (DNI=I.DNI);
        SELECT COUNT(DISTINCT CIFC) INTO NUMCON FROM VENTAS WHERE (DNI=I.DNI);
        DBMS_OUTPUT.PUT_LINE('- Cliente: '||I.nombre||' '||I.apellido||' '||NUMCOC||' '||NUMCON);
        FOR K IN C2(I.dni)  LOOP            
            DBMS_OUTPUT.PUT_LINE('---> Coche: '||K.codcoche||' '||K.nombrech||' '||K.modelo||' '||K.color);
            END LOOP;
    END LOOP;
END;

CALL ListarCochesPorCliente();

-- Ejercicio 13:
-- Realizar otro procedimiento almacenado denominado ListarCochesUnCliente que
-- muestre por pantalla, de la misma forma que en el ejercicio anterior, los coches adquiridos por
-- un determinado cliente cuyo dni es enviado como parámetro de entrada a dicho
-- procedimiento.
CREATE OR REPLACE PROCEDURE ListarCochesUnCliente 
    (DNIC IN CLIENTES.DNI%TYPE) AS
    CURSOR C2 IS SELECT C.codcoche, nombrech, modelo, color 
        FROM COCHES C, VENTAS V WHERE C.CODCOCHE=V.CODCOCHE AND V.DNI=DNIC;
    NUMCOC NUMBER;
    NUMCON NUMBER;
    CLI CLIENTES%ROWTYPE;
BEGIN  
    SELECT * INTO CLI FROM CLIENTES WHERE DNI=DNIC;
    SELECT COUNT(*) INTO NUMCOC FROM VENTAS WHERE (DNI=DNIC);
    SELECT COUNT(DISTINCT CIFC) INTO NUMCON FROM VENTAS WHERE (DNI=DNIC);
    DBMS_OUTPUT.PUT_LINE('- Cliente: '||CLI.nombre||' '||CLI.apellido||' '||NUMCOC||' '||NUMCON);
    FOR K IN C2 LOOP            
        DBMS_OUTPUT.PUT_LINE('---> Coche: '||K.codcoche||' '||K.nombrech||' '||K.modelo||' '||K.color);
    END LOOP;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Datos incorrectos del cliente');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Error desconocido');
END;

CALL ListarCochesUnCliente('1');

-- Ejericio 14:
-- Crear un paquete denominado practicaPL1 que englobe todos los procedimientos y funciones
-- definidas con anterioridad en este ejercicio.
CREATE OR REPLACE PACKAGE PRACTICAPL1 AS
    PROCEDURE PROCEDURE2;
    PROCEDURE PROCEDURE3 (CON VARCHAR2);
    PROCEDURE PROCEDURE4;
--    PROCEDURE PROCEDURE5 (CON CONCESIONARIOS.CIFC%TYPE);
--    PROCEDURE PROCEDURE6;
--    PROCEDURE PROCEDURE7;
--    PROCEDURE PROCEDURE8;
--    PROCEDURE PROCEDURE10 (CON IN CONCESIONARIOS.CIFC%TYPE, NV out number);
--    FUNCTION FUNCTION10 (CON IN CONCESIONARIOS.CIFC%TYPE) RETURN NUMBER;
--    PROCEDURE PROCEDURE11 (CON IN CLIENTES.CIUDAD%TYPE, NV out number);
--    FUNCTION FUNCTION11(CON IN CLIENTES.CIUDAD%TYPE) RETURN NUMBER;
--    PROCEDURE ListarCochesPorCliente;
--    PROCEDURE ListarCochesUnCliente (CON IN CLIENTES.DNI%TYPE);
END;

CREATE OR REPLACE PACKAGE BODY PRACTICAPL1 AS
    PROCEDURE PROCEDURE2 IS
    BEGIN
        DBMS_OUTPUT.put_line('HOLA MUNDO');
    END;
    PROCEDURE PROCEDURE3 
        (nombre IN VARCHAR2) IS
    BEGIN
        DBMS_OUTPUT.put_line('Hola ' || nombre);
    END;
    PROCEDURE PROCEDURE4 IS
        cantidad DISTRIBUCION.CANTIDAD%TYPE;
    BEGIN
        SELECT MAX(CANTIDAD) INTO cantidad FROM DISTRIBUCION;
        DBMS_OUTPUT.put_line(cantidad);
    END;
END;

EXECUTE.PRACTICAPL1.PROCEDURE2();

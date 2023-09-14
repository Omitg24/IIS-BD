-- EJERCICIOS VUELTA_CICLISTA:
SET SERVEROUTPUT ON;
-- Ejercicio 1:
--No puede haber más de 4 ciclistas por equipo.
CREATE OR REPLACE TRIGGER LIMITE_CICLISTAS 
    BEFORE INSERT OR UPDATE ON CYCLIST
    FOR EACH ROW
DECLARE 
    N_CYCLIST NUMBER;
BEGIN
    SELECT COUNT(*) INTO N_CYCLIST FROM CYCLIST WHERE NAME_TEAM=:NEW.NAME_TEAM;
    IF N_CYCLIST >= 4 THEN
        RAISE_APPLICATION_ERROR(-20002, 'No puede haber más de 4 ciclistas por equipo');
    END IF;
END;
SELECT * FROM CYCLIST WHERE NAME_TEAM='vande';
INSERT INTO CYCLIST VALUES('alba', 'master', 'clasicomano', 'vande');
INSERT INTO CYCLIST VALUES('omar', 'master', 'clasicomano', 'vande');
ALTER TRIGGER LIMITE_CICLISTAS DISABLE;

-- Ejercicio 2:
--Imprimir los ciclistas y hacer consulta del equipo en el que esté matriculado.
CREATE OR REPLACE PROCEDURE IMPRIMIR_CICLISTAS IS
    CURSOR CICLISTAS IS SELECT CYCLIST_NAME, NAME_TEAM FROM CYCLIST;
BEGIN
    FOR I IN CICLISTAS LOOP
        DBMS_OUTPUT.PUT_LINE('Ciclista: '||I.CYCLIST_NAME||' - Nombre del equipo: '||I.NAME_TEAM);
    END LOOP;
END;
EXECUTE IMPRIMIR_CICLISTAS;

-- Ejercicio 3:
--Crea una función a la que, pasandole el nombre de un ciclista, 
--te devuelve el nombre del equipo en el que está.
CREATE OR REPLACE FUNCTION EQUIPO_DEL_CICLISTA(NOMCICLISTA CYCLIST.CYCLIST_NAME%TYPE)
    RETURN CYCLIST.NAME_TEAM%TYPE IS
    NOMEQUIPO CYCLIST.NAME_TEAM%TYPE;
BEGIN
    SELECT NAME_TEAM INTO NOMEQUIPO FROM CYCLIST WHERE CYCLIST_NAME=NOMCICLISTA;    
    RETURN NOMEQUIPO;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'No existe ese ciclista');
END;
DECLARE
    NOMEQUIPO VARCHAR2(50);
BEGIN
    NOMEQUIPO:=EQUIPO_DEL_CICLISTA('roberto');
    DBMS_OUTPUT.PUT_LINE('El nombre del equipo del ciclista es: '||NOMEQUIPO);
END;
DECLARE
    NOMEQUIPO VARCHAR2(50);
BEGIN
    NOMEQUIPO:=EQUIPO_DEL_CICLISTA('omar');
    DBMS_OUTPUT.PUT_LINE('El nombre del equipo del ciclista es: '||NOMEQUIPO);
END;

-- Ejercicio 4:
--Según la nueva normativa que deben acatar las vueltas ciclistas de ahora en adelante la cantidad
--subvencionada por un patrocinador a un equipo nuna podrá superar el 10% del presupuesto del
--equipo salvo que el número de ciclistas que integran el equipo supere los 5 en cuyo caso, la cantidad
--subvencionada por el patrocinador podría alcanzar como máximo el 30% del presupuesto del equipo.
CREATE OR REPLACE TRIGGER COMPRUEBA_SPONSOR
    BEFORE INSERT OR UPDATE ON IS_SPONSORIZED
    FOR EACH ROW
DECLARE
    N_CICLISTAS NUMBER;
    PRESUPUESTO TEAM.BUDGET%TYPE;
BEGIN
    SELECT COUNT(DISTINCT CYCLIST_NAME) INTO N_CICLISTAS FROM CYCLIST
        WHERE NAME_TEAM=:NEW.NAME_TEAM;
    IF N_CICLISTAS<5 THEN
        SELECT BUDGET INTO PRESUPUESTO FROM TEAM WHERE NAME_TEAM=:NEW.NAME_TEAM;
        IF :NEW.AMOUNT>(10*PRESUPUESTO)/100 THEN
            RAISE_APPLICATION_ERROR(-20002, 'La cantidad subvencionada no puede superar el 10% del presupuesto del equipo: '||:NEW.NAME_TEAM);
        END IF;
    ELSIF N_CICLISTAS>5 THEN
        SELECT BUDGET INTO PRESUPUESTO FROM TEAM WHERE NAME_TEAM=:NEW.NAME_TEAM;
        IF :NEW.AMOUNT>(30*PRESUPUESTO)/100 THEN
            RAISE_APPLICATION_ERROR(-20003, 'La cantidad subvencionada no puede superar el 30% del presupuesto del equipo: '||:NEW.NAME_TEAM);
        END IF;
    END IF;
END;
SELECT * FROM IS_SPONSORIZED WHERE NAME_TEAM='vande';
INSERT INTO IS_SPONSORIZED VALUES('vande', '7', '9121');
DELETE FROM IS_SPONSORIZED WHERE ID_SPONSOR=7 AND NAME_TEAM='vande';
SELECT * FROM IS_SPONSORIZED WHERE NAME_TEAM='trend';
INSERT INTO IS_SPONSORIZED VALUES('trend', '7', '26400');
DELETE FROM IS_SPONSORIZED WHERE ID_SPONSOR=7 AND NAME_TEAM='trend';
ALTER TRIGGER COMPRUEBA_SPONSOR DISABLE;
--Por otro lado, y de ahora en adelante, a un ciclista nunca se le podrá imponer el maillot 'azul'(lider de
--montaña) si no ha quedado en primer posición en al menos una etapa de montaña.
CREATE OR REPLACE TRIGGER IMPONER_MAILLOT
    BEFORE INSERT OR UPDATE OF ID_MAILLOT ON WEARS
    FOR EACH ROW
DECLARE 
    N_PRIMERA_POS NUMBER;
    ID_AZUL MAILLOT.ID_MAILLOT%TYPE;
BEGIN
    SELECT COUNT(*) INTO N_PRIMERA_POS FROM TAKES_PART TP, MOUNTAINSTAGE MS
        WHERE MS.NUM_STAGE=TP.NUM_STAGE AND TP.ORDER_CLASSIFICATION=1 AND TP.CYCLIST_NAME=:NEW.CYCLIST_NAME;
    SELECT ID_MAILLOT INTO ID_AZUL FROM MAILLOT WHERE COLOR='azul';
    IF N_PRIMERA_POS < 1 AND ID_AZUL=:NEW.ID_MAILLOT THEN
        RAISE_APPLICATION_ERROR(-20002, 'Para llevar el maillot azul el ciclista: '||:NEW.CYCLIST_NAME||' debe de haber quedado en primera posición');
    END IF;
END;
ALTER TRIGGER IMPONER_MAILLOT DISABLE;

-- Ejercicio 5:
--Crear un procedimiento que muestre para cada tipo de ciclista, el número de
--ciclistas de ese tipo que hay registrados (numciclistas) y el número de etapas en las que los
--ciclistas de ese tipo han quedado clasificados en primer lugar (numetapas). Para cada una de esas
--etapas indicar, de la forma que se especifica a continuación, los siguientes datos: número de 
--tramos por los que se discurre la etapa (numtramos), número de carreteras diferentes que atraviesa
--(numcarreteras), y el número de incidentes que han ocurrido en dicha etapa y a los que no han
--tenido que acudir agentes (numincidentes).
SELECT * FROM GOES_BY;
CREATE OR REPLACE PROCEDURE LISTA_TIPOS_CICLISTA IS
    CURSOR CICLISTA IS SELECT TYPE_CYCLIST, COUNT(DISTINCT CYCLIST_NAME) AS NUMCICLISTAS 
        FROM CYCLIST GROUP BY TYPE_CYCLIST;
    CURSOR ETAPA (TCICLISTA CYCLIST.TYPE_CYCLIST%TYPE) IS SELECT TP.NUM_STAGE, COUNT(*) AS NUMTRAMOS, 
        COUNT(DISTINCT G.ID_ROAD) AS NUMCARRETERA FROM CYCLIST C, TAKES_PART TP, STAGE S, GOES_BY G 
            WHERE C.TYPE_CYCLIST=TCICLISTA AND C.CYCLIST_NAME=TP.CYCLIST_NAME AND TP.ORDER_CLASSIFICATION=1
                AND TP.NUM_STAGE=S.NUM_STAGE AND S.NUM_STAGE=G.NUM_STAGE GROUP BY TP.NUM_STAGE;
    NUMETAPAS NUMBER;
    NUMINCIDENTES NUMBER;
BEGIN
    FOR I IN CICLISTA LOOP
        SELECT COUNT(*) INTO NUMETAPAS FROM TAKES_PART TP, CYCLIST C
            WHERE I.TYPE_CYCLIST=C.TYPE_CYCLIST AND C.CYCLIST_NAME=TP.CYCLIST_NAME AND TP.ORDER_CLASSIFICATION=1;
        DBMS_OUTPUT.PUT_LINE('Tipo de Ciclista: '||I.TYPE_CYCLIST||' '||I.NUMCICLISTAS||' '||NUMETAPAS);
        FOR J IN ETAPA(I.TYPE_CYCLIST) LOOP
            SELECT COUNT(*) INTO NUMINCIDENTES FROM INCIDENT INC, TSECTION S, GOES_BY G
                WHERE INC.ID_INCIDENT NOT IN (SELECT ID_INCIDENT FROM COMES) AND S.ID_ROAD=G.ID_ROAD 
                    AND S.ORDER_ROAD=G.ORDER_ROAD AND S.ID_ROAD=INC.ID_ROAD AND INC.ORDER_ROAD=S.ORDER_ROAD;
            DBMS_OUTPUT.PUT_LINE('  Etapa Ganada: '||J.NUM_STAGE||' '||J.NUMTRAMOS||' '||J.NUMCARRETERA||' '||NUMINCIDENTES);
        END LOOP;
    END LOOP;
END;
EXECUTE LISTA_TIPOS_CICLISTA;

-- Ejercicio 6:
--Crear una función que dadas las etapas que discurren por un término municipal 
--dado (id_tm), que es pasado como parámetro, y que no han registrado ningun incidente,
--devuelva aquella (etapa) en la que el número de ciclistas que la han disputado ha sido mayor.
CREATE OR REPLACE FUNCTION ETAPAS_MUNICIPAL (ID_TERM TERRAINMUNICIPALITY.ID_TM%TYPE)
    RETURN STAGE.NUM_STAGE%TYPE IS
    ETAPA STAGE.NUM_STAGE%TYPE;
BEGIN
    SELECT NUM_STAGE INTO ETAPA FROM (SELECT S.NUM_STAGE, COUNT(DISTINCT TP.CYCLIST_NAME) 
        FROM STAGE S, TAKES_PART TP, GOES_BY G, TSECTION TS, PASSES P WHERE P.ID_TM=1 
            AND P.ID_ROAD=TS.ID_ROAD AND TS.ID_ROAD NOT IN (SELECT ID_ROAD FROM INCIDENT) 
                AND TS.ID_ROAD=G.ID_ROAD AND TS.ORDER_ROAD=G.ORDER_ROAD AND G.NUM_STAGE=TP.NUM_STAGE 
                    AND G.NUM_STAGE=S.NUM_STAGE GROUP BY S.NUM_STAGE ORDER BY COUNT(DISTINCT TP.CYCLIST_NAME) DESC) WHERE ROWNUM=1;
    RETURN ETAPA;
END;
DECLARE 
    ETAPA NUMBER(2,0);
BEGIN
    ETAPA:=ETAPAS_MUNICIPAL(1);
    DBMS_OUTPUT.PUT_LINE(ETAPA);
END;

-- Ejercicio 7:
--Según la nueva normativa que regula las vueltas ciclistas, de ahora en adelante, los puntos que se
--asignaran (puntos_ganador) al ganador de las etapas de montaña de categoría especial variarán en
--función de los km de la etapa de tal manera que se le asignaran 50 puntos a etapas de más de 180 km,
--y 25 al resto.
CREATE OR REPLACE TRIGGER PUNTOS_GANADOR
    BEFORE INSERT OR UPDATE ON MOUNTAINSTAGE
    FOR EACH ROW
DECLARE 
    KM_STAGE STAGE.KM%TYPE;
BEGIN
    IF :NEW.CATEGORY_MOUNTAIN='especial' THEN
        SELECT KM INTO KM_STAGE FROM STAGE WHERE NUM_STAGE=:NEW.NUM_STAGE;
        IF KM_STAGE>180 THEN
            :NEW.POINTS_WINNER:=50;
        ELSE
            :NEW.POINTS_WINNER:=25;
        END IF;
    END IF;
END;
ALTER TRIGGER PUNTOS_GANADOR DISABLE;
--Además, de ahora en adelante, los km de un tramo que pasan por un término municipal
--dependen de la población de éste. Si la población tiene menos de 10000 habitantes los km del tramo 
--que pueden pasar por ese término municipal son 20. Si la población tiene >=10000 y <20000 
--habitantes, los km del tramo que podrán discurrir por ese término municipal serán 50. Para
--poblaciones mayores ya no hay restricciones.
CREATE OR REPLACE TRIGGER RESTRINGIR_TRAMO
    BEFORE INSERT OR UPDATE ON PASSES
    FOR EACH ROW
DECLARE 
    N_HABITANTES TERRAINMUNICIPALITY.TOWN_TM%TYPE;
BEGIN
    SELECT TOWN_TM INTO N_HABITANTES FROM TERRAINMUNICIPALITY WHERE ID_TM=:NEW.ID_TM;
    IF N_HABITANTES < 10000 THEN
        IF (:NEW.KM_EXIT-:NEW.KM_ENTRY)>20 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Los kilómetros del tramo superan el límite de 20 km');
        END IF;
    END IF;
    IF N_HABITANTES >= 10000 AND N_HABITANTES < 20000 THEN
        IF (:NEW.KM_EXIT-:NEW.KM_ENTRY)>50 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Los kilómetros del tramo superan el límite de 50 km');
        END IF;
    END IF;
END;
ALTER TRIGGER RESTRINGIR_TRAMO DISABLE;

-- Ejercicio 7:
--Crear un procedimiento que para cada tramo de carreteras locales que esté en
--áreas de superficie superior a 100 hectáreas y haya tenido incidentes, muestre el tramo
--(orden_carretera), la carretera (id_carretera), el nombre del área (nombre_area) junto con su
--superficie (superficie_area) ordenado por superficie del área de forma descendente. A su vez,
--para cada tramo de este tipo, se pide el número de incidentes total (numincidentes), pero solo se
--pide mostrar los incidentes que no sean referentes a animales sueltos. De estos incidentes,
--además de su identificación (id_incidente) se pide mostrar su descripción (descripción_incidente) 
--y el número de parejas que acuden a gestionarlo (numparejas).
CREATE OR REPLACE PROCEDURE MOSTRAR_CARRETERAS IS
    CURSOR CURSOR_TRAMO IS SELECT TS.ORDER_ROAD, TS.ID_ROAD, TS.NAME_AREA, A.SURFACE_AREA
        FROM TSECTION TS, AREA A WHERE TS.NAME_AREA=A.NAME_AREA AND A.SURFACE_AREA>100 ORDER BY A.SURFACE_AREA DESC;
    CURSOR CURSOR_INCIDENTE(ORDERR INCIDENT.ORDER_ROAD%TYPE, IDR INCIDENT.ID_ROAD%TYPE) IS SELECT INC.ID_INCIDENT, INC.DESCRIP_INCIDENT, COUNT(*) AS N_PAREJAS 
        FROM INCIDENT INC, COMES C WHERE INC.ORDER_ROAD=ORDERR AND INC.ID_ROAD=IDR AND INC.DESCRIP_INCIDENT<>'animales sueltos' 
            AND INC.ID_INCIDENT=C.ID_INCIDENT GROUP BY INC.ID_INCIDENT, INC.DESCRIP_INCIDENT;
    NUMINCIDENTES NUMBER;
BEGIN
    FOR I IN CURSOR_TRAMO LOOP
        SELECT COUNT(*) INTO NUMINCIDENTES FROM INCIDENT
            WHERE ID_ROAD=I.ID_ROAD AND ORDER_ROAD=I.ORDER_ROAD;
        IF NUMINCIDENTES>=1 THEN
            DBMS_OUTPUT.PUT_LINE('TRAMO: '||I.ORDER_ROAD||' '||I.ID_ROAD||' '||I.NAME_AREA||' '||I.SURFACE_AREA||' '||NUMINCIDENTES);            
            FOR J IN CURSOR_INCIDENTE(I.ORDER_ROAD, I.ID_ROAD) LOOP
                DBMS_OUTPUT.PUT_LINE('  INCIDENTE: '||J.ID_INCIDENT||' '||J.DESCRIP_INCIDENT||' '||J.N_PAREJAS);
            END LOOP;
        END IF;
    END LOOP;
END;
EXECUTE MOSTRAR_CARRETERAS;

-- Ejercicio 8:
--Crear una funcion que dada una longitud (lon) y un número máximo de parejas,
--devuelva el número de parejas diferentes que solo acuden a incidentes que tienen lugar en
--tramos de no más de lon km. Además, si dicho número de parejas excede el máximo se deberá 
--tambien devolver un mensaje que alerte de ello (en caso contrario, se devolverá un mensaje de 
--confirmación).
CREATE OR REPLACE FUNCTION DEVUELVE_NPAREJAS
    (LON TSECTION.LENGTH_SECTION%TYPE, MAX_NPAREJAS NUMBER)
    RETURN NUMBER IS
    N_DIFPAREJAS NUMBER;
BEGIN
    SELECT COUNT(*) INTO N_DIFPAREJAS FROM COMES C, INCIDENT I, TSECTION TS
        WHERE C.ID_INCIDENT=I.ID_INCIDENT AND I.ORDER_ROAD=TS.ORDER_ROAD AND I.ID_ROAD=TS.ID_ROAD
            AND TS.LENGTH_SECTION<=LON AND (C.LICENCE1, C.LICENCE2) NOT IN (SELECT C1.LICENCE1, C1.LICENCE2
                FROM COMES C1, INCIDENT I1, TSECTION TS1 WHERE C1.ID_INCIDENT=I1.ID_INCIDENT AND I1.ORDER_ROAD=TS1.ORDER_ROAD 
                    AND I1.ID_ROAD=TS1.ID_ROAD AND TS1.LENGTH_SECTION>LON);
    IF N_DIFPAREJAS>MAX_NPAREJAS THEN
        DBMS_OUTPUT.PUT_LINE('Se ha excedido el máximo');
    END IF;
    IF N_DIFPAREJAS<=MAX_NPAREJAS THEN
        DBMS_OUTPUT.PUT_LINE('Número por debajo del máximo');
    END IF;
    RETURN N_DIFPAREJAS;
END;

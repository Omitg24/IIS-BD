-- CONTROL PL/SQL:
-- Omar Teixeira González, UO281847
SET SERVEROUTPUT ON;
-- Ejercicio 1:
--Según la nueva normativa, el número de patrocinadores qu puede tener un equipo depende del número de
--etapas en las que uno de sus ciclistas ha quedado pimero. Un equipo en el que ningún ciclista ha ganado
--ninguna etapa podrá tener un máximo de 4 patrocinadores. El número de patrocinadores que puede tener el
--equipo se incmentará en 1 cada vez que algún ciclista del equipo gane 2 etapas.
CREATE OR REPLACE TRIGGER MAX_PATROCINADORES
    BEFORE INSERT OR UPDATE ON IS_SPONSORIZED
    FOR EACH ROW
DECLARE
    N_SPONSORS NUMBER;
    N_PRIMEROS NUMBER;
BEGIN
    SELECT COUNT(*) INTO N_SPONSORS FROM IS_SPONSORIZED 
        WHERE NAME_TEAM=:NEW.NAME_TEAM;
    SELECT COUNT(*) INTO N_PRIMEROS FROM TAKES_PART TP,  CYCLIST C 
        WHERE C.NAME_TEAM=:NEW.NAME_TEAM AND C.CYCLIST_NAME=TP.CYCLIST_NAME AND TP.ORDER_CLASSIFICATION='1';
    IF N_PRIMEROS<2 THEN
        RAISE_APPLICATION_ERROR(-20002, 'El número de sponsors supera a los que el equipo puede tener: '||4);
    ELSIF ROUND((N_PRIMEROS/2),0)+4<=N_SPONSORS THEN
        RAISE_APPLICATION_ERROR(-20003, 'El número de sponsors supera a los que el equipo puede tener: '||ROUND((N_PRIMEROS/2),0)+4);
    END IF;
END;
ALTER TRIGGER MAX_PATROCINADORES DISABLE;       

-- Ejercicio 2:
--Crea un procedimiento que muestre para cada tramo (order_road) el nombre del area
--(name_area) y el nombre de la carretera (name_road) a los que pertenece, asi como la longitud del tramo
--(length_section). Mostrar solamente aquellos tramos que tengan incidentes y ordenados por id de 
--carretera (id_road) como primer criterio y por orden de tramo (order_road) como segundo criterio.
--También se debe mostrar, para cada uno de los tramos, los incidentes que han sucedido en ese tramo
--junto con la fecha n la que sucede(date_incident y la descripción del incidente (description_incident), así
--como la antiguedad de los dos agentes que acuden a él (seniority_agent1 y senioriy_agent2).
CREATE OR REPLACE PROCEDURE MOSTRAR_TRAMOS IS
    CURSOR CURSOR_TRAMO IS SELECT TS.ID_ROAD, TS.ORDER_ROAD, TS.NAME_AREA, R.NAME_ROAD, TS.LENGTH_SECTION
        FROM TSECTION TS, ROAD R, INCIDENT I WHERE TS.ID_ROAD=R.ID_ROAD AND TS.ID_ROAD=I.ID_ROAD AND TS.ORDER_ROAD=I.ORDER_ROAD 
            GROUP BY TS.ID_ROAD, TS.ORDER_ROAD, TS.NAME_AREA, R.NAME_ROAD, TS.LENGTH_SECTION HAVING COUNT(I.ID_INCIDENT)>=1 ORDER BY TS.ID_ROAD, TS.ORDER_ROAD;
    CURSOR CURSOR_INCIDENTE(ORDERR INCIDENT.ORDER_ROAD%TYPE, IDR INCIDENT.ID_ROAD%TYPE) IS SELECT I.DATE_INCIDENT, I.DESCRIP_INCIDENT, A1.SENIORITY AS SENIORITY_AGENT1, A2.SENIORITY AS SENIORITY_AGENT2
        FROM INCIDENT I, COMES C, AGENT A1, AGENT A2 WHERE I.ORDER_ROAD=ORDERR AND I.ID_ROAD=IDR AND I.ID_INCIDENT=C.ID_INCIDENT AND C.LICENCE1=A1.LICENCE AND C.LICENCE2=A2.LICENCE;
BEGIN
    FOR I IN CURSOR_TRAMO LOOP
        DBMS_OUTPUT.PUT_LINE('SECTION: '||I.ORDER_ROAD||' '||I.NAME_AREA||' '||I.NAME_ROAD||' '||I.LENGTH_SECTION||' ');
        FOR J IN CURSOR_INCIDENTE(I.ORDER_ROAD, I.ID_ROAD) LOOP
            DBMS_OUTPUT.PUT_LINE('--INCIDENT: '||J.DATE_INCIDENT||' '||J.DESCRIP_INCIDENT||' '||J.SENIORITY_AGENT1||' '||J.SENIORITY_AGENT2);         
        END LOOP;
    END LOOP;
END;
EXECUTE MOSTRAR_TRAMOS;
-- Ejercicio 3:
--Crear una función que dado un ciclista (cyclist_name), devuelva el equipo (name_team) al 
--que pertenece, y además retorne un average_subv_amount según se indica:
--El equipo al que pertenece el ciclista tiene varios patrocinadores. Los patrocinadores subvencionan
--una determinada cantidad al equipo. Entonces, se debe devolve también la cantidad media de dinero
--(average_subv_amount) que aportan los patrocinadores al equipo.
CREATE OR REPLACE FUNCTION AVG_SUBVENCION_EQUIPO (CNAME IN CYCLIST.CYCLIST_NAME%TYPE, TNAME OUT CYCLIST.NAME_TEAM%TYPE)
    RETURN NUMBER IS 
    AVERAGE_SUBV_AMOUNT NUMBER;
BEGIN
    SELECT NAME_TEAM INTO TNAME FROM CYCLIST WHERE CYCLIST_NAME=CNAME;
    SELECT ROUND(AVG(AMOUNT),0) INTO AVERAGE_SUBV_AMOUNT FROM IS_SPONSORIZED WHERE NAME_TEAM=TNAME GROUP BY NAME_TEAM;
    RETURN AVERAGE_SUBV_AMOUNT;
END;
DECLARE 
    CNAME VARCHAR2(50);
    TNAME VARCHAR2(50);
    AVERAGE_SUBV_AMOUNT NUMBER;
BEGIN
    CNAME:='mateo';
    AVERAGE_SUBV_AMOUNT:=AVG_SUBVENCION_EQUIPO(CNAME, TNAME);
    DBMS_OUTPUT.PUT_LINE('El ciclista '||CNAME||' pertenece al equipo '||TNAME||', que tiene una media de subvecion de: '||AVERAGE_SUBV_AMOUNT ||' €');
-- CORRECCIÓN DEL EXAMEN
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('No se ha encontrado al ciclista correspondiente');
-- CORRECCIÓN DEL EXAMEN
END;
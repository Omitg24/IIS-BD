-- EXAMEN PRÁCTICO_EJEMPLO:
SET SERVEROUTPUT ON;
-- Ejercicio 1:
--Implemente el modelo anterior lo más completo posible (claves primarias, únicas, ajenas,
--checks, etc.). Se recuerda que es condición necesaria para corregir el examen que las
--CLAVES PRIMARIAS y las AJENAS estén bien establecidas.
prompt PL/SQL Developer import file
set feedback off
set define off
prompt Creating CINES...
create table CINES
(
  CODCINE   VARCHAR2(20),
  LOCALIDAD VARCHAR2(50),
  CONSTRAINT PK_CINES PRIMARY KEY (CODCINE)
);

prompt Creating SALAS...
create table SALAS
(
  CODSALA VARCHAR2(20),
  AFORO   NUMBER,
  CODCINE   VARCHAR2(20) not null,
  CONSTRAINT PK_SALAS PRIMARY KEY (CODSALA),
  CONSTRAINT FK_SALAS_CINES FOREIGN KEY (CODCINE) REFERENCES CINES (CODCINE)
);

prompt Creating PELICULAS...
create table PELICULAS
(
  CODPELICULA VARCHAR2(20),
  TITULO      VARCHAR2(100),
  DURACION    NUMBER,
  TIPO        VARCHAR2(20) not null,
  CONSTRAINT PK_PELICULAS PRIMARY KEY (CODPELICULA),
  CONSTRAINT CK_PELICULAS_TIPO CHECK (TIPO IN ('ficcion', 'aventuras', 'terror'))
);

prompt Creating PROYECTAN...
create table PROYECTAN
(
  CODSALA          VARCHAR2(20),
  CODPELICULA      VARCHAR2(20),
  SESION           NUMBER,
  FECHA            DATE,
  ENTRADASVENDIDAS NUMBER,
  CONSTRAINT PK_PROYECTAN PRIMARY KEY (CODSALA,CODPELICULA,SESION,FECHA),
  CONSTRAINT FK_PROYECTAN_SALAS FOREIGN KEY (CODSALA) REFERENCES SALAS (CODSALA),
  CONSTRAINT FK_PROYECTAN_PELICULAS FOREIGN KEY (CODPELICULA) REFERENCES PELICULAS (CODPELICULA),
  CONSTRAINT CK_PROYECTAN_TSESION CHECK (SESION IN (5,7,10))
);

prompt Creating ENTRADAS...
create table ENTRADAS
(
  CODENTRADA  VARCHAR2(20),
  PRECIO      NUMBER,
  CODSALA     VARCHAR2(20),
  CODPELICULA VARCHAR2(20),
  SESION      NUMBER,
  FECHA       DATE,
  CONSTRAINT PK_ENTRADAS PRIMARY KEY (CODENTRADA),
  CONSTRAINT FK_ENTRADAS_PROYECTAN FOREIGN KEY (CODSALA,CODPELICULA,SESION,FECHA) REFERENCES PROYECTAN (CODSALA,CODPELICULA,SESION,FECHA)
);

prompt Deleting ENTRADAS...
delete from ENTRADAS;
commit;
prompt Deleting PROYECTAN...
delete from PROYECTAN;
commit;
prompt Deleting PELICULAS...
delete from PELICULAS;
commit;
prompt Deleting SALAS...
delete from SALAS;
commit;
prompt Deleting CINES...
delete from CINES;
commit;

prompt Loading CINES...
insert into CINES (CODCINE, LOCALIDAD) values ('c1', 'Aviles');
insert into CINES (CODCINE, LOCALIDAD) values ('c2', 'Aviles');
insert into CINES (CODCINE, LOCALIDAD) values ('c3', 'Gijon');
insert into CINES (CODCINE, LOCALIDAD) values ('c4', 'Oviedo');
commit;
prompt 4 records loaded

prompt Loading SALAS...
insert into SALAS (CODSALA, AFORO, CODCINE) values ('1', 5, 'c1');
insert into SALAS (CODSALA, AFORO, CODCINE) values ('2', 4, 'c2');
insert into SALAS (CODSALA, AFORO, CODCINE) values ('3', 5, 'c3');
insert into SALAS (CODSALA, AFORO, CODCINE) values ('4', 3, 'c1');
insert into SALAS (CODSALA, AFORO, CODCINE) values ('5', 3, 'c2');
insert into SALAS (CODSALA, AFORO, CODCINE) values ('6', 3, 'c3');
insert into SALAS (CODSALA, AFORO, CODCINE) values ('7', 2, 'c4');
insert into SALAS (CODSALA, AFORO, CODCINE) values ('8', 5, 'c1');
insert into SALAS (CODSALA, AFORO, CODCINE) values ('9', 4, 'c2');
insert into SALAS (CODSALA, AFORO, CODCINE) values ('10', 3, 'c3');
insert into SALAS (CODSALA, AFORO, CODCINE) values ('11', 1, 'c1');
insert into SALAS (CODSALA, AFORO, CODCINE) values ('12', 1, 'c2');
insert into SALAS (CODSALA, AFORO, CODCINE) values ('13', 3, 'c3');
insert into SALAS (CODSALA, AFORO, CODCINE) values ('14', 3, 'c1');
commit;
prompt 14 records loaded

prompt Loading PELICULAS...
insert into PELICULAS (CODPELICULA, TITULO, DURACION, TIPO) values ('p1', 'Titulo1', 100, 'ficcion');
insert into PELICULAS (CODPELICULA, TITULO, DURACION, TIPO) values ('p2', 'Titulo2', 90, 'aventuras');
insert into PELICULAS (CODPELICULA, TITULO, DURACION, TIPO) values ('p3', 'Titulo3', 85, 'ficcion');
insert into PELICULAS (CODPELICULA, TITULO, DURACION, TIPO) values ('p4', 'Titulo4', 65, 'aventuras');
insert into PELICULAS (CODPELICULA, TITULO, DURACION, TIPO) values ('p5', 'Titulo5', 75, 'aventuras');
insert into PELICULAS (CODPELICULA, TITULO, DURACION, TIPO) values ('p6', 'Titulo6', 90, 'terror');
insert into PELICULAS (CODPELICULA, TITULO, DURACION, TIPO) values ('p7', 'Titulo7', 101, 'aventuras');
insert into PELICULAS (CODPELICULA, TITULO, DURACION, TIPO) values ('p8', 'Titulo8', 95, 'terror');
insert into PELICULAS (CODPELICULA, TITULO, DURACION, TIPO) values ('p9', 'Titulo9', 70, 'aventuras');
insert into PELICULAS (CODPELICULA, TITULO, DURACION, TIPO) values ('p10', 'Titulo10', 80, 'ficcion');
insert into PELICULAS (CODPELICULA, TITULO, DURACION, TIPO) values ('p11', 'Titulo11', 85, 'terror');
insert into PELICULAS (CODPELICULA, TITULO, DURACION, TIPO) values ('p12', 'Titulo12', 60, 'aventuras');
commit;
prompt 12 records loaded

prompt Loading PROYECTAN...
insert into PROYECTAN (CODSALA, CODPELICULA, SESION, FECHA, ENTRADASVENDIDAS) values ('1', 'p1', 5, to_date('11-02-2009', 'dd-mm-yyyy'), 2);
insert into PROYECTAN (CODSALA, CODPELICULA, SESION, FECHA, ENTRADASVENDIDAS) values ('2', 'p2', 7, to_date('11-02-2009', 'dd-mm-yyyy'), 1);
insert into PROYECTAN (CODSALA, CODPELICULA, SESION, FECHA, ENTRADASVENDIDAS) values ('3', 'p3', 10, to_date('11-02-2009', 'dd-mm-yyyy'), 1);
insert into PROYECTAN (CODSALA, CODPELICULA, SESION, FECHA, ENTRADASVENDIDAS) values ('4', 'p1', 5, to_date('11-02-2009', 'dd-mm-yyyy'), 1);
insert into PROYECTAN (CODSALA, CODPELICULA, SESION, FECHA, ENTRADASVENDIDAS) values ('5', 'p2', 7, to_date('10-02-2009', 'dd-mm-yyyy'), 1);
insert into PROYECTAN (CODSALA, CODPELICULA, SESION, FECHA, ENTRADASVENDIDAS) values ('6', 'p3', 10, to_date('10-02-2009', 'dd-mm-yyyy'), 1);
insert into PROYECTAN (CODSALA, CODPELICULA, SESION, FECHA, ENTRADASVENDIDAS) values ('7', 'p4', 5, to_date('09-02-2009', 'dd-mm-yyyy'), 1);
insert into PROYECTAN (CODSALA, CODPELICULA, SESION, FECHA, ENTRADASVENDIDAS) values ('1', 'p5', 7, to_date('09-02-2009', 'dd-mm-yyyy'), 0);
insert into PROYECTAN (CODSALA, CODPELICULA, SESION, FECHA, ENTRADASVENDIDAS) values ('2', 'p5', 10, to_date('09-02-2009', 'dd-mm-yyyy'), 0);
insert into PROYECTAN (CODSALA, CODPELICULA, SESION, FECHA, ENTRADASVENDIDAS) values ('3', 'p6', 5, to_date('09-02-2009', 'dd-mm-yyyy'), 0);
insert into PROYECTAN (CODSALA, CODPELICULA, SESION, FECHA, ENTRADASVENDIDAS) values ('4', 'p7', 10, to_date('09-02-2009', 'dd-mm-yyyy'), 0);
insert into PROYECTAN (CODSALA, CODPELICULA, SESION, FECHA, ENTRADASVENDIDAS) values ('5', 'p8', 10, to_date('09-02-2009', 'dd-mm-yyyy'), 0);
insert into PROYECTAN (CODSALA, CODPELICULA, SESION, FECHA, ENTRADASVENDIDAS) values ('1', 'p1', 10, to_date('08-02-2009', 'dd-mm-yyyy'), 0);
insert into PROYECTAN (CODSALA, CODPELICULA, SESION, FECHA, ENTRADASVENDIDAS) values ('2', 'p3', 10, to_date('08-02-2009', 'dd-mm-yyyy'), 0);
insert into PROYECTAN (CODSALA, CODPELICULA, SESION, FECHA, ENTRADASVENDIDAS) values ('1', 'p2', 5, to_date('08-02-2009', 'dd-mm-yyyy'), 1);
commit;
prompt 15 records loaded

prompt Loading ENTRADAS...
insert into ENTRADAS (CODENTRADA, PRECIO, CODSALA, CODPELICULA, SESION, FECHA) values ('e1', 6, '1', 'p1', 5, to_date('11-02-2009', 'dd-mm-yyyy'));
insert into ENTRADAS (CODENTRADA, PRECIO, CODSALA, CODPELICULA, SESION, FECHA) values ('e2', 5, '2', 'p2', 7, to_date('11-02-2009', 'dd-mm-yyyy'));
insert into ENTRADAS (CODENTRADA, PRECIO, CODSALA, CODPELICULA, SESION, FECHA) values ('e3', 9, '3', 'p3', 10, to_date('11-02-2009', 'dd-mm-yyyy'));
insert into ENTRADAS (CODENTRADA, PRECIO, CODSALA, CODPELICULA, SESION, FECHA) values ('e4', 7, '4', 'p1', 5, to_date('11-02-2009', 'dd-mm-yyyy'));
insert into ENTRADAS (CODENTRADA, PRECIO, CODSALA, CODPELICULA, SESION, FECHA) values ('e5', 6, '5', 'p2', 7, to_date('10-02-2009', 'dd-mm-yyyy'));
insert into ENTRADAS (CODENTRADA, PRECIO, CODSALA, CODPELICULA, SESION, FECHA) values ('e6', 5, '6', 'p3', 10, to_date('10-02-2009', 'dd-mm-yyyy'));
insert into ENTRADAS (CODENTRADA, PRECIO, CODSALA, CODPELICULA, SESION, FECHA) values ('e7', 4, '7', 'p4', 5, to_date('09-02-2009', 'dd-mm-yyyy'));
insert into ENTRADAS (CODENTRADA, PRECIO, CODSALA, CODPELICULA, SESION, FECHA) values ('e8', 9, '1', 'p2', 5, to_date('08-02-2009', 'dd-mm-yyyy'));
insert into ENTRADAS (CODENTRADA, PRECIO, CODSALA, CODPELICULA, SESION, FECHA) values ('e9', 8, '1', 'p1', 5, to_date('11-02-2009', 'dd-mm-yyyy'));
commit;
prompt 9 records loaded

set feedback on
set define on
prompt Done.

-- Ejercicio 2:
--Una función que devuelva el tipo de la película más vista en la última sesión.
CREATE OR REPLACE FUNCTION PELICULA_MAS_VISTA
    RETURN PELICULAS.TIPO%TYPE IS
        T_PELICULA PELICULAS.TIPO%TYPE;
    
BEGIN
    SELECT TIPO INTO T_PELICULA FROM PELICULAS WHERE CODPELICULA = 
    (SELECT CODPELICULA FROM PROYECTAN WHERE
        SESION = (SELECT MAX(SESION) FROM PROYECTAN) 
            GROUP BY CODPELICULA ORDER BY SUM(ENTRADASVENDIDAS) DESC FETCH FIRST 1 ROWS ONLY);    
    RETURN T_PELICULA;
END;
DECLARE 
    T_PELICULA VARCHAR2(20);
BEGIN
    T_PELICULA:=PELICULA_MAS_VISTA;
    DBMS_OUTPUT.PUT_LINE('El tipo de la película más vista es: '||T_PELICULA);    
END;

-- Ejercicio 3:
--Una función o procedimiento que muestre por pantalla (DBMS_OUTPUT) para los
--cines de una determinada localidad, que recibe como parámetro, la recaudación total
--obtenida en cada cine, así como la obtenida por cada una de las películas en él
--proyectadas.
    --Cine 1 – Recaudación_total
        --Codpelicula1 – Titulo1 – Recaudación_total_pelicula_1_en_cine1
        --Codpelicula 2 – Titulo2 – Recaudación _total_pelicula_2_en_cine1
    --Cine 2 – Recaudación_total
        --Codpelicula1 – Titulo1 – Recaudación_total_película_ 1_en_cine2
        --Codpelicula 2 – Titulo2 – Recaudación_total_película _ 2_en_cine2
        --Codpelicula 3 - Titulo3 – Recaudación_total_película_3_en_cine2
CREATE OR REPLACE PROCEDURE MOSTRAR_CINES_POR_LOCALIDAD(LCL CINES.LOCALIDAD%TYPE) IS
    CURSOR CURSORCINES IS SELECT C.CODCINE, SUM(E.PRECIO) AS TOTAL_CINE
        FROM CINES C, SALAS S, ENTRADAS E WHERE C.LOCALIDAD=LCL
            AND C.CODCINE=S.CODCINE AND S.CODSALA=E.CODSALA GROUP BY C.CODCINE;
    CURSOR CURSORPELICULAS (CCINE CINES.CODCINE%TYPE) IS SELECT P.CODPELICULA, P.TITULO, SUM(E.PRECIO) AS TOTAL_PELICULA 
        FROM PELICULAS P, ENTRADAS E, SALAS S
            WHERE S.CODCINE=CCINE AND S.CODSALA=E.CODSALA 
                AND E.CODPELICULA=P.CODPELICULA GROUP BY P.CODPELICULA, P.TITULO;
BEGIN
    FOR I IN CURSORCINES LOOP
        DBMS_OUTPUT.PUT_LINE('Cine '||I.CODCINE||' - Recaudación total: '||I.TOTAL_CINE);
        FOR J IN CURSORPELICULAS(I.CODCINE) LOOP
            DBMS_OUTPUT.PUT_LINE('   Película '||J.CODPELICULA||' - Titulo: '||J.TITULO||' - Recaudación total en cine '||I.CODCINE||': '||J.TOTAL_PELICULA);
        END LOOP;
    END LOOP;
END;
EXECUTE MOSTRAR_CINES_POR_LOCALIDAD('Aviles');

-- Ejercicio 4:
--Realizar un listado en el que se indique la siguiente información para cada película.
    --Titulo_Pelicula 1
        --Cine 1
            --Sala – Sesión – Nº de espectadores
            --Sala – Sesión – Nº de espectadores
        --Cine 2
            --Sala – Sesión – Nº de espectadores
            --Sala – Sesión – Nº de espectadores
--El número de espectadores se entiende que es el número de entradas vendidas para esa
--película en esa sala durante esa sesión.
CREATE OR REPLACE PROCEDURE LISTADO_PELICULAS IS
    CURSOR CURSOR_PELICULAS IS SELECT CODPELICULA, TITULO FROM PELICULAS;
    CURSOR CURSOR_CINES(CPELI PELICULAS.CODPELICULA%TYPE) IS SELECT CODCINE 
        FROM SALAS S, PROYECTAN P WHERE P.CODPELICULA=CPELI 
            AND P.CODSALA=S.CODSALA GROUP BY CODCINE;
    CURSOR CURSOR_SALAS(CCINE CINES.CODCINE%TYPE, CPELI PELICULAS.CODPELICULA%TYPE) IS SELECT S.CODSALA, P.SESION, SUM(P.ENTRADASVENDIDAS) AS N_ESPECTADORES
        FROM SALAS S, PROYECTAN P WHERE S.CODCINE=CCINE
            AND S.CODSALA=P.CODSALA AND P.CODPELICULA=CPELI GROUP BY S.CODSALA, P.SESION;
BEGIN
    FOR I IN CURSOR_PELICULAS LOOP
        DBMS_OUTPUT.PUT_LINE('Titulo: '||I.TITULO);
        FOR J IN CURSOR_CINES(I.CODPELICULA) LOOP
            DBMS_OUTPUT.PUT_LINE('  Cine '||J.CODCINE);
            FOR K IN CURSOR_SALAS(J.CODCINE, I.CODPELICULA) LOOP
                DBMS_OUTPUT.PUT_LINE('      Sala '||K.CODSALA||' - Sesión: '||K.SESION||' - Nº Espectadores: '||K.N_ESPECTADORES);
            END LOOP;
        END LOOP;
    END LOOP;
END;

EXECUTE LISTADO_PELICULAS;


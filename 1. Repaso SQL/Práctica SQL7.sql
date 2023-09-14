 -- PRÁCTICA SQL7:
-- Ejercicio 1:
--Obtener el nombre de las estaciones y su número de transformadores, para las estaciones
--en las que alguna de las centrales nucleares que les entregan energía genera más de 25000
--residuos.
SELECT ES.ENOMBRE, ES.TRANSFORMADORES FROM ESTACION ES, ENTREGA EN, NUCLEAR N
    WHERE ES.ENOMBRE=EN.ENOMBRE AND EN.PNOMBRE=N.PNOMBRE AND N.RESIDUOS>25000;
    
-- Ejercicio 2:
--Obtener el nombre de las compañías que comienza por la letra ‘C’ que poseen redes de
--distribución que envían energía a otras redes, pero no reciben energía de ninguna otra red.
SELECT DISTINCT C.CNOMBRE FROM COMPANIA C, PERTENECE P, RED_DISTRIBUCION R, ENVIA_ENERGIA E
    WHERE  C.CNOMBRE LIKE 'C%' AND C.CNOMBRE=P.CNOMBRE AND P.NUMRED=R.NUMRED AND R.NUMRED=E.NUMRED_ENVIA AND R.NUMRED<>E.NUMRED_RECIBE;

-- Ejercicio 3:
--Obtener para cada envío de energía entre redes de distribución, el número de red de la red
--que envía energía y de la que la recibe, así como el volumen de energía del envío siempre y
--cuando la estación de cabecera de la red que envía energía tenga un número de
--transformadores mayor que el número de transformadores de la red que recibe la energía y
--el volumen de energía enviado sea mayor de 16000W.
SELECT EE.NUMRED_ENVIA, EE.NUMRED_RECIBE, EE.VOLUMEN FROM ENVIA_ENERGIA EE, RED_DISTRIBUCION RE, ESTACION ESE, RED_DISTRIBUCION RR, ESTACION ESR
    WHERE EE.NUMRED_ENVIA=RE.NUMRED AND RE.ENOMBRE=ESE.ENOMBRE AND EE.NUMRED_RECIBE=RR.NUMRED AND RR.ENOMBRE=ESR.ENOMBRE AND
        ESE.TRANSFORMADORES>ESR.TRANSFORMADORES AND EE.VOLUMEN>16000;

-- Ejercicio 4:
--Obtener el nombre y el número de transformadores de las estaciones que tengan más de
--800 transformadores y que sean cabeceras de redes de distribución que no abastecen a
--subestaciones con un número total acumulado de consumidores particulares mayor que el
--número total acumulado de consumidores de empresas.
SELECT DISTINCT ES.ENOMBRE, ES.TRANSFORMADORES FROM ESTACION ES, RED_DISTRIBUCION R
    WHERE ES.TRANSFORMADORES>800 AND ES.ENOMBRE=R.ENOMBRE AND R.NUMRED NOT IN 
        (SELECT S.NUMRED FROM SUBESTACION S, DISTRIBUYE D, ZONA Z 
            WHERE S.NSUBESTACION=D.NSUBESTACION AND D.ZCODIGO=Z.ZCODIGO
                GROUP BY S.NUMRED HAVING SUM(Z.CONSPARTICULARES)>SUM(Z.CONSEMPRESAS));

-- Ejercicio 5:
--Obtener el nombre y el número de reactores de los productores nucleares (ordenados de
--forma descendente por residuos generados) cuyo nombre comienza por 'C' y se trate de
--productores que entregan energía a estaciones con más de 300 transformadores y que sean
--cabecera de redes de distribución de longitud máxima superior a 125000 y que dichas redes
--dispongan de al menos una línea instalada.
SELECT N.PNOMBRE, N.NUMREACTORES FROM NUCLEAR N, ENTREGA EN, ESTACION ES, RED_DISTRIBUCION R, LINEA L
    WHERE N.PNOMBRE LIKE 'C%' AND N.PNOMBRE=EN.PNOMBRE AND EN.ENOMBRE=ES.ENOMBRE AND ES.TRANSFORMADORES>300 
        AND ES.ENOMBRE=R.ENOMBRE AND R.LONGITUDMAXIMA>125000 AND R.NUMRED=L.NUMRED ORDER BY N.RESIDUOS DESC;

-- Ejercicio 6:
--Obtener el nombre, la producción media y el número de reactores de los productores
--nucleares que compran plutonio a suministradores con mayor stock de todos.
SELECT N.PNOMBRE, P.PRODMEDIA, N.NUMREACTORES FROM PRODUCTOR P, NUCLEAR N, COMPRA C, SUMINISTRADOR S
    WHERE P.PNOMBRE=N.PNOMBRE AND N.PNOMBRE=C.PNOMBRE AND C.SNOMBRE=S.SNOMBRE AND C.PAIS=S.PAIS AND S.STOCK = 
        (SELECT MAX(STOCK) FROM SUMINISTRADOR);

-- Ejercicio 7:
--Obtener el nombre y capital social de las compañías de más de 50 M de dicho capital, así
--como el número total de acciones que poseen dichas compañías en redes de distribución
--que ni envían ni reciben energía de ninguna otra red de distribución y siempre y cuando
--dicho número total de acciones sea mayor que 25000.
SELECT C.CNOMBRE, C.CAPITALSOCIAL, SUM(P.NUMACCIONES) FROM COMPANIA C, PERTENECE P
    WHERE C.CAPITALSOCIAL>50 AND C.CNOMBRE=P.CNOMBRE AND P.NUMRED NOT IN 
        (SELECT R.NUMRED FROM RED_DISTRIBUCION R, ENVIA_ENERGIA EE 
            WHERE R.NUMRED IN (EE.NUMRED_ENVIA, EE.NUMRED_RECIBE)) GROUP BY C.CNOMBRE, C.CAPITALSOCIAL HAVING SUM(P.NUMACCIONES)>25000;

-- Ejercicio 8:
--Obtener el nombre de las estaciones junto con su número de transformadores para
--aquellas estaciones que son cabecera de las redes de distribución cuyas líneas abastecen las
--subestaciones que distribuyen energía solo a zonas cuyo consumo en instituciones es
--mayor que el consumo de particulares.
SELECT DISTINCT ES.ENOMBRE, ES.TRANSFORMADORES FROM ESTACION ES, RED_DISTRIBUCION R, SUBESTACION S
    WHERE ES.ENOMBRE=R.ENOMBRE AND R.NUMRED=S.NUMRED AND S.NSUBESTACION IN 
        ((SELECT NSUBESTACION FROM DISTRIBUYE)
        MINUS (SELECT NSUBESTACION FROM DISTRIBUYE D, ZONA Z
            WHERE D.ZCODIGO=Z.ZCODIGO AND Z.CONSINSTITUCIONES<=Z.CONSPARTICULARES));

-- Ejercicio 9:
--Obtener el nombre de las provincias que tienen más de una zona cuyas empresas
--consumen (consEmpresas) más que las instituciones (consInstituciones). Además, solo
--deben salir las provincias cuyo consumo medio máximo de dichas zonas sea superior a
--20000. Muestra el resultado ordenado de forma descendente por el nombre de las
--provincias.
SELECT NOMBRE FROM PROVINCIA P, ZONA Z
    WHERE P.PCODIGO=Z.PCODIGO AND Z.CONSEMPRESAS>Z.CONSINSTITUCIONES GROUP BY NOMBRE
        HAVING MAX(Z.CONSUMOMEDIO)>20000 AND COUNT(*)>1 ORDER BY NOMBRE DESC;

-- Ejercicio 10:
--Obtener el nombre y el número de transformadores de las estaciones cuyo nombre
--empiece por M y que son cabecera de al menos una red que envía y recibe energía (ambas
--cosas).
SELECT DISTINCT ES.ENOMBRE, ES.TRANSFORMADORES FROM ESTACION ES, RED_DISTRIBUCION R
    WHERE ES.ENOMBRE LIKE 'M%' AND ES.ENOMBRE=R.ENOMBRE 
        AND R.NUMRED IN (SELECT NUMRED_ENVIA FROM ENVIA_ENERGIA)
            AND R.NUMRED IN (SELECT NUMRED_RECIBE FROM ENVIA_ENERGIA);

-- Ejercicio 11:
--Obtener el nombre de los productores nucleares que compran plutonio a algún
--suministrador y que solo entregan energía a estaciones que no son cabecera de ninguna red
--de distribución.
SELECT PNOMBRE FROM COMPRA WHERE PNOMBRE IN (
    (SELECT PNOMBRE FROM ENTREGA)
    MINUS (
    (SELECT EN.PNOMBRE FROM ENTREGA EN, RED_DISTRIBUCION R WHERE EN.ENOMBRE=R.ENOMBRE)));

-- Ejercicio 12:
--Obtener el número de red junto con sus líneas (nlinea) y la longitud de éstas para aquellas
--redes de distribución que envían energía a otras redes de distribución cuya estación de
--cabecera es la que recibe menos cantidad de energía de los productores.
SELECT DISTINCT RE.NUMRED, L.NLINEA, L.LONGITUD FROM LINEA L, RED_DISTRIBUCION RE, ENVIA_ENERGIA EE, RED_DISTRIBUCION RR, ESTACION ES, ENTREGA EN
    WHERE RE.NUMRED=EE.NUMRED_ENVIA AND L.NUMRED=RE.NUMRED AND RR.NUMRED=EE.NUMRED_RECIBE AND RR.ENOMBRE IN (
        SELECT ENOMBRE FROM ENTREGA GROUP BY ENOMBRE HAVING SUM(CANTIDAD) <= ALL (SELECT SUM(CANTIDAD) FROM ENTREGA GROUP BY ENOMBRE));

-- Ejercicio 13:
--Incrementar en 10 unidades el número de transformadores de aquellas estaciones en las
--que alguna de las centrales nucleares que les entregan energía genera un volumen de
--residuos superior a 30000.
SELECT ES.ENOMBRE, 10+TRANSFORMADORES FROM ESTACION ES, ENTREGA EN, NUCLEAR N
    WHERE ES.ENOMBRE=EN.ENOMBRE AND EN.PNOMBRE=N.PNOMBRE AND N.RESIDUOS>30000;
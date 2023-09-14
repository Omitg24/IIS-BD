-- PRÁCTICA SQL2
-- Ejercicio 1:
--Obtener las tuplas de la relación MARCAS para las que el atributo ciudad es ‘barcelona’.
SELECT * FROM MARCAS WHERE CIUDADM='barcelona';

-- Ejercicio 2:
--Obtener las tuplas de la relación CLIENTES para aquellos clientes de ‘madrid’ cuyo apellido
--es ‘garcía’.
SELECT * FROM CLIENTES WHERE CIUDAD='madrid' AND APELLIDO='garcia';
--Lo mismo para los clientes que cumplen alguna de esas dos condiciones.
SELECT * FROM CLIENTES WHERE CIUDAD='madrid' OR APELLIDO='garcia';

-- Ejercicio 3:
--Obtener una relación en la que aparezcan los valores de los atributos apellido y ciudad de la
--relación CLIENTES.
SELECT APELLIDO, CIUDAD FROM CLIENTES;

-- Ejercicio 4:
--Obtener una relación en la que aparezcan los apellidos de los CLIENTES de ‘madrid’.
SELECT APELLIDO FROM CLIENTES WHERE CIUDAD='madrid';

-- Ejercicio 5:
--Obtener los nombres de las marcas que tienen modelos 'gtd'.
SELECT NOMBREM FROM MARCAS WHERE CIFM IN (
    SELECT CIFM FROM MARCO WHERE CODCOCHE IN (
        SELECT CODCOCHE FROM COCHES WHERE MODELO='gtd'));
        
-- Ejercicio 6:
--Obtener el nombre de las marcas de las que se han vendido coches de color rojo.
SELECT NOMBREM FROM MARCAS WHERE CIFM IN (
    SELECT CIFM FROM MARCO WHERE CODCOCHE IN (
        SELECT CODCOCHE FROM COCHES WHERE CODCOCHE IN (
            SELECT CODCOCHE FROM VENTAS WHERE COLOR='rojo')));
--Otra forma de hacerlo:
SELECT NOMBREM FROM MARCAS M, MARCO MC, VENTAS V 
    WHERE M.CIFM=MC.CIFM AND MC.CODCOCHE=V.CODCOCHE AND V.COLOR='rojo';
    
-- Ejercicio 7:
--Obtener el nombre de los coches que tengan los mismos modelos que el coche cuyo nombre
--es ‘cordoba’.
SELECT C2.NOMBRECH FROM COCHES C1, COCHES C2
    WHERE C1.MODELO=C2.MODELO AND C1.NOMBRECH='cordoba';

-- Ejercicio 8:
--Obtener los nombres de los coches que no tengan el modelo 'gtd'.
SELECT DISTINCT NOMBRECH FROM COCHES 
    WHERE NOMBRECH NOT IN (SELECT NOMBRECH FROM COCHES WHERE MODELO='gtd');

-- Ejercicio 9:
--Obtener todas las tuplas de la relación CONCESIONARIOS.
SELECT * FROM CONCESIONARIOS;

-- Ejercicio 10:
--Obtener todas las parejas de valores de los atributos cifm de la relación MARCAS y dni de la
--relación CLIENTES que sean de la misma ciudad.
SELECT M.CIFM, C.DNI FROM MARCAS M, CLIENTES C WHERE M.CIUDADM=C.CIUDAD;
--Lo mismo para los que no sean de la misma ciudad.
SELECT M.CIFM, C.DNI FROM MARCAS M, CLIENTES C WHERE M.CIUDADM<>C.CIUDAD;

-- Ejercicio 11:
--Obtener los valores del atributo codcoche para los coches que se encuentran en algún
--concesionario de 'barcelona'.
SELECT CODCOCHE FROM COCHES WHERE CODCOCHE IN (
    SELECT CODCOCHE FROM DISTRIBUCION WHERE CIFC IN (
        SELECT CIFC FROM CONCESIONARIOS WHERE CIUDADC='barcelona'));
--Otra forma de hacerlo:
SELECT CC.CODCOCHE FROM COCHES CC, DISTRIBUCION D, CONCESIONARIOS CN
    WHERE CC.CODCOCHE=D.CODCOCHE AND D.CIFC=CN.CIFC AND CN.CIUDADC='barcelona';
    
-- Ejercicio 12:
--Obtener los valores del atributo codcoche para los coches que han sido adquiridos por un
--cliente de ‘madrid’ en un concesionario de ‘madrid’.
SELECT CODCOCHE FROM VENTAS WHERE 
    (DNI IN (SELECT DNI FROM CLIENTES WHERE CIUDAD='madrid'))
        AND 
    (CIFC IN (SELECT CIFC FROM CONCESIONARIOS WHERE CIUDADC='madrid'));
--Otra forma de hacerlo:
SELECT V.CODCOCHE FROM VENTAS V, CLIENTES CL, CONCESIONARIOS CN 
    WHERE V.DNI=CL.DNI AND CL.CIUDAD='madrid' 
        AND V.CIFC=CN.CIFC AND CN.CIUDADC='madrid';

-- Ejercicio 13:
--Obtener los valores del atributo codcoche para los coches comprados en un concesionario de
--la misma ciudad que la del cliente que lo compra.
SELECT V.CODCOCHE FROM VENTAS V, CLIENTES CL, CONCESIONARIOS CN
    WHERE V.DNI=CL.DNI AND V.CIFC=CN.CIFC AND CL.CIUDAD=CN.CIUDADC;

-- Ejercicio 14:
--Obtener todas las parejas de nombres de marcas que sean de la misma ciudad.
SELECT M1.NOMBREM, M2.NOMBREM FROM MARCAS M1, MARCAS M2 
    WHERE M1.CIUDADM=M2.CIUDADM AND M1.NOMBREM!=M2.NOMBREM;

-- Ejercicio 15:
--Obtener todas las tuplas de la relación clientes correspondientes a clientes de ‘madrid’
SELECT * FROM CLIENTES WHERE CIUDAD='madrid';

-- Ejercicio 16:
--Obtener el dni de los clientes que han comprado algún coche en un concesionario de ‘madrid’.
SELECT DISTINCT V.DNI FROM VENTAS V, CONCESIONARIOS C
    WHERE V.CIFC=C.CIFC AND C.CIUDADC='madrid';
    
-- Ejercicio 17:
--Obtener los colores de los coches vendidos por el concesionario ‘acar’.
SELECT DISTINCT V.COLOR FROM VENTAS V, CONCESIONARIOS C
    WHERE V.CIFC=C.CIFC AND C.NOMBREC='acar';
    
-- Ejercicio 18:
--Obtener los valores del atributo codcoche para los coches vendidos por algún concesionario
--de ‘madrid’.
SELECT DISTINCT V.CODCOCHE FROM VENTAS V, CONCESIONARIOS C
    WHERE V.CIFC=C.CIFC AND C.CIUDADC='madrid';
    
-- Ejercicio 19:
--Obtener todos los nombres de los clientes que hayan adquirido algún coche en el
--concesionario ‘dcar’.
SELECT CL.NOMBRE FROM CLIENTES CL, VENTAS V, CONCESIONARIOS CN
    WHERE CL.DNI=V.DNI AND V.CIFC=CN.CIFC AND CN.NOMBREC='dcar';

-- Ejercicio 20:
--Obtener el nombre y el apellido de los clientes que han adquirido un coche modelo ‘gti’ de
--color ‘blanco’.
SELECT CL.NOMBRE, CL.APELLIDO FROM CLIENTES CL, VENTAS V, COCHES CC
    WHERE CL.DNI=V.DNI AND V.COLOR='blanco' AND V.CODCOCHE=CC.CODCOCHE AND CC.MODELO='gti';

-- Ejercicio 21:
--Obtener el nombre y el apellido de los clientes que han adquirido un automóvil en un
--concesionario de ‘madrid’ que dispone de coches del modelo ‘gti’.
SELECT DISTINCT CL.NOMBRE, CL.APELLIDO FROM CLIENTES CL, VENTAS V, COCHES CC, CONCESIONARIOS CN
    WHERE CL.DNI=V.DNI AND V.CIFC=CN.CIFC AND V.CODCOCHE=CC.CODCOCHE AND CN.CIUDADC='madrid' AND CC.MODELO='gti';
    
-- Ejercicio 22:
--Obtener el nombre y el apellido de los clientes que han comprado como mínimo un coche
--‘blanco’ y un coche ‘rojo’.
SELECT CL.NOMBRE, CL.APELLIDO FROM CLIENTES CL, VENTAS V1, VENTAS V2
    WHERE CL.DNI=V1.DNI AND CL.DNI=V2.DNI AND V1.COLOR='blanco' AND V2.COLOR='rojo';
    
-- Ejercicio 23:
--Obtener los valores del atributo dni para los clientes que sólo han comprado coches al
--concesionario con cifc igual a ‘1’.
SELECT DISTINCT DNI FROM VENTAS 
    WHERE DNI NOT IN (SELECT DNI FROM VENTAS WHERE CIFC!='1');
    
-- Ejercicio 24:
--Obtener los nombres de los clientes que no han comprado coches de color ‘rojo’ en
--concesionarios de ‘madrid’.
SELECT DISTINCT CL.NOMBRE FROM CLIENTES CL, VENTAS V
    WHERE CL.DNI=V.DNI AND CL.DNI NOT IN (SELECT V.DNI FROM CONCESIONARIOS CN, VENTAS V
        WHERE CN.CIFC=V.CIFC AND CN.CIUDADC='madrid' AND V.COLOR='rojo');
        
-- Ejercicio 25:
--Mostrar para cada concesionario (cifc) la cantidad total de coches que contiene
SELECT DISTINCT CIFC, SUM(CANTIDAD) FROM DISTRIBUCION GROUP BY CIFC;

-- Ejercicio 26:
--Mostrar el cifc de aquellos concesionarios cuyo promedio de coches almacenados en él supera
--las 10 unidades. Mostrar también dicho promedio.
SELECT CIFC, AVG(CANTIDAD) FROM DISTRIBUCION GROUP BY CIFC HAVING AVG(CANTIDAD)>=10;

-- Ejercicio 27:
--Obtener el cifc de todos los concesionarios que disponen de una cantidad de coches
--comprendida entre 10 y 18 unidades, ambas inclusive.
SELECT CIFC, SUM(CANTIDAD) FROM DISTRIBUCION GROUP BY CIFC HAVING SUM(CANTIDAD) BETWEEN 10 AND 18;

-- Ejercicio 28:
--Obtener el número de marcas disponibles.
SELECT COUNT(*) FROM MARCAS;
--Obtener el número de ciudades donde existen marcas.
SELECT COUNT(DISTINCT CIUDADM) FROM MARCAS;

-- Ejercicio 29:
--Obtener el nombre y los apellidos de todos los clientes que se han comprado un coche en un
--concesionario de ‘madrid’ y cuyo nombre comienza por j.
SELECT NOMBRE, APELLIDO FROM CLIENTES CL, VENTAS V, CONCESIONARIOS CN
    WHERE CL.DNI=V.DNI AND V.CIFC=CN.CIFC AND CN.CIUDADC='madrid' AND CL.NOMBRE LIKE 'j%';
    
-- Ejercicio 30:
--Obtener un listado completo de los clientes ordenado por nombre
SELECT * FROM CLIENTES ORDER BY NOMBRE;

-- Ejercicio 31:
--Obtener la lista de clientes que han comprado un coche en el mismo concesionario que el
--cliente con dni ‘2’ (excluyendo al propio cliente con dni ‘2’). 
SELECT DISTINCT NOMBRE, APELLIDO FROM CLIENTES CL, VENTAS V
    WHERE CL.DNI=V.DNI AND V.CIFC IN (SELECT CIFC FROM VENTAS WHERE DNI='2')
        AND CL.DNI<>'2';
--Hacer lo mismo con el dni ‘1’.
SELECT DISTINCT NOMBRE, APELLIDO FROM CLIENTES CL, VENTAS V
    WHERE CL.DNI=V.DNI AND V.CIFC IN (SELECT CIFC FROM VENTAS WHERE DNI='1')
        AND CL.DNI<>'1';
        
-- Ejercicio 32:
--Obtener un listado de los concesionarios cuyo total de unidades supera al promedio global de
--unidades de todos los concesionarios.
SELECT D.CIFC,CN.NOMBREC, CN.CIUDADC FROM CONCESIONARIOS CN, DISTRIBUCION D
    WHERE CN.CIFC=D.CIFC GROUP BY D.CIFC,CN.NOMBREC, CN.CIUDADC 
        HAVING SUM(D.CANTIDAD) > (SELECT SUM(CANTIDAD)/COUNT(DISTINCT CIFC) FROM DISTRIBUCION);

-- Ejercicio 33:
--Obtener el concesionario que tiene el mejor promedio de coches entre todos los
--concesionarios; es decir, el concesionario cuyo promedio de coches supera al promedio de
--coches de cada uno del resto de concesionarios.
SELECT CN.CIFC, CN.NOMBREC, CN.CIUDADC FROM CONCESIONARIOS CN, DISTRIBUCION D
    WHERE CN.CIFC=D.CIFC GROUP BY CN.CIFC, CN.NOMBREC, CN.CIUDADC
        HAVING AVG(D.CANTIDAD) >= ALL(SELECT AVG(CANTIDAD) FROM DISTRIBUCION GROUP BY CIFC);

-- Ejercicio 34:
--Obtener los dos clientes que han comprado más coches en total, ordenados por el número de
--coches comprados.
SELECT DNI, NOMBRE, APELLIDO FROM CLIENTES
    WHERE DNI IN (SELECT DNI FROM VENTAS GROUP BY DNI 
        ORDER BY COUNT(CODCOCHE) DESC FETCH FIRST 2 ROWS ONLY);

-- Ejercicio 35:
--Crear una vista a partir de la consulta 34. Utilizando dicha vista, obtener para cada uno de los
--dos clientes que han comprado más coches en total, el código de los coches que han
--comprado, el cif del concesionario donde lo compraron y el color.
CREATE VIEW CLIENTESMASCOCHES AS 
    SELECT DNI, NOMBRE, APELLIDO FROM CLIENTES
    WHERE DNI IN (SELECT DNI FROM VENTAS GROUP BY DNI 
        ORDER BY COUNT(CODCOCHE) DESC FETCH FIRST 2 ROWS ONLY);
    
SELECT V.DNI, NOMBRE, APELLIDO, CODCOCHE, CIFC, COLOR FROM VENTAS V, CLIENTESMASCOCHES CMC
    WHERE V.DNI=CMC.DNI;
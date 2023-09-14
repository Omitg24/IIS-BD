select apuntame_bd from dual;
select estoy_apuntado_bd from dual;

SELECT TITULO, VENTAS_PREVISTAS FROM TITULOS WHERE VENTAS_PREVISTAS >= 200 AND VENTAS_PREVISTAS <= 5000;

SELECT TITULO, VENTAS_PREVISTAS FROM TITULOS WHERE VENTAS_PREVISTAS BETWEEN 200 AND 5000;

SELECT AU_NOMBRE, AU_APELLIDO FROM AUTORES WHERE AU_TELEFONO IS NULL;

SELECT AU_NOMBRE, AU_APELLIDO, NVL(AU_TELEFONO, 'sin telefono') FROM AUTORES;

-- GUIÓN 3
--Ejercicio 8
-- Mostrar todos los autores cuyo teléfono comience con el prefijo ‘456’
SELECT * FROM AUTORES WHERE AU_TELEFONO LIKE '456%';

--Ejercicio 13
-- Mostrar para cada tipo de título el número de ejemplares que existen siempre que éste sea
-- superior a una unidad
SELECT TIPO, COUNT(*) FROM TITULOS GROUP BY TIPO HAVING COUNT(*) > 1 ;

--Ejercicio 25
-- Mostrar los tipos de libros que son comunes a más de una editorial. Formalizar la consulta de dos
-- formas diferentes.
SELECT DISTINCT T1.TIPO FROM TITULOS T1 JOIN TITULOS T2 ON T1.TIPO = T2.TIPO;

SELECT DISTINCT T1.TIPO FROM TITULOS T1, TITULOS T2 WHERE T1.TIPO=T2.TIPO;

SELECT DISTINCT TIPO FROM TITULOS T1 WHERE (
    SELECT COUNT(TIPO) FROM TITULOS T2 WHERE T2.TIPO=T1.TIPO
) > 1;

--Ejercicio 27
-- Mostrar los libros que tienen una pre-publicación mayor que la mayor pre-publicación que
-- tiene la editorial ‘Prentice Hall’
SELECT TITULO FROM TITULOS GROUP BY TITULO HAVING MAX(PRE_PUBLICACION) > (
    SELECT MAX(PRE_PUBLICACION) FROM TITULOS T, EDITORIALES E 
        WHERE T.ED_ID=E.ED_ID AND E.ED_NOMBRE='Prentice Hall'
);

--GUIÓN 4
--Ejercicio 1
-- Mostrar los nombres de los clientes con cuentas y préstamos en la sucursal Perryridge. Realizar
-- la consulta de varias formas diferentes (utilizando exists, utilizando in, utilizando el producto de tablas y
-- utilizando intersect).
SELECT NOMBRE_CLIENTE FROM CLIENTE WHERE EXISTS (
    SELECT * FROM CUENTA JOIN DEPOSITANTE ON 
        CUENTA.NUM_CUENTA=DEPOSITANTE.NUM_CUENTA
            WHERE DEPOSITANTE.NOMBRE_CLIENTE=CLIENTE.NOMBRE_CLIENTE AND
                NOMBRE_SUCURSAL='Perryridge'
) AND EXISTS (
    SELECT * FROM PRESTAMO JOIN PRESTATARIO ON
        PRESTAMO.NUM_PRESTAMO=PRESTATARIO.NUM_PRESTAMO
            WHERE PRESTATARIO.NOMBRE_CLIENTE=CLIENTE.NOMBRE_CLIENTE AND
                NOMBRE_SUCURSAL = 'Perryridge'
);

SELECT NOMBRE_CLIENTE FROM CLIENTE WHERE NOMBRE_CLIENTE IN (
    SELECT NOMBRE_CLIENTE FROM PRESTATARIO WHERE NUM_PRESTAMO IN (
        SELECT NUM_PRESTAMO FROM PRESTAMO WHERE NOMBRE_SUCURSAL='Perryridge'
        ) AND NOMBRE_CLIENTE IN (
            SELECT NOMBRE_CLIENTE FROM DEPOSITANTE WHERE NUM_CUENTA IN (
                SELECT NUM_CUENTA FROM CUENTA WHERE NOMBRE_SUCURSAL='Perryridge'
            )
        )
);
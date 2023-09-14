--EJERCICIO 1
SELECT * FROM MARCAS WHERE ciudadm = 'barcelona';
--EJERCICIO 2
SELECT * FROM CLIENTES WHERE ciudad = 'madrid' AND apellido = 'garcia';
SELECT * FROM CLIENTES WHERE ciudad = 'madrid' OR apellido = 'garcia';
--EJERCICIO 3
SELECT apellido, ciudad FROM CLIENTES;
--EJERCICIO 4
SELECT apellido FROM CLIENTES WHERE ciudad = 'madrid';
--EJERCICIO 5
SELECT nombrem FROM MARCAS WHERE cifm IN (
    SELECT cifm FROM MARCO WHERE codcoche IN (
        SELECT codcoche FROM COCHES WHERE modelo = 'gtd'
    )
);

--EJERCICIO 14
SELECT M1.nombrem, M2.nombrem FROM MARCAS M1, MARCAS M2 WHERE M1.ciudadm=M2.ciudadm AND M1.nombrem <> M2.nombrem;

--EJERCICIO 18
SELECT V.codcoche FROM VENTAS V, CONCESIONARIOS CO WHERE CO.ciudadc = 'madrid' AND CO.cifc=V.cifc;
--EJERCICIO 19


--EJERCICIO 25
SELECT cifc, SUM(cantidad) AS NUMERO_COCHES FROM DISTRIBUCION GROUP BY cifc;

--EJERCICIO 30
SELECT * FROM CLIENTES ORDER BY nombre;

--EJERCICIO 32
SELECT * FROM CONCENSIONARIOS WHERE cifc IN (
    SELECT cifc FROM DISTRIBUCION GROUP BY cifc HAVING SUM(cantidad) > (
        SELECT AVG(total) FROM (
            SELECT SUM(cantidad) as total FROM DISTRIBUCION GROUP BY cifc
        )
    )
);

--EJERCICIO 34
SELECT * FROM CLIENTES WHERE dni IN (
    SELECT dni FROM (
        SELECT COUNT(codcoche), dni FROM ventas
        GROUP BY dni ORDER BY COUNT(codcoche) DESC
    ) WHERE ROWNUM <= 2
);

--EJERCICIO 35
CREATE VIEW clientesmascoches7 AS SELECT * FROM CLIENTES WHERE dni IN (
    SELECT dni FROM (
        SELECT COUNT(codcoche), dni FROM ventas
        GROUP BY dni ORDER BY COUNT(codcoche) DESC
    ) WHERE ROWNUM <= 2
);
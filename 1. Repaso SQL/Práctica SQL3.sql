-- PRÁCTICA SQL3
-- Ejercicio 1:
--Generar una relación con las columnas nombre y apellidos que contengan el nombre y
--apellidos de la relación AUTORES.
SELECT AU_NOMBRE, AU_APELLIDO FROM AUTORES;

-- Ejercicio 2:
--Generar una relación con una columna que contenga los títulos y otra que contenga los
--ingresos previstos para cada título. Dichos ingresos serán calculados mediante el producto de
--las ventas previstas por el precio asignado a cada título.
SELECT TITULO, (VENTAS_PREVISTAS*PRECIO) AS INGRESOS_PREVISTOS FROM TITULOS;

-- Ejercicio 3:
--Mostrar los títulos cuyas ventas previstas estén entre 200 y 5000 unidades.
SELECT TITULO FROM TITULOS WHERE VENTAS_PREVISTAS BETWEEN 200 AND 5000;

-- Ejercicio 4:
--Mostrar los nombres, apellidos y teléfonos de todos los autores
SELECT AU_NOMBRE, AU_APELLIDO, AU_TELEFONO FROM AUTORES;

-- Ejercicio 5:
--Mostrar los nombres y apellidos de los autores que no tienen teléfono (es decir, es nulo).
SELECT AU_NOMBRE, AU_APELLIDO FROM AUTORES WHERE AU_TELEFONO IS NULL;

-- Ejercicio 6:
--Mostrar los nombres, apellidos y teléfonos de todos los autores, indicando “sin teléfono” para
--aquellos que no tienen teléfono. Formular la consulta utilizando la función NVL.
SELECT AU_NOMBRE, AU_APELLIDO, NVL(AU_TELEFONO, 'sin teléfono') FROM AUTORES;

-- Ejercicio 7:
--Mostrar el identificador de los títulos, el propio título y las ventas previstas para cada uno de
--los títulos cuyo tipo es bases de datos (BD) o programación (PROG). Ordenar los datos
--descendentemente por precio. 
SELECT TITULO_ID, TITULO, VENTAS_PREVISTAS FROM TITULOS
    WHERE TIPO='BD' OR TIPO='PROG' ORDER BY PRECIO DESC;    
--Formular la consulta de dos formas diferentes.
SELECT TITULO_ID, TITULO, VENTAS_PREVISTAS FROM TITULOS
    WHERE TIPO IN ('BD', 'PROG') ORDER BY PRECIO DESC;

-- Ejercicio 8:
--Mostrar todos los autores cuyo teléfono comience con el prefijo ‘456’.
SELECT * FROM AUTORES WHERE AU_TELEFONO LIKE '456%';

-- Ejercicio 9:
--Mostrar el precio medio de los títulos almacenados en la tabla TITULOS. Mostrar el precio
--medio para los títulos cuyo tipo es bases de datos. 
SELECT AVG(PRECIO) AS PRECIO_MEDIO FROM TITULOS;
SELECT AVG(PRECIO) AS PRECIO_MEDIO FROM TITULOS WHERE TIPO='BD';
--Formalizar la consulta de dos formas diferentes.
SELECT SUM(PRECIO)/COUNT(PRECIO) AS PRECIO_MEDIO FROM TITULOS;
SELECT SUM(PRECIO)/COUNT(PRECIO) AS PRECIO_MEDIO FROM TITULOS WHERE TIPO='BD';

-- Ejercicio 10:
--Mostrar el número de títulos que tiene cada editorial. Indicar también el número de títulos que
--pertenecen a cada tipo para cada editorial
SELECT ED_ID, COUNT(TITULO_ID) FROM TITULOS GROUP BY ED_ID;
--Indicar también el número de títulos quE pertenecen a cada tipo para cada editorial
SELECT ED_ID, TIPO, COUNT(TITULO_ID) FROM TITULOS GROUP BY ED_ID, TIPO;

-- Ejercicio 11:
--Mostrar para cada tipo de título el número de ejemplares existentes. Ignorar los valores nulos
SELECT TIPO, COUNT(*) AS N_EJEMPLARES FROM TITULOS GROUP BY TIPO;

-- Ejercicio 12:
--Mostrar el precio medio para cada tipo de título cuya fecha de publicación sea posterior al año
--2000.
SELECT TIPO, AVG(PRECIO) AS PRECIO_MEDIO FROM TITULOS 
    WHERE F_PUBLICACION>TO_DATE('01/01/2000','DD/MM/YYYY') GROUP BY TIPO;
    
-- Ejercicio 13:
--Mostrar para cada tipo de título el número de ejemplares que existen siempre que éste sea
--superior a una unidad
SELECT TIPO, COUNT(*) AS N_EJEMPLARES FROM TITULOS GROUP BY TIPO HAVING COUNT(*)>1;

-- Ejercicio 14:
--Mostrar para cada tipo de título el precio medio siempre que éste sea superior a 35
SELECT TIPO,  AVG(PRECIO) AS N_EJEMPLARES FROM TITULOS GROUP BY TIPO HAVING AVG(PRECIO)>35;

-- Ejercicio 15:
--Mostrar para cada editorial el precio medio de sus títulos siempre que el identificador de la
--editorial sea superior a ‘2’ y el precio medio sea superior a 60. El resultado debe aparecer
--ordenado de forma ascendente por el identificador de la editorial
SELECT ED_ID, AVG(PRECIO) FROM TITULOS WHERE ED_ID>2 GROUP BY ED_ID HAVING AVG(PRECIO)>60 ORDER BY ED_ID;

-- Ejercicio 16:
--Mostrar el nombre, apellidos y orden de los editores para el título cuyo identificador es ‘1’.
SELECT E.EDITOR_ID, EDITOR_NOMBRE, EDITOR_APELLIDO, ORDEN_EDITORES 
    FROM EDITORES E, TITULOSEDITORES TE WHERE E.EDITOR_ID=TE.EDITOR_ID AND TE.TITULO_ID='1';
    
-- Ejercicio 17:
--Mostrar los nombres de los editores y de las editoriales de la misma ciudad
SELECT EDITOR_NOMBRE, ED_NOMBRE, ED_CIUDAD FROM EDITORES 
    INNER JOIN EDITORIALES ON EDITOR_CIUDAD=ED_CIUDAD;
--Otra forma de hacerlo:
SELECT EDITOR_NOMBRE, ED_NOMBRE, ED_CIUDAD FROM EDITORES, EDITORIALES
    WHERE EDITOR_CIUDAD=ED_CIUDAD;
    
-- Ejercicio 18:
--Mostrar los títulos de todos los libros del tipo bases de datos (BD) y los nombres de sus
--autores, así como el orden en el que figuran.
SELECT T.TITULO, A.AU_NOMBRE, TA.ORDEN_AUTORES FROM TITULOS T, TITULOSAUTORES TA, AUTORES A
    WHERE T.TITULO_ID=TA.TITULO_ID AND TA.AU_ID=A.AU_ID AND T.TIPO='BD';
    
-- Ejercicio 19:
--Mostrar el nombre y apellidos de los editores, así como el nombre de su editor jefe.
SELECT E1.EDITOR_NOMBRE, E1.EDITOR_APELLIDO, E2.EDITOR_NOMBRE AS JEFE 
    FROM EDITORES E1, EDITORES E2 WHERE E1.EDITOR_JEFE=E2.EDITOR_ID; 

-- Ejercicio 20:
--Mostrar los datos de los autores (au_id, au_nombre y au_apellido) en los que coinciden su
--apellido.
SELECT A1.AU_ID, A1.AU_NOMBRE, A1.AU_APELLIDO FROM AUTORES A1, AUTORES A2
    WHERE A1.AU_APELLIDO=A2.AU_APELLIDO AND A1.AU_NOMBRE<>A2.AU_NOMBRE;
    
-- Ejercicio 21:
--Mostrar los nombres de las editoriales que publican títulos de programación. 
SELECT DISTINCT ED_NOMBRE FROM EDITORIALES E, TITULOS T 
    WHERE E.ED_ID=T.ED_ID AND TIPO='PROG';
--Formalizar la consulta de dos formas diferentes.
SELECT DISTINCT ED_NOMBRE FROM EDITORIALES E 
    INNER JOIN TITULOS T ON E.ED_ID=T.ED_ID 
        WHERE T.TIPO='PROG';
        
-- Ejercicio 22:
--Mostrar el título y el precio de los libros cuyo precio coincida con el del libro más barato.
SELECT TITULO, PRECIO FROM TITULOS WHERE PRECIO = (SELECT MIN(PRECIO) FROM TITULOS);
--Hacer lo mismo con el más caro.
SELECT TITULO, PRECIO FROM TITULOS WHERE PRECIO = (SELECT MAX(PRECIO) FROM TITULOS);

-- Ejercicio 23:
--Mostrar los nombres y la ciudad de los autores que viven en la misma ciudad que ‘Abraham
--Silberschatz.
SELECT AU_NOMBRE, AU_APELLIDO, AU_CIUDAD FROM AUTORES
    WHERE AU_CIUDAD = (SELECT AU_CIUDAD FROM AUTORES 
        WHERE AU_NOMBRE='Abraham' AND AU_APELLIDO = 'Silberschatz');

-- Ejercicio 24:
--Mostrar el nombre y apellido de los autores que son autores individuales y coautores
SELECT AU_NOMBRE, AU_APELLIDO FROM AUTORES A, TITULOSAUTORES TA
    WHERE A.AU_ID=TA.AU_ID AND TA.PORCENTAJE_PARTICIPACION=1 
        AND A.AU_ID IN (SELECT DISTINCT AU_ID FROM TITULOSAUTORES
            WHERE PORCENTAJE_PARTICIPACION<1);

-- Ejercicio 25:
--Mostrar los tipos de libros que son comunes a más de una editorial. 
SELECT DISTINCT T1.TIPO FROM TITULOS T1 
    WHERE T1.TIPO IN (SELECT TIPO FROM TITULOS T2 WHERE T1.ED_ID<>T2.ED_ID);
--Formalizar la consulta de dos formas diferentes.
SELECT DISTINCT T1.TIPO FROM TITULOS T1, TITULOS T2
    WHERE T1.TIPO=T2.TIPO AND T1.ED_ID<>T2.ED_ID;

-- Ejercicio 26:
--Mostrar los tipos de libros cuyo precio máximo es al menos dos veces el precio medio para ese
--tipo.
SELECT TIPO FROM TITULOS GROUP BY TIPO HAVING MAX(PRECIO)>=2*AVG(PRECIO);

-- Ejercicio 27:
--Mostrar los libros que tienen una pre-publicación mayor que la mayor pre-publicación que
--tiene la editorial ‘Prentice Hall’.
SELECT TITULO FROM TITULOS WHERE PRE_PUBLICACION > (SELECT MAX(PRE_PUBLICACION) 
    FROM TITULOS T, EDITORIALES E WHERE T.ED_ID=E.ED_ID AND E.ED_NOMBRE='Prentice Hall');
    
-- Ejercicio 28:
--Mostrar los títulos de los libros publicados por una editorial localizada en una ciudad que
--comienza por la letra ‘B’.
SELECT TITULO FROM TITULOS T, EDITORIALES E
    WHERE T.ED_ID=E.ED_ID AND E.ED_CIUDAD LIKE 'B%';
    
-- Ejercicio 29:
--Mostrar los nombres de las editoriales que no publican libros cuyo tipo sea bases de datos.
SELECT DISTINCT ED_NOMBRE FROM EDITORIALES 
    WHERE ED_ID NOT IN (SELECT ED_ID FROM TITULOS WHERE TIPO='BD');
--Formalizar la consulta de dos formas diferentes.
SELECT E.ED_NOMBRE FROM EDITORIALES E
    WHERE NOT EXISTS (SELECT * FROM TITULOS T WHERE T.ED_ID = E.ED_ID AND T.TIPO ='BD');

-- PRÁCTICA SQL6:
-- Ejercicio 1:
--Muestra las ofertas realizadas por agencias que trabajan con mayoristas cuyo tipo de viajes que
--ofertan son ‘hoteles’. Mostrar también el precio de la oferta.
SELECT O.CODOFERTA, O.ORIGEN, O.DESTINO, ER.PRECIO
    FROM OFERTA O, ESREALIZADA ER, AGENCIA A, MAYORISTA M
    WHERE O.CODOFERTA=ER.CODOFERTA AND ER.CODAGENCIA=A.CODAGENCIA 
        AND A.CODMAYORISTA=M.CODMAYORISTA AND M.TIPO='hoteles';
        
-- Ejercicio 2:
--Mostrar el número total de ventas realizadas por las agencias para cada tipo de mayorista
--siempre que el número sea superior a 1.
SELECT M.TIPO, SUM(A.VENTASREALIZADAS) AS TOTAL_VENTAS FROM AGENCIA A, MAYORISTA M 
    WHERE A.CODMAYORISTA=M.CODMAYORISTA GROUP BY M.TIPO HAVING SUM(A.VENTASREALIZADAS)>1;
    
-- Ejercicio 3:
--Indicar el mayor porcentaje de descuento aplicado a las compras de ofertas con origen Madrid.
SELECT MAX(D.PORCENTAJE) AS MAX_PORCENTAJE FROM OFERTA O, COMPRA C, TIENE T, DESCUENTOS D
    WHERE O.ORIGEN='Madrid' AND O.CODOFERTA=C.CODOFERTA AND C.DNI=T.DNI AND T.CODDESCUENTO=D.CODDESCUENTO;
        
-- Ejercicio 4:
--Mostrar los clientes que no han hecho ninguna compra con pago fraccionado para agencias
--cuyo mayorista es de tipo ‘combinados’.
SELECT NOMBRE FROM CLIENTE
    WHERE DNI NOT IN (SELECT DNI FROM COMPRA CO, AGENCIA A, MAYORISTA M
        WHERE CO.PAGOFRACCIONADO='S' AND CO.CODAGENCIA=A.CODAGENCIA AND A.CODMAYORISTA=M.CODMAYORISTA AND M.TIPO='combinados');
        
-- Ejercicio 5:
--Mostar para las compras realizadas el nombre del mayorista con el que trabaja la agencia que
--realiza la oferta que es comprada. Mostrar además del nombre del mayorista, el nombre de la
--agencia, el destino de la oferta comprada, el importe definitivo abonado, el nombre del cliente
--que ha hecho la compra y el porcentaje de descuento aplicado.
SELECT NOMBREMAYORISTA, NOMBREAGENCIA, DESTINO, IMPORTEDEFINITIVO, NOMBRE, PORCENTAJE 
    FROM COMPRA CO, AGENCIA A, MAYORISTA M, OFERTA O, CLIENTE CL, TIENE T, DESCUENTOS D
        WHERE CO.CODAGENCIA=A.CODAGENCIA AND A.CODMAYORISTA=M.CODMAYORISTA AND CO.CODOFERTA=O.CODOFERTA
            AND CO.DNI=CL.DNI AND CL.DNI=T.DNI AND T.CODDESCUENTO=D.CODDESCUENTO;
            
-- Ejercicio 6:
--Mostrar el nombre de la agencia que realiza la oferta más barata y con plazas todavía
--disponibles.
SELECT O.CODOFERTA, A.CODAGENCIA, NOMBREAGENCIA, PRECIO, PLAZASDISPONIBLES FROM AGENCIA A, ESREALIZADA ER, OFERTA O
    WHERE A.CODAGENCIA=ER.CODAGENCIA AND ER.CODOFERTA=O.CODOFERTA AND ER.PLAZASDISPONIBLES > 0 AND ER.PRECIO IN 
        (SELECT MIN(PRECIO) FROM ESREALIZADA);
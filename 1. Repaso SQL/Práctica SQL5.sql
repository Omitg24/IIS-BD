-- PR�CTICA SQL5:
-- Ejercicio 1:
--Muestra el apellido, puesto de trabajo, salario y % de comisi�n de aquellos empleados que
--ganan comisiones. Ordena los datos por el puesto de trabajo en orden ascendente y por el
--salario de forma descendente.
SELECT LAST_NAME, JOB_ID, SALARY, COMMISSION_PCT FROM EMPLOYEES
    WHERE COMMISSION_PCT>0 ORDER BY JOB_ID, SALARY DESC;
    
-- Ejercicio 2:
--Muestra aquellos empleados que tienen un apellido que empieza por J, K, L o M.
SELECT EMPLOYEE_ID, FIRST_NAME, LAST_NAME FROM EMPLOYEES
    WHERE SUBSTR(LAST_NAME,1,1) IN ('J', 'K', 'L', 'M');
    
-- Ejercicio 3:
--Muestra para todos los empleados el apellido y n�mero de empleado, junto al apellido y
--n�mero de empleado de su manager.
SELECT W.LAST_NAME AS EMP_LAST_NAME, W.EMPLOYEE_ID AS EMP_ID,
    M.LAST_NAME AS MNG_LAST_NAME, M.EMPLOYEE_ID AS MNG_ID FROM EMPLOYEES W, EMPLOYEES M 
        WHERE W.MANAGER_ID=M.EMPLOYEE_ID;
        
-- Ejercicio 4;
--Muestra el apellido y fecha de contrataci�n de todos los empleados contratados despu�s del
--empleado apellidado �Davies�.
SELECT E.LAST_NAME, E.HIRE_DATE FROM EMPLOYEES E, EMPLOYEES D
    WHERE E.HIRE_DATE>D.HIRE_DATE AND D.LAST_NAME='Davies';

-- Ejercicio 5:
--Muestra los nombres y fechas de contrataci�n de todos los empleados que fueron contratados
--antes que sus managers. Muestra tambi�n el apellido de su manager y su fecha de contrataci�n.
SELECT W.FIRST_NAME AS EMP_NAME, W.HIRE_DATE AS EMP_DATE, 
    M.LAST_NAME AS MNG_LAST_NAME, M.HIRE_DATE AS MNG_DATE FROM EMPLOYEES W, EMPLOYEES M
        WHERE W.MANAGER_ID=M.EMPLOYEE_ID AND W.HIRE_DATE < M.HIRE_DATE;
        
-- Ejercicio 6:
--Muestra el n�mero de departamento y su salario m�nimo para aquel departamento con mayor
--salario medio.
SELECT DEPARTMENT_ID, MIN(SALARY) AS SALARY FROM EMPLOYEES GROUP BY DEPARTMENT_ID
    HAVING AVG(SALARY) >= ALL(SELECT AVG(SALARY) FROM EMPLOYEES GROUP BY DEPARTMENT_ID);

-- Ejercicio 7:
--Muestra el n�mero de departamento, nombre y localizaci�n para aquellos departamentos
--donde no trabajen empleados cuyo �job_id� sea �SA_REP�.
SELECT DEPARTMENT_ID, DEPARTMENT_NAME, LOCATION_ID FROM DEPARTMENTS
    WHERE DEPARTMENT_ID NOT IN (SELECT DEPARTMENT_ID FROM EMPLOYEES WHERE JOB_ID='SA_REP');

-- Ejercicio 8:
--Muestra el n�mero de departamento, su nombre y n�mero de empleados trabajando en �l que
--cumplan:
--a) que tengan menos de tres empleados:
SELECT D.DEPARTMENT_ID, D.DEPARTMENT_NAME, COUNT(*) AS NUM_EMP FROM DEPARTMENTS D, EMPLOYEES E
    WHERE D.DEPARTMENT_ID=E.DEPARTMENT_ID GROUP BY D.DEPARTMENT_ID, D.DEPARTMENT_NAME HAVING COUNT(*)<3;
--b) que el departamento tenga el m�ximo n�mero de empleados:
SELECT D.DEPARTMENT_ID, D.DEPARTMENT_NAME, COUNT(*) AS NUM_EMP FROM DEPARTMENTS D, EMPLOYEES E
    WHERE D.DEPARTMENT_ID=E.DEPARTMENT_ID GROUP BY D.DEPARTMENT_ID, D.DEPARTMENT_NAME HAVING COUNT(*) = 
        (SELECT MAX(COUNT(*)) FROM EMPLOYEES GROUP BY DEPARTMENT_ID);
--c) que el departamento tenga el m�nimo n�mero de empleados:
SELECT D.DEPARTMENT_ID, D.DEPARTMENT_NAME, COUNT(*) AS NUM_EMP FROM DEPARTMENTS D, EMPLOYEES E
    WHERE D.DEPARTMENT_ID=E.DEPARTMENT_ID GROUP BY D.DEPARTMENT_ID, D.DEPARTMENT_NAME HAVING COUNT(*) = 
        (SELECT MIN(COUNT(*)) FROM EMPLOYEES GROUP BY DEPARTMENT_ID);
-- Ejercicio 9:
--Muestra el puesto de trabajo (job_id) que se contrat� (hire_date) en la primera mitad de 1990 y
--tambi�n en la primera mitad de 1991
SELECT JOB_ID FROM EMPLOYEES 
    WHERE HIRE_DATE BETWEEN TO_DATE('01/01/1990') AND TO_DATE('01/07/1990')
    INTERSECT (SELECT JOB_ID FROM EMPLOYEES 
    WHERE HIRE_DATE BETWEEN TO_DATE('01/01/1991') AND TO_DATE('01/07/1991'));

-- Ejercicio 10:
--Muestra los tres empleados que mas ganan de la tabla empleados/employees
SELECT FIRST_NAME, LAST_NAME, SALARY FROM EMPLOYEES ORDER BY SALARY DESC FETCH FIRST 3 ROWS ONLY;

-- Ejercicio 11:
--Mostrar el n�mero de empleado y su apellido para aquellos empleados que trabajan en el
--estado de California.
SELECT E.EMPLOYEE_ID, E.LAST_NAME FROM EMPLOYEES E, DEPARTMENTS D, LOCATIONS L
    WHERE E.DEPARTMENT_ID=D.DEPARTMENT_ID AND D.LOCATION_ID=L.LOCATION_ID AND L.STATE_PROVINCE='California';

-- Ejercicio 12:
--Incrementar un 15% el salario de los empleados que est�n desempe�ando un puesto cuyo
--salario m�nimo sea igual a 4200 euros.
SELECT E.EMPLOYEE_ID, E.FIRST_NAME, (15*E.SALARY/100)+E.SALARY AS NEW_SALARY 
    FROM EMPLOYEES E, JOBS J WHERE E.JOB_ID=J.JOB_ID AND J.MIN_SALARY=4200;
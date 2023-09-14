package bbdd.jdbc1;
import java.sql.*;
import java.util.Scanner;

import Aux_Package.AuxClass;

/**
 * Titulo: Clase Program
 *
 * @author Omar Teixeira González, UO281847
 * @version 21 abr 2022
 */
public class Program {	
		
	/**
	 * Método Main
	 * @param args
	 * @throws SQLException
	 */
	public static void main(String[] args) throws SQLException {
		System.out.println("Exercise 1_1:");
		exercise1_1();
		System.out.println("Exercise 1_2:");
		exercise1_2();
		System.out.println("Exercise 2:");
		exercise2();
		System.out.println("Exercise 3:");
		exercise3();
		System.out.println("Exercise 4:");
		exercise4();
		System.out.println("Exercise 5_1:");
		exercise5_1();
		System.out.println("Exercise 5_2:");
		exercise5_2();
		System.out.println("Exercise 5_3:");
		exercise5_3();
		System.out.println("Exercise 6_1:");
		exercise6_1();
		System.out.println("Exercise 6_2:");
		exercise6_2();
		System.out.println("Exercise 7_1:");
		exercise7_1();
		System.out.println("Exercise 7_2:");
		exercise7_2();
		System.out.println("Exercise 8:");
		exercise8();
	}

	/*
		1.	Crear un metodo en Java que muestre por pantalla los resultados de las consultas 21 y 32 de la Practica SQL2. 
		1.1. (21) Obtener el nombre y el apellido de los clientes que han adquirido un coche en un concesionario de Madrid, el cual dispone de coches del modelo gti.
	 */
	public static void exercise1_1() throws SQLException {
		String query = "SELECT DISTINCT CL.NOMBRE, CL.APELLIDO FROM CLIENTES CL, VENTAS V, COCHES CC, CONCESIONARIOS CN "
				+ "WHERE CL.DNI=V.DNI AND V.CIFC=CN.CIFC AND V.CODCOCHE=CC.CODCOCHE AND CN.CIUDADC='madrid' AND CC.MODELO='gti'";
		ResultSet rs = AuxClass.solveQuery(query);	
		
		while(rs.next()) {
			final String name = rs.getString("NOMBRE");
			final String surname = rs.getString("APELLIDO"); 
			System.out.println(String.format(
					"\tNombre: %s, Apellido: %s",
					name,
					surname
			));
		}
		
		rs.close();
		AuxClass.getStatement().close();
		AuxClass.getConnection().close();
	}
	
	/* 
		1.2. (32) Obtener un listado de los concesionarios cuyo promedio de coches supera a la cantidad promedio de todos los concesionarios. 
	*/
	public static void exercise1_2() throws SQLException {		
		String query = "SELECT D.CIFC, CN.NOMBREC, CN.CIUDADC FROM CONCESIONARIOS CN, DISTRIBUCION D\r\n"
				+ "    WHERE CN.CIFC=D.CIFC GROUP BY D.CIFC,CN.NOMBREC, CN.CIUDADC \r\n"
				+ "        HAVING SUM(D.CANTIDAD) > (SELECT SUM(CANTIDAD)/COUNT(DISTINCT CIFC) FROM DISTRIBUCION)";
		ResultSet rs = AuxClass.solveQuery(query);	
		
		while(rs.next()) {
			final String cifc = rs.getString("CIFC");
			final String nombrec = rs.getString("NOMBREC"); 
			final String ciudad = rs.getString("CIUDADC");
			System.out.println(String.format(
					"\tCifc: %s, Nombrec: %s, Ciudadc: %s",
					cifc,
					nombrec,
					ciudad
			));
		}
		
		rs.close();
		AuxClass.getStatement().close();
		AuxClass.getConnection().close();
	}
	
	/*
		2. Crear un metodo en Java que muestre por pantalla el resultado de la consulta 6 de la Practica SQL2 de forma el color de la busqueda sea introducido por el usuario.
			(6) Obtener el nombre de las marcas de las que se han vendido coches de un color introducido por el usuario.
	*/
	public static void exercise2() throws SQLException {
		String query = "SELECT NOMBREM FROM MARCAS M, MARCO MC, VENTAS V \r\n"
				+ "	    WHERE M.CIFM=MC.CIFM AND MC.CODCOCHE=V.CODCOCHE AND V.COLOR=?";		
		System.out.print("Color: ");
		final String color = ReadString();
		ResultSet rs = AuxClass.solveQuery(query, color);	
		
		while(rs.next()) {
			final String nombrem = rs.getString("NOMBREM"); 
			System.out.println(String.format(
					"\tNombrem: %s",
					nombrem
			));
		}
		
		rs.close();	
		AuxClass.getPreparedStatement().close();
		AuxClass.getConnection().close();
	}
	
	/*
		3.	Crear un metodo en Java para ejecutar la consulta 27 de la Practica SQL2 de forma que los limites la cantidad de coches sean introducidos por el usuario. 
			(27) Obtener el cifc de los concesionarios que disponen de una cantidad de coches comprendida entre dos cantidades introducidas por el usuario, ambas inclusive.

	*/
	public static void exercise3() throws SQLException {
		String query = "SELECT CIFC, SUM(CANTIDAD) AS TOTAL FROM DISTRIBUCION GROUP BY CIFC HAVING SUM(CANTIDAD) BETWEEN ? AND ?";
		System.out.print("Límite inferior: ");
		final int lowerLimit = ReadInt();
		System.out.print("Límite superior: ");
		final int upperLimit = ReadInt();
		ResultSet rs = AuxClass.solveQuery(query, lowerLimit, upperLimit);
		
		while(rs.next()) {
			final String cifc = rs.getString("CIFC");
			final String cantidad = rs.getString("TOTAL");
			System.out.println(String.format(
					"\tCifc: %s, Total: %s",
					cifc,
					cantidad					
			));
		}
		
		rs.close();
		AuxClass.getPreparedStatement().close();
		AuxClass.getConnection().close();
	}
	
	/*
		4.	Crear un metodo en Java para ejecutar la consulta 24 de la Practica SQL2 de forma que tanto la ciudad del concesionario como el color sean introducidos por el usuario. 
			(24) Obtener los nombres de los clientes que no han comprado coches de un color introducido por el usuario en concesionarios de una ciudad introducida por el usuario.

	*/
	public static void exercise4() throws SQLException {
		String query = "SELECT DISTINCT CL.NOMBRE FROM CLIENTES CL, VENTAS V\r\n"
				+ "    WHERE CL.DNI=V.DNI AND CL.DNI NOT IN (SELECT V.DNI FROM CONCESIONARIOS CN, VENTAS V\r\n"
				+ "        WHERE CN.CIFC=V.CIFC AND CN.CIUDADC=? AND V.COLOR=?)";
		System.out.print("Ciudad: ");
		final String ciudadc = ReadString();
		System.out.print("Color: ");
		final String color = ReadString();
		ResultSet rs = AuxClass.solveQuery(query, ciudadc, color);
		
		while (rs.next()) {
			final String nombre = rs.getString("NOMBRE");
			System.out.println(String.format(
					"\tNombre: %s",
					nombre
			));
		}
		
		rs.close();
		AuxClass.getPreparedStatement().close();
		AuxClass.getConnection().close();		
	}
	
	/*
		5.	Crear un metodo en Java que haciendo uso de la instruccion SQL adecuada: 
		5.1. Introduzca datos en la tabla coches cuyos datos son introducidos por el usuario.

	*/
	public static void exercise5_1() throws SQLException {		
		String insert = "INSERT INTO COCHES VALUES (?, ?, ?)";
		
		System.out.print("Código del coche: ");
		int codcoche = ReadInt();
		System.out.print("Nombre del coche: ");
		String nombrech = ReadString();
		System.out.print("Modelo del coche: ");
		String modelo = ReadString();
		
		PreparedStatement pst = AuxClass.changeTable(insert, codcoche, nombrech, modelo);
			
		if (pst.executeUpdate()==1) {
			System.out.println("Datos insertados");
		} else {
			System.out.println("Datos no insertados");
		}
		
		pst.close();
		AuxClass.getConnection().close();
	}
	
	/*
		5.2. Borre un determinado coche cuyo codigo es introducido por el usuario. 
	*/
	public static void exercise5_2() throws SQLException {		
		String delete = "DELETE FROM COCHES WHERE CODCOCHE=?";	
		
		System.out.print("Código del coche: ");
		int codcoche = ReadInt();
		
		PreparedStatement pst = AuxClass.changeTable(delete, codcoche);
				
		if (pst.executeUpdate()==1) {
			System.out.println("Datos eliminados");
		} else {
			System.out.println("Datos no eliminados");
		}
		
		pst.close();
		AuxClass.getConnection().close();
	}
	
	/*	 
		5.3. Actualice el nombre y el modelo para un determinado coche cuyo codigo es introducido por el usuario.
	*/
	public static void exercise5_3() throws SQLException {				
		String update = "UPDATE COCHES SET NOMBRECH=?, MODELO=? WHERE CODCOCHE=?";
		
		System.out.print("Nombre del coche: ");
		String nombrech = ReadString();
		System.out.print("Modelo del coche: ");
		String modelo = ReadString();
		System.out.print("Código del coche: ");
		int codcoche = ReadInt();		
		
		PreparedStatement pst = AuxClass.changeTable(update, nombrech, modelo, codcoche);
		
		if (pst.executeUpdate()==1) {
			System.out.println("Datos actualizados");
		} else {
			System.out.println("Datos no actualizados");
		}
		
		pst.close();
		AuxClass.getConnection().close();
	}
	
	/*
		6. Invocar la funcion y el procedimiento del ejercicio 10 de la practica PL1 desde una aplicacion Java. 
			(10) Realizar un procedimiento y una funcion que dado un codigo de concesionario devuelve el numero ventas que se han realizado en el mismo.
		6.1. Funcion
	*/
	public static void exercise6_1() throws SQLException {				
		String call = "{? = call FUNCTION10(?)}";
		
		System.out.print("Código del concesionario: ");
		int cifc = ReadInt();
		
		CallableStatement cs = AuxClass.callFunctionOrProcedure(call, cifc, AuxClass.INT_TYPE);
		
		cs.execute();
		int nv = cs.getInt(1);
		
		System.out.println("\tNúmero de ventas: " + nv);
		
		cs.close();
		AuxClass.getConnection().close();
	}
	
	/*	
		6.2. Procedimiento
	*/
	public static void exercise6_2() throws SQLException {				
		String call = "{call PROCEDURE10(?, ?)}";
		
		System.out.print("Código del concesionario: ");
		Object cifc = ReadInt();
		
		CallableStatement cs = AuxClass.callFunctionOrProcedure(call, cifc, AuxClass.INT_TYPE);
				
		cs.execute();
		int nv = cs.getInt(2);
		
		System.out.println("\tNúmero de ventas: " + nv);
		
		cs.close();
		AuxClass.getConnection().close();
	}
	
	/*
		7. Invocar la funcion y el procedimiento del ejercicio 11 de la Practica PL1 desde una aplicacion Java. 
			(11) Realizar un procedimiento y una funcion que dada una ciudad que se le pasa como parametro devuelve el numero de clientes de dicha ciudad.
		7.1. Funcion

	*/
	public static void exercise7_1() throws SQLException {		
		String call = "{? = call FUNCTION11(?)}";
		
		System.out.print("Ciudad: ");
		String ciudad = ReadString();
		
		CallableStatement cs = AuxClass.callFunctionOrProcedure(call, ciudad, AuxClass.INT_TYPE);
		
		cs.execute();
		int nc = cs.getInt(1);
		
		System.out.println("\tNúmero de clientes: " + nc);
		
		cs.close();
		AuxClass.getConnection().close();
	}	
	
	/*
		7.2. Procedimiento
	*/
	public static void exercise7_2() throws SQLException {		
		String call = "{call PROCEDURE11(?, ?)}";
		
		System.out.print("Ciudad: ");
		String ciudad = ReadString();
		
		CallableStatement cs = AuxClass.callFunctionOrProcedure(call, ciudad, AuxClass.INT_TYPE);
		
		cs.execute();
		int nc = cs.getInt(2);
		
		System.out.println("\tNúmero de clientes: " + nc);
		
		cs.close();
		AuxClass.getConnection().close();
	}
	
    /*
     	8. Crear un metodo en Java que imprima por pantalla los coches que han sido adquiridos por cada cliente.
     	Ademas, debera imprimirse para cada cliente el numero de coches que ha comprado y el numero de
     	concesionarios en los que ha comprado. Aquellos clientes que no han adquirido ningun coche no
		deben aparecer en el listado.
    */
	public static void exercise8() throws SQLException {		
		String queryClientes = "SELECT DISTINCT C.DNI, NOMBRE, APELLIDO FROM CLIENTES C, VENTAS V WHERE C.DNI=V.DNI";
		String queryCount = "SELECT COUNT(*) AS NCH, COUNT(DISTINCT CIFC) AS NCO FROM VENTAS WHERE DNI=?";
		String queryCoches = "SELECT CH.CODCOCHE AS CODCH, CH.NOMBRECH AS NOMCH, CH.MODELO AS MOD, V.COLOR AS COL FROM COCHES CH, VENTAS V WHERE CH.CODCOCHE=V.CODCOCHE AND V.DNI=?";
		ResultSet rsClientes = AuxClass.solveQuery(queryClientes);
		while (rsClientes.next()) {
			final String dni = rsClientes.getString("DNI");
			final String nombre = rsClientes.getString("NOMBRE");
			final String apellido = rsClientes.getString("APELLIDO");
			ResultSet rsCount = AuxClass.solveQuery(queryCount, dni);
			rsCount.next();
			final String nch = rsCount.getString("NCH");
			final String nco = rsCount.getString("NCO");
			System.out.println(String.format(
					"\t-Cliente: %s %s %s %s", 
					nombre,
					apellido,
					nco,
					nch));
			ResultSet rsCoches = AuxClass.solveQuery(queryCoches, dni);
			while (rsCoches.next()) {
				final String codcoche = rsCoches.getString("CODCH");
				final String nombrech = rsCoches.getString("NOMCH");
				final String modelo = rsCoches.getString("MOD");
				final String color = rsCoches.getString("COL");
				System.out.println(String.format(
						"\t\t--->Coche: %s %s %s %s", 
						codcoche,
						nombrech,
						modelo,
						color));
			}
			rsCoches.close();			
			rsCount.close();
		}
		rsClientes.close();
		AuxClass.getStatement().close();
		AuxClass.getPreparedStatement().close();
		AuxClass.getConnection().close();		
	}
		
	/**
	 * Método que lee un string
	 * @return string
	 */
	@SuppressWarnings("resource")
	private static String ReadString(){
		return new Scanner(System.in).nextLine();		
	}
	
	/**
	 * Método que lee un int
	 * @return int
	 */
	@SuppressWarnings("resource")
	private static int ReadInt(){
		return new Scanner(System.in).nextInt();			
	}	
}
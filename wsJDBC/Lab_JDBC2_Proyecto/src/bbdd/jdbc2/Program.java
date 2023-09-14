package bbdd.jdbc2;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Scanner;

import Aux_Package.AuxClass;

/**
 * Titulo: Clase Program
 *
 * @author Omar Teixeira González, UO281847
 * @version 28 abr 2022
 */
public class Program {
	
	/**
	 * Método Main
	 * @param args
	 * @throws SQLException
	 */
	public static void main(String[] args) throws SQLException {
		System.out.println("Exercise 2_b:");
		exercise2_b();
		System.out.println("Exercise 3_a:");
		exercise3_a();
		System.out.println("Exercise 3_b:");
		exercise3_b();
	}

	
	/*
    2. En JAVA:
    b. Realizar un listado en el que, para los cines de una determinada localidad, se indique la recaudacion total
	obtenida en cada cine, asi como la obtenida por cada una de las peliculas en el proyectadas
    	Cine 1 - Recaudacion_total
			Codpelicula1 - Titulo1- Recaudacion_total_pelicula_1_en_cine1
			Codpelicula 2 - Titulo2 - Recaudacion_total_pelicula_2_en_cine1
		Cine 2 â€“ Recaudacion_total
			Codpelicula1 â€“ Titulo1 â€“ Recaudacion_total_pelicula_1_en_cine2
			Codpelicula 2 â€“ Titulo2 â€“ Recaudacion_total_pelicula_2_en_cine2
			Codpelicula 3 â€“ Titulo3 â€“ Recaudacion_total_pelicula_3_en_cine2 
    */
	public static void exercise2_b() throws SQLException {
		String queryCines = "SELECT C.CODCINE, SUM(E.PRECIO) AS TOTAL_CINE "
				+ "FROM CINES C, SALAS S, ENTRADAS E WHERE C.LOCALIDAD=? AND "
				+ "C.CODCINE=S.CODCINE AND S.CODSALA=E.CODSALA GROUP BY C.CODCINE";
		String queryPeliculas = "SELECT P.CODPELICULA, P.TITULO, SUM(E.PRECIO) AS TOTAL_PELICULA "
				+ "FROM PELICULAS P, SALAS S, ENTRADAS E WHERE S.CODCINE=? AND S.CODSALA=E.CODSALA "
				+ "AND E.CODPELICULA=P.CODPELICULA GROUP BY P.CODPELICULA, P.TITULO";
		System.out.print("Localidad: ");
		String localidad = ReadString();
		
		ResultSet rsCines = AuxClass.solveQuery(queryCines, localidad);
		while (rsCines.next()) {
			final String codcine = rsCines.getString("CODCINE");
			final int totalCine = rsCines.getInt("TOTAL_CINE");
			System.out.println(String.format(
					"\tCine %s - %d",
					codcine,
					totalCine
					));
			ResultSet rsPeliculas = AuxClass.solveQuery(queryPeliculas, codcine);
			while (rsPeliculas.next()) {
				final String codpelicula = rsPeliculas.getString("CODPELICULA");
				final String titulo = rsPeliculas.getString("TITULO");
				final int totalPelicula = rsPeliculas.getInt("TOTAL_PELICULA");
				System.out.println(String.format(
						"\t\tPelícula %s - %s - %d",
						codpelicula,
						titulo,
						totalPelicula
						));
			}
			rsPeliculas.close();
		}
		rsCines.close();
		AuxClass.getPreparedStatement().close();
		AuxClass.getConnection().close();	
	}
	
	/*
	3. En JAVA:
	a. Realizar un listado en el que se indique la siguiente informacion para cada pelicula:
		Titulo_Pelicula 1
			Cine 1
				Sala - Sesion - Numero de espectadores
				Sala - Sesion - Numero de espectadores
			Cine 2
				Sala - Sesion - Numero de espectadores
				Sala - Sesion - Numero de espectadores
	*/
	public static void exercise3_a() throws SQLException {
		String queryPelicula = "SELECT TITULO, CODPELICULA FROM PELICULAS";		
		String queryCines = "SELECT S.CODCINE FROM SALAS S, PROYECTAN P"
				+ " WHERE P.CODPELICULA=? AND P.CODSALA=S.CODSALA";
		String querySalas = "SELECT S.CODSALA, P.SESION, SUM(P.ENTRADASVENDIDAS) AS N_ESPECTADORES"
				+ " FROM SALAS S, PROYECTAN P WHERE P.CODPELICULA=? AND S.CODCINE=? AND S.CODSALA=P.CODSALA"
				+ " GROUP BY S.CODSALA, P.SESION";
		ResultSet rsPeliculas = AuxClass.solveQuery(queryPelicula);
		while (rsPeliculas.next()) {
			final String titulo = rsPeliculas.getString("TITULO");
			final String codpelicula = rsPeliculas.getString("CODPELICULA");
			System.out.println(String.format(
					"\tTítulo: %s",
					titulo
					));
			ResultSet rsCines = AuxClass.solveQuery(queryCines, codpelicula);
			while (rsCines.next()) {
				final String codcine = rsCines.getString("CODCINE");
				System.out.println(String.format(
						"\t\tCine: %s",
						codcine
						));
				ResultSet rsSalas = AuxClass.solveQuery(querySalas, codpelicula, codcine);
				while (rsSalas.next()) {
					final String codsala = rsSalas.getString("CODSALA");
					final String sesion = rsSalas.getString("SESION");
					final int nEspectadores = rsSalas.getInt("N_ESPECTADORES");
					System.out.println(String.format(
							"\t\t\tSala: %s - %s - %d",
							codsala,
							sesion,
							nEspectadores
							));
				}
				rsSalas.close();
			}
			rsCines.close();
		}
		rsPeliculas.close();
		AuxClass.getStatement().close();
		AuxClass.getPreparedStatement().close();
		AuxClass.getConnection().close();
	}
		
	/*
	3. En JAVA:
	b. Invocar desde Java la función realizada en el ejercicio 2.a).
	*/
	public static void exercise3_b() throws SQLException {
		String call = "{? = call LISTADO_PELICULAS_FUNCTION}";
		
		CallableStatement cs = AuxClass.callFunctionOrProcedure(call, null, new int[] {AuxClass.VARCHAR_TYPE});
		
		cs.execute();
		
		String result = cs.getString(1);		
		result=result.replace("\\n", "\n");
		System.out.println(result);
		
		cs.close();
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
	@SuppressWarnings({ "resource", "unused" })
	private static int ReadInt(){
		return new Scanner(System.in).nextInt();			
	}	
}

package bbdd.jdbc3;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.Scanner;

/**
 * Titulo: Clase Program
 *
 * @author Omar Teixeira González, UO281847
 * @version 28 abr 2022
 */
public class Program {
	
	/**
	 * Constante USERNAME
	 */
	public final static String USERNAME = "UO281847";
	/**
	 * Constante PASSWORD
	 */
	public final static String PASSWORD = "24@Omar24BDatos";
	/**
	 * Constante CONNECTION_STRING
	 */
	public final static String CONNECTION_STRING = "jdbc:oracle:thin:@156.35.94.98:1521:desa19";
	
	/**
	 * Método Main
	 * @param args
	 * @throws SQLException
	 */
	public static void main(String[] args) throws SQLException {
//		System.out.println("EXERCISE 1");
//		exercise1();
//		System.out.println("\nEXERCISE 2");
//		exercise2();
//		System.out.println("\nEXERCISE 3");
//		exercise3();
//		System.out.println("\nEXERCISE 4");
//		exercise4();
//		System.out.println("\nEXERCISE 5");
//		exercise5();
//		System.out.println("\nEXERCISE 6");
//		exercise6();
		System.out.println("\nEXERCISE 7");
		exercise7();
	}

	/**
	 * Realizar un listado en el que se indique la siguiente información para cada película.
	 *		Titulo_Pelicula 1
	 *			Cine 1
	 *				Sala – Sesión – Nº de espectadores
	 *				Sala – Sesión – Nº de espectadores
	 *			Cine 2
	 *				Sala – Sesión – Nº de espectadores
	 *				Sala – Sesión – Nº de espectadores
	 * El número de espectadores se entiende que es el número de entradas vendidas para esa
	 * película en esa sala durante esa sesión.
	 * @throws SQLException 
	 */
	public static void exercise1() throws SQLException {
		Connection con = null;		
		Statement stPeliculas = null;
		PreparedStatement pstCines = null;
		PreparedStatement pstSalas = null;
		
		String queryPeliculas = "SELECT CODPELICULA, TITULO FROM PELICULAS";
		String queryCines = "SELECT CODCINE FROM SALAS S, PROYECTAN P WHERE"
				+ " P.CODPELICULA=? AND P.CODSALA=S.CODSALA GROUP BY CODCINE";
		String querySalas = "SELECT S.CODSALA, P.SESION, SUM(P.ENTRADASVENDIDAS) AS N_ESPECTADORES FROM SALAS S, PROYECTAN P"
				+ " WHERE S.CODCINE=? AND P.CODSALA=S.CODSALA AND P.CODPELICULA=? GROUP BY S.CODSALA, P.SESION";
		
		try {
			DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
			con = DriverManager.getConnection(CONNECTION_STRING, USERNAME, PASSWORD);			
			stPeliculas = con.createStatement();
			
			ResultSet rsPeliculas = stPeliculas.executeQuery(queryPeliculas);
			
			while (rsPeliculas.next()) {
				final String codPelicula = rsPeliculas.getString("CODPELICULA");
				final String titulo = rsPeliculas.getString("TITULO");
				System.out.println(titulo);				
				
				pstCines = con.prepareStatement(queryCines);
				pstCines.setString(1, codPelicula);
				
				ResultSet rsCines = pstCines.executeQuery();
				while (rsCines.next()) {
					final String codCine = rsCines.getString("CODCINE");
					System.out.println("    " + codCine);
					
					pstSalas = con.prepareStatement(querySalas);
					pstSalas.setString(1, codCine);
					pstSalas.setString(2, codPelicula);
					
					ResultSet rsSalas = pstSalas.executeQuery();
					while (rsSalas.next()) {
						final String codSala = rsSalas.getString("CODSALA");
						final String sesion = rsSalas.getString("SESION");
						final String nEspectadores = rsSalas.getString("N_ESPECTADORES");
						
						System.out.println("        " + codSala + " - " + sesion + " - " + nEspectadores);
					}
					rsSalas.next();
				}				
				rsCines.close();
				
			}
			rsPeliculas.next();			
			
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			pstSalas.close();
			pstCines.close();
			stPeliculas.close();
			con.close();
		}
	}
	
	/**
	 * Invocar desde Java la función realizada en el ejercicio 2.a).
	 * @throws SQLException 
	 */
	public static void exercise2() throws SQLException {
		Connection con = null;		
		CallableStatement cs = null;
		
		String call = "{? = call PELICULA_MAS_VISTA}";
		
		try {
			DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
			con = DriverManager.getConnection(CONNECTION_STRING, USERNAME, PASSWORD);
			
			cs = con.prepareCall(call);
			cs.registerOutParameter(1, Types.VARCHAR);
			cs.execute();
			
			String tipo = cs.getString(1);
			System.out.println("    El tipo más visto es: " + tipo);
			
						
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			cs.close();
			con.close();
		}
	}
	
	/**
	 * Invocar desde Java la funcion DEVUELVE_NPAREJAS
	 * @throws SQLException 
	 */
	public static void exercise3() throws SQLException {
		Connection con = null;		
		CallableStatement cs = null;
		
		String call = "{? = call DEVUELVE_NPAREJAS(?,?)}";
		System.out.print("Sección: ");
		final int section = ReadInt();
		System.out.print("Parejas máx: ");
		final int maxParejas = ReadInt();
		
		try {
			DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
			con = DriverManager.getConnection(CONNECTION_STRING, USERNAME, PASSWORD);
			
			cs = con.prepareCall(call);
			cs.registerOutParameter(1, Types.INTEGER);			
			cs.setInt(2, section);			
			cs.setInt(3, maxParejas);			
			cs.execute();
			
			int nParejas = cs.getInt(1);
			System.out.println("    El numero de parejas diferentes es: " + nParejas);
			
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			cs.close();
			con.close();
		}
	}
	
	/**
	 * Hacer un listado que muestre para cada tipo de ciclista, el número de ciclisas
	 * de ese tipo que hay registrados (numciclistas) y el número de etapas en las que los ciclistas
	 * de ese tipo han quedado clasificados en primer lugar (numetapas). Para cada una de esas etapas
	 * indicar, de las formar que se especifica a continuación, los siguientes datos: número de tramos
	 * por los que discurre la etrapa (numtramos), número de carreteras diferentes que atraviesa (numcarreteras),
	 * y el número de incidentes que han ocurrido en dicha etapa y a los que no han tenido que acudir agentes (numincidentes).
	 * 
	 * 	TIPO DE CICLISTA: tipo_ciclista   numciclistas	numetapas
	 * 	---ETAPA GANADA: num_etapa   numtramos   numcarreteras   numincidentes
	 *  ---ETAPA GANADA: num_etapa   numtramos   numcarreteras   numincidentes
	 *  
	 *  TIPO DE CICLISTA: tipo_ciclista   numciclistas	numetapas
	 *  ---ETAPA GANADA: num_etapa   numtramos   numcarreteras   numincidentes
	 *  ---ETAPA GANADA: num_etapa   numtramos   numcarreteras   numincidentes
	 */
	public static void exercise4() throws SQLException {
		Connection con = null;	
		Statement stCiclistas = null;
		PreparedStatement pstNumEtapas = null;
		PreparedStatement pstEtapas = null;
		Statement stNumIncidentes = null;
		
		String queryCiclistas = "SELECT TYPE_CYCLIST, COUNT(DISTINCT CYCLIST_NAME) AS NUMCICLISTAS"
				+ " FROM CYCLIST GROUP BY TYPE_CYCLIST";
		String queryNumEtapas = "SELECT COUNT(*) AS NUMETAPAS FROM TAKES_PART TP, CYCLIST C"
				+ " WHERE C.TYPE_CYCLIST=? AND C.CYCLIST_NAME=TP.CYCLIST_NAME AND TP.ORDER_CLASSIFICATION=1";
		String queryEtapas = "SELECT TP.NUM_STAGE AS NUMETAPA, COUNT(*) AS NUMTRAMOS, COUNT(DISTINCT G.ID_ROAD) AS NUMCARRETERA"
				+ " FROM CYCLIST C, TAKES_PART TP, STAGE S, GOES_BY G WHERE C.TYPE_CYCLIST=? AND C.CYCLIST_NAME=TP.CYCLIST_NAME"
				+ " AND TP.ORDER_CLASSIFICATION=1 AND TP.NUM_STAGE=S.NUM_STAGE AND S.NUM_STAGE=G.NUM_STAGE GROUP BY TP.NUM_STAGE";
		String queryIncidentes = "SELECT COUNT(*) AS NUMINCIDENTES FROM INCIDENT INC, TSECTION S, GOES_BY G"
				+ " WHERE INC.ID_INCIDENT NOT IN (SELECT ID_INCIDENT FROM COMES) AND S.ID_ROAD=G.ID_ROAD"
				+ " AND S.ORDER_ROAD=G.ORDER_ROAD AND S.ID_ROAD=INC.ID_ROAD AND INC.ORDER_ROAD=S.ORDER_ROAD";
		try {
			DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
			con = DriverManager.getConnection(CONNECTION_STRING, USERNAME, PASSWORD);			
			stCiclistas = con.createStatement();			
			
			ResultSet rsCiclistas = stCiclistas.executeQuery(queryCiclistas);			
			while (rsCiclistas.next()) {
				final String tipo = rsCiclistas.getString("TYPE_CYCLIST");
				final int numCiclistas = rsCiclistas.getInt("NUMCICLISTAS");
				
				pstNumEtapas = con.prepareStatement(queryNumEtapas);
				pstNumEtapas.setString(1, tipo);
				ResultSet rsNumEtapas = pstNumEtapas.executeQuery();
				rsNumEtapas.next();
				final int numEtapas = rsNumEtapas.getInt("NUMETAPAS");
				
				System.out.println("TIPO DE CICLISTA: " + tipo + "    " + numCiclistas + "    " + numEtapas);
				
				rsNumEtapas.close();
				
				pstEtapas = con.prepareStatement(queryEtapas);
				pstEtapas.setString(1, tipo);
				ResultSet rsEtapas = pstEtapas.executeQuery();
				while (rsEtapas.next()) {
					final int numEtapa = rsEtapas.getInt("NUMETAPA");
					final int numTramos = rsEtapas.getInt("NUMTRAMOS");
					final int numCarretera = rsEtapas.getInt("NUMCARRETERA");
					
					stNumIncidentes = con.createStatement();
					ResultSet rsNumIncidentes = stNumIncidentes.executeQuery(queryIncidentes);
					rsNumIncidentes.next();
					final int numIncidentes = rsNumIncidentes.getInt("NUMINCIDENTES");
					
					System.out.println("---ETAPA GANADA: " + numEtapa + "    " + numTramos + "    " + numCarretera + "    " + numIncidentes);
					
					rsNumIncidentes.close();					
				}
				rsEtapas.close();
			}			
			rsCiclistas.close();
			
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			pstNumEtapas.close();
			stCiclistas.close();
			con.close();
		}
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
	public static void exercise5() throws SQLException {
		Connection con = null;	
		PreparedStatement pstCines = null;
		PreparedStatement pstPeliculas = null;
		
		String queryCines = "SELECT C.CODCINE, SUM(E.PRECIO) AS TOTAL_CINE "
				+ "FROM CINES C, SALAS S, ENTRADAS E WHERE C.LOCALIDAD=? AND C.CODCINE=S.CODCINE AND S.CODSALA=E.CODSALA GROUP BY C.CODCINE";		
		String queryPeliculas = "SELECT P.CODPELICULA, P.TITULO, SUM(E.PRECIO) AS TOTAL_PELICULA "
				+ "FROM PELICULAS P, SALAS S, ENTRADAS E WHERE S.CODCINE=? AND S.CODSALA=E.CODSALA "
				+ "AND E.CODPELICULA=P.CODPELICULA GROUP BY P.CODPELICULA, P.TITULO";
		
		System.out.print("Introduzca la localidad: ");
		final String localidad = ReadString();		
		
		try {
			DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
			con = DriverManager.getConnection(CONNECTION_STRING, USERNAME, PASSWORD);			
			
			pstCines = con.prepareStatement(queryCines);
			pstCines.setString(1, localidad);
			ResultSet rsCines = pstCines.executeQuery();
			while(rsCines.next()) {
				final String codCine = rsCines.getString("CODCINE");
				final int totalCine = rsCines.getInt("TOTAL_CINE");
				System.out.println("Cine: " + codCine + " - Recaudación total: " + totalCine);
				
				pstPeliculas = con.prepareStatement(queryPeliculas);
				pstPeliculas.setString(1, codCine);
				ResultSet rsPeliculas = pstPeliculas.executeQuery();
				while (rsPeliculas.next()) {
					final String codpelicula = rsPeliculas.getString("CODPELICULA");
					final String titulo = rsPeliculas.getString("TITULO");
					final int totalPelicula = rsPeliculas.getInt("TOTAL_PELICULA");
					System.out.println("\tPelícula: " + codpelicula + " - Titulo: " + titulo + " - Recaudación total en cine: " + totalPelicula);
				}
				rsPeliculas.close();
			}
			rsCines.close();
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			pstPeliculas.close();
			pstCines.close();
			con.close();
		}
	}
	
	/**
	 * La DGT ha decidido acortar en cierto porcentaje las carreteras que han sufrido 
	 * más de cierto número de incidentes de tipo salida de vía o choques. 
	 * 
	 * Realizar un método que para un porcentaje y número de incidentes determinado (parámetros) 
	 * acorte la longitud de las carreteras en dicho porcentaje siempre y cuando en esa carretera 
	 * hayan ocurrido más incidentes de tipo salida de vía o choques que el parámetro recibido. 
	 * 
	 * El método debe mostrar por pantalla también el número de carreteras modificadas.
	 * @throws SQLException 
	 */
	public static void exercise6() throws SQLException {
		Connection con = null;
		PreparedStatement pstUpdate = null;
		
		System.out.print("Introduzca el porcentaje: ");
		final int porcentaje = ReadInt();
		System.out.print("Introduzca el número de incidentes: ");
		final int numIncidentes = ReadInt();
				
		String update = "UPDATE ROAD SET LENGTH_ROAD=LENGTH_ROAD*?/100 WHERE (SELECT COUNT(*)"
				+ " FROM INCIDENT I WHERE I.ID_ROAD=ID_ROAD AND DESCRIP_INCIDENT IN ('salida de via', 'choque')) > ?";
		
		try {
			DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
			con = DriverManager.getConnection(CONNECTION_STRING, USERNAME, PASSWORD);
			
			pstUpdate = con.prepareStatement(update);
			
			pstUpdate.setInt(1, porcentaje);
			pstUpdate.setInt(2, numIncidentes);			
			if (pstUpdate.executeUpdate()==1) {
				System.out.println("Datos actualizados");
				System.out.println("El número de carreteras modificadas es: " + pstUpdate.getUpdateCount());
			} else {
				System.out.println("Datos no actualizados");
			}
			
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			pstUpdate.close();
			con.close();
		}
	}
	
	/**
	 * Crear un método que muestre por pantalla las etapas de montaña de categoría especial.
	 *  De cada una de ellas debe mostrarse el número de etapa, altitud, longitud, 
	 *  así como el número de ciclistas que la disputan que pertenecen a equipos que 
	 *  reciben subvenciones de más de 1000000€. 
	 *  Además, deben mostrarse para cada una de ellas, los tramos por los que pasa, 
	 *  la longitud de estos y el tipo de carretera de cada uno de los tramos
	 *        Etapa montaña: num_etapa altitud km num_ciclisas
	 *         <-- ordenados por longitud en km de mayor a menor
	 *               Tramo: orden_carretera id_carretera longitud_tramo tipo_carretera
	 *        Etapa montaña: num_etapa altitud km num_ciclisas
	 *         <-- ordenados por longitud en km de mayor a menor
	 * @throws SQLException
	 */
	public static void exercise7() throws SQLException {
		Connection con = null;
		Statement stEtapas = null;
		PreparedStatement pstTramos = null;
		
		String queryEtapas = "SELECT MS.NUM_STAGE, MS.ALTITUDE, S.KM, COUNT(C.CYCLIST_NAME) AS NUM_CICLISTAS"
				+ " FROM MOUNTAINSTAGE MS, STAGE S, TAKES_PART TP, CYCLIST C, TEAM T"
				+ " WHERE MS.CATEGORY_MOUNTAIN='especial' AND MS.NUM_STAGE=S.NUM_STAGE AND"
				+ " S.NUM_STAGE=TP.NUM_STAGE AND TP.CYCLIST_NAME=C.CYCLIST_NAME AND"
				+ " C.NAME_TEAM=T.NAME_TEAM AND T.BUDGET > 1000000 GROUP BY MS.NUM_STAGE, MS.ALTITUDE, S.KM ORDER BY S.KM DESC";
		
		String queryTramos = "SELECT TS.ORDER_ROAD, TS.ID_ROAD, TS.LENGTH_SECTION, R.TYPE_ROAD FROM GOES_BY G, TSECTION TS, ROAD R"
				+ " WHERE G.NUM_STAGE=? AND G.ORDER_ROAD=TS.ORDER_ROAD AND G.ID_ROAD=TS.ID_ROAD AND TS.ID_ROAD=R.ID_ROAD;";
		
		try {
			DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
			con = DriverManager.getConnection(CONNECTION_STRING, USERNAME, PASSWORD);
			
			stEtapas = con.createStatement();
			ResultSet rsEtapas = stEtapas.executeQuery(queryEtapas);
			while(rsEtapas.next()) {
				final int numEtapa = rsEtapas.getInt("NUM_STAGE");
				final int altitud = rsEtapas.getInt("ALTITUDE");
				final int km = rsEtapas.getInt("KM");
				final int numCiclistas = rsEtapas.getInt("NUM_CICLISTAS");
				
				System.out.println("Etapa montaña: " + numEtapa + "  " + altitud + "  " + km + "  " + numCiclistas);
				
				pstTramos = con.prepareStatement(queryTramos);
				pstTramos.setInt(1, numEtapa);				
				ResultSet rsTramos = pstTramos.executeQuery();
				while (rsTramos.next()) {
					final int ordenCarretera = rsTramos.getInt("ORDER_ROAD");
					final String idCarretera = rsTramos.getString("ID_ROAD");
					final int longitudTramo = rsTramos.getInt("LENGTH_SECTION");
					final String  tipoCarretera = rsTramos.getString("TYPE_ROAD");
					
					System.out.println("Tramo: " + ordenCarretera + "  " + idCarretera + "  " + longitudTramo + "  " + tipoCarretera);
				}
				rsTramos.close();
			}
			rsEtapas.close();
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			pstTramos.close();
			stEtapas.close();
			con.close();
		}		
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

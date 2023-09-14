package es.uniovi.eii.bbdd.jdbc.exam.june22;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.Scanner;

/**
 * From this main class it must be possible to execute
 * the methods implemented during the test.
 * 
 * (ES)
 * Si al importar el proyecto te da un problema con la
 * versiÃ³n de Java: BotÃ³n secundario sobre el
 * proyecto > "Build Path", "Configure Build Path" > "Libraries".
 * En "Modulepath" elimina la versiÃ³n de JRE que te estÃ¡
 * dando problemas y aÃ±ade la que tengas en tu equipo
 * desde el botÃ³n de "Add Library".
 * 
 * (EN)
 * If when importing the project you have a problem with
 * the Java version: Right-click on the
 * project > "Build Path", "Configure Build Path" > "Libraries".
 * In "Modulepath" delete the JRE version that is giving you
 * problems and add the one you have in your computer from
 * the "Add Library" button.
 *  
 * @author Databases 2022 Teaching Staff.
 */
public class Program {
//CONSTANTES PARA LA RED
	/**
	 * Constante USERNAME
	 */
	public static final String USERNAME = "EXJ22_UO281847";
	/**
	 * Constante PASSWORD
	 */
	public static final String PASSWORD = "JUO281847";
	/**
	 * Constante URL
	 */
	public static final String URL = "jdbc:oracle:thin:@156.35.94.98:1521:DESA19";

//EXAMEN
	/**
	 * Método Main
	 * @param args
	 */
	public static void main(String[] args) {		
		System.out.println("-------------- JDBC EXAM --------------");
		try {
			System.out.println("EXERCISE 1:");
			exercise1();
			System.out.println("\nEXERCISE 2:");
			exercise2();
		} catch (SQLException ex) {
			System.out.println("SQLException recogida: ");
			while (ex!=null){
				System.out.println("Mensaje: "+ex.getMessage());
				System.out.println("SQLState: "+ex.getSQLState());
				System.out.println("ErrorCode: "+ex.getErrorCode());
				ex=ex.getNextException();
				System.out.println("");
			}
		}
	}

	/**
	 * Ejercicio 1 (6 puntos). Crear un método que, dado un nombre de ciclista introducido por el
	 * usuario, muestre un listado de las etapas en las que ha participado incluyendo el número de la etapa
	 * (num_stage), la longitud (km), la fecha en la que se realizó (date_stage), y la posición en la que el 
	 * ciclista terminó la carrera (order_classification). Para cada etapa, se deben mostrar cada uno de los
	 * tramos que componen la etapa con la siguiente información: Identificador de la carretera (id_road),
	 * tipo de carretera (type_road), orden del tramo (order_road) y la longitud del tramo (length_section).
	 * El listado de tramos se debe ordenar siguiendo como primer criterio el identificador de la carretera
	 * (id_road) y como segundo criterio el orden del tramo (order_road).
	 * @throws SQLException
	 */
	public static void exercise1() throws SQLException {
		Connection con = null;
		PreparedStatement pstStage = null;
		PreparedStatement pstSection = null;
		
		String queryStage = "SELECT TP.NUM_STAGE, S.KM, S.DATE_STAGE, TP.ORDER_CLASSIFICATION"
				+ " FROM TAKES_PART TP, STAGE S WHERE TP.CYCLIST_NAME=? AND TP.NUM_STAGE=S.NUM_STAGE";
		
		String querySection = "SELECT TS.ID_ROAD, R.TYPE_ROAD, TS.ORDER_ROAD, TS.LENGTH_SECTION"
				+ " FROM GOES_BY G, TSECTION TS, ROAD R WHERE G.NUM_STAGE=? AND G.ID_ROAD=TS.ID_ROAD"
				+ " AND G.ORDER_ROAD=TS.ORDER_ROAD AND TS.ID_ROAD=R.ID_ROAD ORDER BY TS.ID_ROAD, TS.ORDER_ROAD";
		
		System.out.print("Introduzca el nombre del ciclista: ");
		final String cyclistName = ReadString();
		
		try {
			DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
			con = DriverManager.getConnection(URL, USERNAME, PASSWORD);
			
			pstStage = con.prepareStatement(queryStage);
			pstStage.setString(1, cyclistName);
			
			ResultSet rsStage = pstStage.executeQuery();
			while (rsStage.next()) {
				final int numStage = rsStage.getInt("NUM_STAGE");
				final int km = rsStage.getInt("KM");
				final Date dateStage = rsStage.getDate("DATE_STAGE");
				final int orderClassification = rsStage.getInt("ORDER_CLASSIFICATION");
				
				System.out.println(String.format(
						"STAGE: %d %d %s %d", 
						numStage,
						km,
						dateStage,
						orderClassification));
				
				pstSection = con.prepareStatement(querySection);
				pstSection.setInt(1, numStage);
				
				ResultSet rsSection = pstSection.executeQuery();
				while (rsSection.next()) {
					final String idRoad = rsSection.getString("ID_ROAD");
					final String typeRoad = rsSection.getString("TYPE_ROAD");
					final int orderRoad = rsSection.getInt("ORDER_ROAD");
					final int lengthSection = rsSection.getInt("LENGTH_SECTION");
					
					System.out.println(String.format(
							"---SECTION: %s %s %d %d", 
							idRoad,
							typeRoad,
							orderRoad,
							lengthSection));
				}
				rsSection.close();
			}
			rsStage.close();
		} catch (SQLException ex) {
			System.out.println("SQLException recogida: ");
			while (ex!=null){
				System.out.println("Mensaje: "+ex.getMessage());
				System.out.println("SQLState: "+ex.getSQLState());
				System.out.println("ErrorCode: "+ex.getErrorCode());
				ex=ex.getNextException();
				System.out.println("");
			}
		} finally {
			pstSection.close();
			pstStage.close();
			con.close();
		}		
	}	
	
	/**
	 * Ejercicio 2 (4 puntos). Invocar desde Java a la función INFO_SPONSOR (disponible en el
	 * CV) que, dado un nombre de ciclista, devuelve el nombre del equipo al que pertenece y retorna la
	 * cantidad media que recibe en subvenciones. Mostrar por pantalla la información obtenida. 
	 * @throws SQLException
	 */
	public static void exercise2() throws SQLException {
		Connection con = null;
		CallableStatement cs = null;
		
		String callFunction = "{? = call INFO_SPONSOR(?,?)}";
		
		System.out.print("Introduzca el nombre del ciclista: ");
		final String cyclistName = ReadString();
		
		try {
			DriverManager.registerDriver(new oracle.jdbc.OracleDriver());
			con = DriverManager.getConnection(URL, USERNAME, PASSWORD);
			
			cs = con.prepareCall(callFunction);
			cs.registerOutParameter(1, Types.INTEGER);
			cs.setString(2, cyclistName);
			cs.registerOutParameter(3, Types.VARCHAR);			
			cs.execute();
			
			final int avgAmount = cs.getInt(1);
			final String teamName = cs.getString(3);
			System.out.println("\tEl ciclista " + cyclistName + " pertenece al equipo: " + teamName + ", que recibe: " + avgAmount);			
		} catch (SQLException ex) {
			System.out.println("SQLException recogida: ");
			while (ex!=null){
				System.out.println("Mensaje: "+ex.getMessage());
				System.out.println("SQLState: "+ex.getSQLState());
				System.out.println("ErrorCode: "+ex.getErrorCode());
				ex=ex.getNextException();
				System.out.println("");
			}
		} finally {
			cs.close();
			con.close();
		}		
	}	
	
	/**
	 * Método ReadString
	 * @return String
	 */
	@SuppressWarnings({ "resource"})
	private static String ReadString(){
		return new Scanner(System.in).nextLine();		
	}
	
	/**
	 * Método ReadInt
	 * @return Int
	 */
	@SuppressWarnings({ "resource", "unused" })
	private static int ReadInt(){
		return new Scanner(System.in).nextInt();			
	}	
}

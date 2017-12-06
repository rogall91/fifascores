package fifa.service

import javax.ws.rs.Path
import javax.ws.rs.Produces
import javax.ws.rs.core.MediaType
import javax.ws.rs.GET
import fifa.dao.MatchDAO
import fifa.dao.TableDAO
import fifa.dao.TableDAO.PlayerFilter
import javax.ws.rs.PathParam
import org.json.JSONObject
import org.json.JSONArray
import java.util.ArrayList
import java.util.Collections
import javax.ws.rs.QueryParam

@Path("/table")
@Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
class TableService {
	
	@GET
	@Path("/{playerFilter}")
	def table(@PathParam("playerFilter") String playerFilter){
		TableDAO.calculateTable(MatchDAO.allMatches, PlayerFilter.valueOf(playerFilter.toUpperCase())).toString()
	}
	
	@GET
	@Path("/{playerFilter}/month/{month}")
	def monthTable(@PathParam("playerFilter") String playerFilter, @PathParam("month") String month){
		TableDAO.calculateTable(MatchDAO.getMonthMatches(month), PlayerFilter.valueOf(playerFilter.toUpperCase())).toString()
	}
	
	@GET
	@Path("/{playerFilter}/edition/{edition}")
	def editionTable(@PathParam("playerFilter") String playerFilter, @PathParam("edition") String edition){
		TableDAO.calculateTable(MatchDAO.getEditionMatches(edition), PlayerFilter.valueOf(playerFilter.toUpperCase())).toString()
	}
	
	@GET
	@Path("/{playerFilter}/power/{numberOfMatches}")
	def powerTable(
		@PathParam("playerFilter") String playerFilter, 
		@PathParam("numberOfMatches") int numberOfMatches, 
		@QueryParam("edition") String edition
	){
		TableDAO.calculatePowerTable(
			(if (null === edition) MatchDAO.allMatches else MatchDAO.getEditionMatches(edition)), 
			PlayerFilter.valueOf(playerFilter.toUpperCase()), 
			numberOfMatches
		).toString()
	}
	
	@GET
	@Path("/{playerFilter}/session")
	def sessionTables(@PathParam("playerFilter") String playerFilter){
		new JSONObject(
			MatchDAO.getSessionMatches.mapValues[sessionMatches |
				TableDAO.calculateTable(sessionMatches, PlayerFilter.valueOf(playerFilter.toUpperCase()))
			]
		).toString()
	}
	
	def static void main(String[] args){
		val power = TableDAO.calculatePowerTable(MatchDAO.getAllMatches(), PlayerFilter.SINGLE, 10)
		val list = new ArrayList<JSONObject>()
		for (var i =0; i<power.length;i++)
			list.add(power.getJSONObject(i))
		Collections.sort(list, [r1, r2 |
			r2.getInt("points") - r1.getInt("points")
		])
		println(new JSONArray(list))
	}
}
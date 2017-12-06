package fifa.service

import org.json.JSONObject
import fifa.dao.MatchDAO
import javax.ws.rs.Path
import javax.ws.rs.GET
import javax.ws.rs.Produces
import javax.ws.rs.core.MediaType
import fifa.model.Match
import org.json.JSONArray
import javax.ws.rs.PathParam
import java.util.List

@Path("/matches")
@Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
class MatchService {
	
	@GET
	@Path("/all")
	def getAllMatches(){
		MatchDAO.allMatches.toJSON.toString()
	}
	
	@GET
	@Path("/all/{edition}")
	def getEditionMatches(@PathParam("edition") String edition){
		MatchDAO.getEditionMatches(edition).toJSON.toString()
	}
	
	@GET
	@Path("/{month}")
	def getMonthMatches(@PathParam("month") String month){
		MatchDAO.getMonthMatches(month).toJSON.toString()
	}
	
	@GET
	@Path("/sessions")
	def getSessionMatches(){
		new JSONObject(
			MatchDAO.getSessionMatches.mapValues[sessionMatches |
				sessionMatches.toJSON
			]
		).toString()
	}
	
	@GET
	@Path("/update")
	def updateMatches(){
		MatchDAO.externalUpdateMatches
	}
	
	def toJSON(List<Match> matches){
		val json = new JSONArray()
		for (match : matches){
			json.put(match.JSON)
		}
		return json
	}
	
	def static void main(String[] args){
		val matches = MatchDAO.getLastXMatchesForPlayer(5,"Rogal")
		for (match : matches){
			println(match.JSON)
		}
		MatchDAO.externalUpdateMatches
	}
}
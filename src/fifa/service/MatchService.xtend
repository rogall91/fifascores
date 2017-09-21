package fifa.service

import org.json.JSONObject
import fifa.dao.MatchDAO
import javax.ws.rs.Path
import javax.ws.rs.GET
import javax.ws.rs.Produces
import javax.ws.rs.core.MediaType
import java.util.Collection
import fifa.model.Match
import org.json.JSONArray
import javax.ws.rs.PathParam

@Path("/match")
@Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
class MatchService {
	
	@GET
	@Path("/all")
	def getAllMatches(){
		MatchDAO.allMatches.toJSON.toString()
	}
	
	@GET
	@Path("/{month}")
	def getMonthMatches(@PathParam("month") String month){
		MatchDAO.getMonthMatches(month).toJSON.toString()
	}
	
	@GET
	@Path("/sessions")
	def getSessionMatches(){
		val json = new JSONObject()
		val sesionMatches = MatchDAO.getSessionMatches
		for (key : sesionMatches.keySet){
			json.put(key, sesionMatches.get(key).toJSON)
		}
		json.toString()
	}
	
	def toJSON(Collection<Match> matches){
		val json = new JSONArray()
		for (match : matches){
			json.put(match.JSON)
		}
		return json
	}
	
	def static void main(String[] args){
		print(MatchDAO.getSessionMatches.keySet)
	}
}
package fifa.dao

import fifa.model.Match
import org.hibernate.HibernateException
import org.hibernate.Transaction
import java.util.List
import java.util.Collection
import org.json.JSONObject
import fifa.model.TeamScore
import java.util.HashMap
import java.util.ArrayList
import java.util.Date
import java.text.SimpleDateFormat
import org.json.JSONArray
import org.apache.http.impl.client.HttpClients
import org.apache.http.client.methods.HttpGet
import org.apache.http.util.EntityUtils

class MatchDAO {
	
	val static session = SessionHelper.getSession()
	
	def static getAllMatches(){
		var List<Match> matches = null
		var Transaction t = null
		try{
			t = session.beginTransaction()

			matches = session.createQuery("from Match order by date").list()

			t.commit()
		} catch (HibernateException e){
			if (t !== null) t.rollback
			e.printStackTrace()
		}

		return matches
	}
	
	def static getEditionMatches(String edition){
		var List<Match> matches = null
		var Transaction t = null
		try{
			t = session.beginTransaction()

			matches = session.createQuery("from Match where edition = :edition order by date")
					.setParameter("edition", edition)
					.list()

			t.commit()
		} catch (HibernateException e){
			if (t !== null) t.rollback
			e.printStackTrace()
		}

		return matches
	}
	
	def static getMonthMatches(String month){
		var List<Match> matches = null
		var Transaction t = null
		try{
			t = session.beginTransaction()
			
			matches = 
				session
					.createQuery("from Match where substring (date, 1, 7) = :date order by date")
					.setParameter("date", month)
					.list()

			t.commit()
		} catch (HibernateException e){
			if (t !== null) t.rollback
			e.printStackTrace()
		}

		return matches
	}
	
	def static getSessionMatches(){
		val sessions = new HashMap<String,List<Match>>()
		val matches = getAllMatches()
		val sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS")
		println("start: " + sdf.format(new Date()))

		var sessionMatches = new ArrayList<Match>
		var key = matches.get(0).date
		for (var i = 0; i < matches.length - 1; i++) {
			sessionMatches.add(matches.get(i))
				
			if (matches.get(i + 1).parsedDate.time - matches.get(i).parsedDate.time > 10800000){
				sessions.put(key, sessionMatches)
				sessionMatches = new ArrayList<Match>
				key = matches.get(i+1).date
			}
		}
		sessionMatches.add(matches.get(matches.length - 1))
		sessions.put(key, sessionMatches)
		println("end: " + sdf.format(new Date()))
		
		return sessions
	}
	
	def static getLastXMatchesForPlayer(int x, String playerName){
		var List<Match> matches = null
		var Transaction t = null
		try{
			t = session.beginTransaction()

			matches = 
				session
					.createQuery("select distinct m from Match m 
						join m.homeTeamScore.players as hp
						join m.guestTeamScore.players as gp
						where (:playerName = hp.name or :playerName = gp.name)
						order by m.date desc")
						.setParameter("playerName", playerName)
						.setMaxResults(x)
					.list()

			t.commit()
		} catch (HibernateException e){
			if (t !== null) t.rollback
			e.printStackTrace()
		}

		return matches
	}

	def static addMatch(Match m){
		var i = 0
		var Transaction t = null
		try{
			t = session.beginTransaction()

			val (TeamScore)=> void updateTeamAndPlayers = [teamScore |
				teamScore.setTeam(
					TeamDAO.getOrAddTeam(teamScore.team.name, session)
				)
				teamScore.setPlayers(
					PlayerDAO.getOrAddPlayers(teamScore.getPlayersNames(), session)
				)
			]
			
			updateTeamAndPlayers.apply(m.homeTeamScore)
			updateTeamAndPlayers.apply(m.guestTeamScore)
			
			i = session.save(m) as Integer

			t.commit()
		} catch (HibernateException e){
			if (t !== null) t.rollback
			e.printStackTrace()
		}
		    
		return i
	}

	def static addMatch(String externalId, String date, int homeScore, String homeTeam, Collection<String> homePlayers, 
				int guestScore, String guestTeam, Collection<String> guestPlayers)
	{
		addMatch(new Match(externalId, date, homeScore, homeTeam, homePlayers, guestScore, guestTeam, guestPlayers))
	}

	def static addMatch(JSONObject match)
	{
		addMatch(new Match(match))
	}

	def static addMatches(JSONArray matches)
	{
		for (var int i; i < matches.length(); i++)
			addMatch(new Match(matches.getJSONObject(i)))
	}
	
	def static deleteMatch(int id)
	{
		var Transaction t = null
		try{
			t = session.beginTransaction()
			
			val match = session.get(Match, id)
			session.delete(match)

			t.commit()
		} catch (HibernateException e){
			if (t !== null) t.rollback
			e.printStackTrace()
		}
	}
	
	def static deleteMatch(Match match)
	{
		var Transaction t = null
		try{
			t = session.beginTransaction()
			
			session.delete(match)

			t.commit()
		} catch (HibernateException e){
			if (t !== null) t.rollback
			e.printStackTrace()
		}
	}
	
	def static deleteAllMatches()
	{
			val matches = getAllMatches()
			for (match : matches){
				deleteMatch(match)
			}
	}
	
	def static getMatchByExternalId(String externalId)
	{
		var Match match = null
		var Transaction t = null
		try{
			t = session.beginTransaction()

			match = session.createQuery("from Match where externalId = :externalId")
			.setParameter("externalId", externalId)
			.uniqueResult() as Match

			t.commit()
		} catch (HibernateException e){
			if (t !== null) t.rollback
			e.printStackTrace()
		}

		return match
	}
	
	def static externalCopyAllMatches()
	{
		var httpclient = HttpClients.createDefault();
		var httpGet = new HttpGet("http://fifascores.herokuapp.com/api/scores");
		var response = httpclient.execute(httpGet);
		try {
		    val entity = response.getEntity()
		    
		    MatchDAO.addMatches(new JSONArray(EntityUtils.toString(entity)))
		    
		    EntityUtils.consume(entity)
		} finally {
		    response.close()
		}
	}
	
	def static externalUpdateMatches()
	{
		var httpclient = HttpClients.createDefault();
		var httpGet = new HttpGet("http://fifascores.herokuapp.com/api/scores");
		var response = httpclient.execute(httpGet);
		try {
			val entity = response.getEntity()

		   	val matches = new JSONArray(EntityUtils.toString(entity))

		   	var i = 1
		   	while(null === getMatchByExternalId(matches.getJSONObject(matches.length() - i).getString("id")))
		   	{
		   		MatchDAO.addMatch(matches.getJSONObject(matches.length() - i))
		   		i++
		   	}

		    EntityUtils.consume(entity)
		} finally {
		    response.close()
		}
	}
}
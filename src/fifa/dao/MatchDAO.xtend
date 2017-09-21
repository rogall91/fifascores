package fifa.dao

import fifa.model.Match
import org.hibernate.HibernateException
import org.hibernate.Transaction
import java.util.List
import java.util.Collection
import org.json.JSONObject
import fifa.model.TeamScore
import java.util.HashMap
import java.util.Collections
import java.util.ArrayList

class MatchDAO {
	
	val static session = SessionHelper.getSession()
	
	def static getAllMatches(){
		var List<Match> matches = null
		var Transaction t = null
		try{
			t = session.beginTransaction()

			matches = session.createQuery("from Match").list()

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
					.createQuery("from Match where substring (date, 1, 7) = :date")
					.setParameter("date","month")
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
		Collections.sort(matches, new Match.dateComparator)

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
		
		return sessions
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
}
package fifa.model

import java.util.Collection
import org.json.JSONObject
import javax.persistence.Entity
import javax.persistence.Id
import org.json.JSONArray
import javax.persistence.GeneratedValue
import javax.persistence.ManyToMany
import javax.persistence.OneToOne
import java.util.ArrayList
import javax.persistence.CascadeType
import javax.persistence.ManyToOne
import java.util.Collections
import java.text.SimpleDateFormat
import java.util.Comparator

@Entity
class Match {
	@Id
	@GeneratedValue
	int id
	
	String externalId
	
	String date
	
	@OneToOne(cascade = CascadeType.ALL, orphanRemoval = true)
	TeamScore homeTeamScore
	
	@OneToOne(cascade = CascadeType.ALL, orphanRemoval = true)
	TeamScore guestTeamScore
	
	String edition
	
	new (){}
	
	new (String externalId, String date, TeamScore homeTeamScore, TeamScore guestTeamScore){
		this.externalId = externalId
		this.date = date
		this.homeTeamScore = homeTeamScore
		this.guestTeamScore = guestTeamScore
	}
	
	new (String externalId, String date, int homeScore, Team homeTeam, Collection<Player> homePlayers,
		int guestScore, Team guestTeam, Collection<Player> guestPlayers
	){
		this.externalId = externalId
		this.date = date
		this.homeTeamScore = new TeamScore(homeScore, homeTeam, homePlayers)
		this.guestTeamScore = new TeamScore(guestScore, guestTeam, guestPlayers)
	}
	
	new (String externalId, String date, int homeScore, String homeTeam, Collection<String> homePlayers,
		int guestScore, String guestTeam, Collection<String> guestPlayers
	){
		this.externalId = externalId
		this.date = date
		this.homeTeamScore = new TeamScore(homeScore, homeTeam, homePlayers)
		this.guestTeamScore = new TeamScore(guestScore, guestTeam, guestPlayers)
	}
	
	new (JSONObject match){
		this.externalId = match.getString("id")
		this.date = match.getString("date")
		this.homeTeamScore = new TeamScore(match.getJSONObject("homeTeamScore"))
		this.guestTeamScore = new TeamScore(match.getJSONObject("guestTeamScore"))
	}
	
	def getId(){
		id
	}
	
	def setId(int id){
		this.id = id
	}
	
	def getExternalId(){
		externalId
	}
	
	def setExternalId(String externalId){
		this.externalId = externalId
	}
	
	def getDate(){
		date
	}
	
	def setDate(String date){
		this.date = date
	}
	
	def getParsedDate(){
		(new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")).parse(date)
	}
	
	def getHomeTeamScore(){
		homeTeamScore
	}
	
	def setHomeTeamScore(TeamScore homeTeamScore){
		this.homeTeamScore = homeTeamScore
	}
	
	def getGuestTeamScore(){
		guestTeamScore
	}
	
	def setGuestTeamScore(TeamScore guestTeamScore){
		this.guestTeamScore = guestTeamScore
	}
	
	def getEdition(){
		edition
	}
	
	def setEdition(String edition){
		this.edition = edition
	}
	
	def JSON(){
		val object = new JSONObject()
		object.put("externalId", this.externalId)
		object.put("date", this.date)
		object.put("homeTeamScore", this.homeTeamScore.JSON())
		object.put("guestTeamScore", this.guestTeamScore.JSON())
		object.put("id", this.id)
	}

	static class dateComparator implements Comparator<Match> {
		override compare(Match m1, Match m2) {
			m1.date.compareTo(m2.date)
		}
    }
}

@Entity
class TeamScore {
	@Id
	@GeneratedValue
	int id
	
	int score
	
	@ManyToOne
	Team team
	
	@ManyToMany
	Collection<Player> players
	
	new (){}
	
	new (int score, Team team, Collection<Player> players){
		this.score = score
		this.team = team
		this.players = players
	}
	
	new (int score, String team, Collection<String> playersName){
		this.score = score
		this.team = new Team(team)
		
		val players = new ArrayList<Player>()
		for (String name : playersName){
			players.add(new Player(name))
		}
		this.players = players
	}
	
	new (int score, String team, JSONArray playersName){
		this.score = score
		this.team = new Team(team)
		
		val players = new ArrayList<Player>()
		for (var i = 0; i < playersName.length; i++){
			players.add(new Player(playersName.getString(i)))
		}
		this.players = players
	}
	
	new (JSONObject teamScore){
		this (teamScore.getInt("score"), teamScore.getString("team"), teamScore.getJSONArray("players"))
	}
	
	def getId(){
		id
	}
	
	def setId(int id){
		this.id = id
	}

	def getScore(){
		score
	}
	
	def setScore(int score){
		this.score = score
	}
	
	def getTeam(){
		team
	}
	
	def setTeam(Team team){
		this.team = team
	}
	
	def getPlayers(){
		players
	}
	
	def setPlayers(Collection<Player> players){
		this.players = players
	}
	
	def getPlayersNames(){
		val playerNames = new ArrayList()
		
		for (Player player : players)
			playerNames.add(player.getName())
		
		Collections.sort(playerNames)
		
		return playerNames
	}
	
	def JSON(){
		val object = new JSONObject()
		object.put("score", this.score)
		object.put("team", this.team)
		val players = new JSONArray()
		for (Player player : this.players){
			players.put(player.getName())
		}
		object.put("players", players)
		return object
	}
}
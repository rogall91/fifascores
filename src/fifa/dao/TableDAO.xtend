package fifa.dao

import fifa.model.Match
import org.json.JSONObject
import org.apache.commons.lang3.StringUtils
import java.util.Collections
import java.util.List

class TableDAO {
	
	enum PlayerFilter {SINGLE, PAIR}
	
	def static calculateTable(List<Match> matches, PlayerFilter filter){
		val table = new JSONObject()
		
		val (String, int, int) => void addOrUpdateTableRow = [playerName, scored, against|
			if (table.has(playerName)){
				val player = table.getJSONObject(playerName)
				player.put("matches", player.getInt("matches") + 1)
				player.put("scored", player.getInt("scored") + scored)
				player.put("against", player.getInt("against") + against)
				player.put("scoredPerGame", player.getInt("scored") / player.getInt("matches") as double)
				player.put("againstPerGame", player.getInt("against") / player.getInt("matches") as double)
				player.put("differencePerGame", player.getDouble("scoredPerGame") - player.getDouble("againstPerGame"))
				if (scored > against) player.put("won", player.getInt("won") + 1)
				else if (scored == against) player.put("draw", player.getInt("draw") + 1)
				else if (scored < against) player.put("lost", player.getInt("lost") + 1)
				player.put("points", player.getInt("won") * 3 + player.getInt("draw"))
				player.put("pointsPerGame", player.getInt("points") / player.getInt("matches") as double)
			}
			else {
				val player = new JSONObject()
				player.put("nickname", playerName)
				player.put("matches", 1)
				player.put("scored", scored)
				player.put("against", against)
				player.put("scoredPerGame", scored)
				player.put("againstPerGame", against)
				player.put("differencePerGame", scored - against)
				player.put("won", 0)
				player.put("draw", 0)
				player.put("lost", 0)
				if (scored > against) player.put("won", 1)
				else if (scored == against) player.put("draw", 1)
				else if (scored < against) player.put("lost", 1)
				player.put("points", player.getInt("won") * 3 + player.getInt("draw"))
				player.put("pointsPerGame", player.getInt("points") / player.getInt("matches"))
				
				table.put(playerName, player)
			}
		]
		
		for (match : matches){
			if (filter === PlayerFilter.SINGLE){
				for (player : match.homeTeamScore.players){
					addOrUpdateTableRow.apply(player.name, match.homeTeamScore.score, match.guestTeamScore.score)
				}
				for (player : match.guestTeamScore.players){
					addOrUpdateTableRow.apply(player.name, match.guestTeamScore.score, match.homeTeamScore.score)
				}
			}
			else if (filter === PlayerFilter.PAIR){
				addOrUpdateTableRow.apply(StringUtils.join(match.homeTeamScore.getPlayersNames(), ","), match.homeTeamScore.score, match.guestTeamScore.score)
				addOrUpdateTableRow.apply(StringUtils.join(match.guestTeamScore.getPlayersNames(), ","), match.guestTeamScore.score, match.homeTeamScore.score)
			}
		}
		return table.toJSONArray(table.names())
	}
	
	def static calculatePowerTable(List<Match> matches, PlayerFilter filter, int numberOfMatches){
		val table = new JSONObject()
		
		val (String, int, int) => void addOrUpdateTableRow = [playerName, scored, against|
			if (table.has(playerName)){
				val player = table.getJSONObject(playerName)
				if (player.getInt("matches") < numberOfMatches){
					player.put("matches", player.getInt("matches") + 1)
					player.put("scored", player.getInt("scored") + scored)
					player.put("against", player.getInt("against") + against)
					player.put("scoredPerGame", player.getInt("scored") / player.getInt("matches") as double)
					player.put("againstPerGame", player.getInt("against") / player.getInt("matches") as double)
					player.put("differencePerGame", player.getDouble("scoredPerGame") - player.getDouble("againstPerGame"))
					if (scored > against) player.put("won", player.getInt("won") + 1)
					else if (scored == against) player.put("draw", player.getInt("draw") + 1)
					else if (scored < against) player.put("lost", player.getInt("lost") + 1)
					player.put("points", player.getInt("won") * 3 + player.getInt("draw"))
					player.put("pointsPerGame", player.getInt("points") / player.getInt("matches") as double)
				}
			}
			else {
				val player = new JSONObject()
				player.put("nickname", playerName)
				player.put("matches", 1)
				player.put("scored", scored)
				player.put("against", against)
				player.put("scoredPerGame", scored)
				player.put("againstPerGame", against)
				player.put("differencePerGame", scored - against)
				player.put("won", 0)
				player.put("draw", 0)
				player.put("lost", 0)
				if (scored > against) player.put("won", 1)
				else if (scored == against) player.put("draw", 1)
				else if (scored < against) player.put("lost", 1)
				player.put("points", player.getInt("won") * 3 + player.getInt("draw"))
				player.put("pointsPerGame", player.getInt("points") / player.getInt("matches"))
				
				table.put(playerName, player)
			}
		]
		
		Collections.sort(matches, [ m1, m2 |
			m2.date.compareTo(m1.date)
		])
		for (match : matches){
			if (filter === PlayerFilter.SINGLE){
				for (player : match.homeTeamScore.players){
					addOrUpdateTableRow.apply(player.name, match.homeTeamScore.score, match.guestTeamScore.score)
				}
				for (player : match.guestTeamScore.players){
					addOrUpdateTableRow.apply(player.name, match.guestTeamScore.score, match.homeTeamScore.score)
				}
			}
			else if (filter === PlayerFilter.PAIR){
				addOrUpdateTableRow.apply(StringUtils.join(match.homeTeamScore.getPlayersNames(), ","), match.homeTeamScore.score, match.guestTeamScore.score)
				addOrUpdateTableRow.apply(StringUtils.join(match.guestTeamScore.getPlayersNames(), ","), match.guestTeamScore.score, match.homeTeamScore.score)
			}
		}
		return table.toJSONArray(table.names())
	}
}
package fifa.dao

import org.hibernate.Transaction
import org.hibernate.HibernateException
import fifa.model.Player
import org.hibernate.Session
import java.util.Collection
import java.util.ArrayList

class PlayerDAO {
	
	val static session = SessionHelper.getSession()
	
	def static getOrAddPlayer(String name){
		var Player player = null
		var Transaction t = null
		try{
			t = session.beginTransaction()

			player = session.get(Player, name)
			
			if (player === null){
				player = new Player(name)
				session.save(player)
			}

			t.commit()
		} catch (HibernateException e){
			if (t !== null) t.rollback
			e.printStackTrace()
		}

		return player
	}
	
	def static getOrAddPlayer(String name, Session session){
		var Player player = null

		player = session.get(Player, name)
		
		if (player === null){
			player = new Player(name)
			session.save(player)
		}

		return player
	}
	
	def static getOrAddPlayers(Collection<String> names, Session session){
		val players = new ArrayList<Player>()
		for (name : names){
			players.add(getOrAddPlayer(name, session))
		}

		return players
	}
	
	def static deletePlayer(Player player){
		var Transaction t = null
		try{
			t = session.beginTransaction()

			session.delete(player)

			t.commit()
		} catch (HibernateException e){
			if (t !== null) t.rollback
			e.printStackTrace()
		}
	}
	
	def static deletePlayer(String name){
		deletePlayer(new Player(name))
	}
}
package fifa.dao

import fifa.model.Team
import org.hibernate.Transaction
import org.hibernate.HibernateException
import org.hibernate.Session

class TeamDAO {
	val static session = SessionHelper.getSession()
	def static getOrAddTeam(String name){
		var Team team = null
		var Transaction t = null
		try{
			t = session.beginTransaction()

			team = session.get(Team, name)
			
			if (team === null){
				team = new Team(name)
				session.save(team)
			}

			t.commit()
		} catch (HibernateException e){
			if (t !== null) t.rollback
			e.printStackTrace()
		}

		return team
	}
	
	def static getOrAddTeam(String name, Session session){
		var Team team = null

		team = session.get(Team, name)
		
		if (team === null){
			team = new Team(name)
			session.save(team)
		}

		return team
	}
	
	def static deleteTeam(Team team){
		val session = SessionHelper.getSession()
		var Transaction t = null
		try{
			t = session.beginTransaction()

			session.delete(team)

			t.commit()
		} catch (HibernateException e){
			if (t !== null) t.rollback
			e.printStackTrace()
		}
	}
	
	def static deleteTeam(String name){
		deleteTeam(new Team(name))
	}
}
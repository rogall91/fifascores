package fifa.dao

import org.hibernate.Transaction
import fifa.model.Setting
import org.hibernate.HibernateException
import java.util.List

class SettingDAO {
	
	val static session = SessionHelper.getSession()
	
	def getAllSettings(){
		var List<Setting> settings = null
		var Transaction t = null
		try{
			t = session.beginTransaction()

			settings = session.createQuery("from Setting").list()

			t.commit()
		} catch (HibernateException e){
			if (t !== null) t.rollback
			e.printStackTrace()
		}

		return settings
	}
	
	def getSetting(String key){
		var Setting setting = null
		var Transaction t = null
		try{
			t = session.beginTransaction()

			setting = session.get(Setting, key)

			t.commit()
		} catch (HibernateException e){
			if (t !== null) t.rollback
			e.printStackTrace()
		}

		return setting
	}
}
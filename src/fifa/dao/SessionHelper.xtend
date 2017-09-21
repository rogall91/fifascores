package fifa.dao

import org.hibernate.cfg.Configuration
import javax.annotation.PostConstruct
import javax.annotation.PreDestroy
import org.hibernate.Session

class SessionHelper {
	var static Session session
	
	def static getSession(){
		if (session === null) session = new Configuration().configure().buildSessionFactory().openSession()
		session
	}
	
	@PostConstruct
	def postConstruct(){
		session = getSession()
	}
	
	@PreDestroy
	def preDestroy(){
		session.close()
	}
}
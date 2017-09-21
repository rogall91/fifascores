package fifa.model

import javax.persistence.Entity
import javax.persistence.Id

@Entity
class Team {
	@Id
	String name
	
	boolean club
	
	double rating
	
	new (){}
	
	new (String name){
		this.name = name
	}
	
	def getName(){
		name
	}
	
	def setName(String name){
		this.name = name
	}
	
	def isClub(){
		club
	}
	
	def setClub(boolean club){
		this.club = club
	}
	
	def getRating(){
		rating
	}
	
	def setRating(double rating){
		this.rating = rating
	}
	
	override toString(){
		name
	}
}
package fifa.model

import javax.persistence.Entity
import javax.persistence.Id

@Entity
class Team {
	@Id
	String name
	
	String type
	
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
	
	def getType(){
		type
	}
	
	def setType(String type){
		this.type = type
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
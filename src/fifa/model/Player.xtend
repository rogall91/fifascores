package fifa.model

import javax.persistence.Entity
import javax.persistence.Id

@Entity
class Player {
	@Id
	String name
	
	new (){}
	
	new(String name){
		this.name = name
	}
	
	def getName(){
		name
	}
	
	def setName(String name){
		this.name = name
	}
	
	override toString(){
		name
	}
	
	def equals(Player p){
		this.name == p.name
	}
}
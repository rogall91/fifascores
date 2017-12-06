package fifa.model

import javax.persistence.Id

class Setting {
	@Id
	String key
	
	String value
	
	def getKey(){
		key
	}
	
	def setKey(String key){
		this.key = key
	}
	
	def getValue(){
		value
	}
	
	def setValue(String value){
		this.value = value
	}
}
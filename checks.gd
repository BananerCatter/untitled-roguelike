extends Control
var introfade: bool=false
var cute: bool=false
var introboss: bool=false
var introp2: bool=false
var introp3: bool=false
var introp4: bool=true
var dead: bool=false
var bail: bool=true
var loveS: int=100
signal stateChanged(flagName:String, newValue:Variant)
var itemflags:Dictionary = {}
func setflag(flagName:String, value:Variant):
	if itemflags.has(flagName) and itemflags[flagName] == value:
		return
	itemflags[flagName]=value
	stateChanged.emit(flagName, value)
func getFlag(flagName:String, defaultValue:Variant=false):
	return itemflags.get(flagName, defaultValue)
func hasFlag(flagName:String):
	return itemflags.has(flagName)
func clearFlag(flagName:String):
	if not itemflags.has(flagName):
		return
	itemflags.erase(flagName)
	stateChanged.emit(flagName, null)


	
	

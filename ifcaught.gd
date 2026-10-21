extends Node2D
@onready var diagmanager=$DiagManager
func _ready():
	var roll=randi_range(1, 5)
	if roll==1:
		loadText("res://scenes/ifcaught/ifcaughtdungeon1.json")
	if roll==2:
		loadText("res://scenes/ifcaught/ifcaughtdungeon2.json")
	if roll==3:
		loadText("res://scenes/ifcaught/ifcaughtdungeon3.json")
	if roll==4:
		loadText("res://scenes/ifcaught/ifcaughtdungeon4.json")
	if roll==5:
		loadText("res://scenes/ifcaught/ifcaughtdungeon5.json")
func loadText(path:String):
	var file=FileAccess.open(path, FileAccess.READ)
	var jsonText=file.get_as_text()
	file.close()
	var data=JSON.parse_string(jsonText)
	var lines: Array[Dictionary] = []
	for line in data:
		if line is Dictionary:
			lines.append(line)
	$DiagManager.start(lines)
	
	
	

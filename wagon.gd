extends Node2D
@onready var diagmanager=$DiagManager
func _ready():
	loadText("res://characters/bestofriendo/wagon.json")
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

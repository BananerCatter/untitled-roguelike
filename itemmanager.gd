extends Control
signal itemsLoaded
const ITEMFOLDER: String = "res://data/items"
var items:Dictionary = {}
func _ready():
	loadItems()
func loadItems():
	var directory := DirAccess.open(ITEMFOLDER)
	if directory==null:
		itemsLoaded.emit()
		return
	directory.list_dir_begin()
	var fileName := directory.get_next()
	while fileName != "":
		if not directory.current_is_dir() and fileName.ends_with(".json"):
			loadItemFile(ITEMFOLDER + fileName)
	fileName=directory.get_next()
	itemsLoaded.emit()
	print("Loaded", items.size(), " item(s).")
func loadItemFile(filePath:String):
	var file :=FileAccess.open(filePath, FileAccess.READ)
	var jsonText = file.get_as_text()
	var parsed: Variant = JSON.parse_string(jsonText)
	var item:Dictionary = parsed
	var itemID: String = str(item["id"])
	items[itemID]=item
	var json := JSON.new()
	var error := json.parse(jsonText)
	if error != OK:
		push_error("json error in %s at line %d:%s"% [filePath, json.get_error_line()])
		return
	if not parsed is Dictionary:
		push_error("json must be an object"+filePath)
		return
	file.close()
func getItem(itemID:String):
	return items[itemID]
func getAllItemIDs():
	return items.keys()
func hasItem(itemID:String):
	return items.has(itemID)
		

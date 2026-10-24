extends Control
@onready var itemName: Label = $ItemName
@onready var itemDesc: Label = $ItemDesc
var selectedItem: Dictionary = {}
func _input(event: InputEvent):
	if event.is_action_pressed("ui_accept"):
		Checks.set_flag("cooking_show", true)
	elif event.is_action_pressed("ui_cancel"):
		Checks.set_flag("coking_show", false)
func _ready():
	Checks.stateChanged.connect(_on_state_changed)
	showItem("burger")
	clearItem()
func _exit_tree():
	if Checks.stateChanged.is_connected(_on_state_changed):
		Checks.stateChanged.disconnect(_on_state_changed)
func showItem(itemID:String):
	selectedItem=Itemmanager.get_item(itemID)
	refreshDescription()
func clearItem():
	selectedItem = {}
	itemName.text = " "
	itemDesc.text = "Select an item to view it's description"
func itemUsesFlag(item:Dictionary, flagName:String):
	var rules:Array=item.get("conditonal_descriptions", [])
	for rule in rules:
		if not rule is Dictionary:
			continue
		var conditions:Variant=rule.get("conditions", [])
		for condition in conditions:
			if not condition is Dictionary:
				continue
			if str(condition.get("flag", "")) == flagName:
				return true
	return false
func _on_state_changed(flagName:String, _new_value:Variant):
	if selectedItem.is_empty():
		return
	if not itemUsesFlag(selectedItem, flagName):
		return
	refreshDescription()
func refreshDescription():
	if selectedItem.is_empty():
		clearItem()
		return
	itemName.text=str(selectedItem.get("name", "Unnamed Item"))
	itemDesc.text=getItemDesc(selectedItem)
func getItemDesc(item:Dictionary):
	var rules:Array=item.get("conditional_descriptions", [])
	for rule in rules:
		if not rule is Dictionary:
			continue
		var conditions: Variant=rule.get("conditions", [])
		if not conditions is Array:
			continue
		var allMatch := true
		for condition in conditions:
			if not condition is Dictionary:
				allMatch=false
				break
			if not checkCondition(condition):
				allMatch=false
				break
			if allMatch and rule.has("text"):
				return str(rule["text"])
		return str(item.get("default_description", "No information"))
func checkCondition(condition:Dictionary):
	if not condition.has("flag"):
		return false
	var flagName: String = str(condition["flag"])
	var operator: String=str(condition.get("operator", "equals"))
	var expected: Variant=condition.get("value", true)
	var actual: Variant=Checks.getFlag(flagName, false)
	match operator:
		"equals":
			return actual==expected
		"not_equals":
			return actual!=expected
		"greater_than":
			if actual is int or actual is float:
				if expected is int or expected is float:
					return actual>expected
			return false
		"less_than":
			if actual is int or actual is float:
				if expected is int or expected is float:
					return actual<expected
			return false
		"greater_or_equal":
			if actual is int or actual is float:
				if expected is int or expected is float:
					return actual >= expected
			return false
		"less_or_equal":
			if actual is int or actual is float:
				if expected is int or expected is float:
					return actual <=expected
			return false
		"true":
			return bool(actual)
		"fake":
			return not bool(actual)

extends Control
signal finish
var currentText: Array[Dictionary] = []
var currentLine: int=0
var choose: bool=false
@onready var speaker: Label= $Background/Items/Speaker
@onready var text: Label= $Background/Items/Text
@onready var choicescontainer: VBoxContainer= $Background/Items/ChoicesContainer
func showChoices(choices:Array):
	choose=true
	for choice in choices:
		if not choice is Dictionary:
			continue
		if not requirments(choice):
			continue
		var choiceButton := Button.new()
		choiceButton.text=str(choice.get("text", "Continue"))
		choicescontainer.add_child(choiceButton)
		choiceButton.pressed.connect(
			_on_choice_selected.bind(choice)
		)
	if choicescontainer.get_child_count()==0:
		choose=false
		currentLine+=1
		showLine()
func _on_choice_selected(choice:Dictionary):
	if choice.has("set_flags"):
		var flags:Dictionary=choice["set_flags"]
		for flag in flags:
			Checks.set(flag, flags[flag])
	currentLine=int(choice.get("next_line", currentLine +1))
	clearChoice()
	showLine()
func clearChoice():
	for child in choicescontainer.get_children():
		choicescontainer.remove_child(child)
		child.queue_free()

func _ready():
	hide()
func start(lines: Array[Dictionary]):
	currentText=lines
	currentLine=0
	show()
	showLine()
func showLine():
	clearChoice()
	choose=false
	while currentLine<currentText.size():
		var line:Dictionary=currentText[currentLine]
		if requirments(line):
			break
		currentLine +=1
	if currentLine >= currentText.size():
		end()
		return
	var line:Dictionary=currentText[currentLine]
	speaker.text=str(line.get("speaker",""))
	text.text=str(line.get("text",""))
	if line.has("set_flags"):
		var flags:Dictionary=line["set_flags"]
		for flag in flags:
			Checks.set(flag, flags[flag])
	if line.has("choices"):
		showChoices(line["choices"])
func requirments(data:Dictionary):
	if not data.has("requires"):
		return true
	var requirments:Dictionary = data["requires"]
	for flag in requirments:
		if Checks.get(flag) != requirments[flag]:
			return false
	return true
func nextLine():
	if choose:
		return
	currentLine +=1
	showLine()
func end():
	hide()
	currentText.clear()
	currentLine=0
	choose=false
	finish.emit()
func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_accept"):
		nextLine()

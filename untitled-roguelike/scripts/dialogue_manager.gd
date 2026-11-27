extends Node

var current_interactable: Area2D = null
var dialogue_box: DialogueBox = null

var dialogue_lines: Array[String] = []
var current_line_index : int = 0
var dialogue_open: bool = false

func setup(box: DialogueBox) -> void:
	dialogue_box = box
	dialogue_box.hide()

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("dialogue_interact") or event.is_echo():
		return

	if dialogue_open:
		advance_dialogue()
		return

	if current_interactable == null:
		return 
	
	if not is_instance_valid(current_interactable):
		current_interactable = null
		return
		
	if current_interactable.is_player_facing_object():
		start_dialogue(current_interactable)

func set_interactable(interactable: Area2D) -> void:
	current_interactable = interactable

func clear_interactable(interactable: Area2D) -> void:
	if current_interactable == interactable:
		current_interactable = null

func start_dialogue(interactable: Area2D) -> void:
	if dialogue_box == null:
		push_warning("DialogueBox has not been initialized!")
		return
	
	if interactable.dialogue.is_empty():
		return
	
	dialogue_lines = interactable.dialogue
	current_line_index = 0
	dialogue_open = true
	
	show_current_line(interactable)

func show_current_line(interactable: Area2D) -> void:
	dialogue_box.display_dialogue(
		interactable.character_name,
		dialogue_lines[current_line_index]
	)

func advance_dialogue() -> void:
	current_line_index += 1
	
	if current_line_index >= dialogue_lines.size():
		close_dialogue()
		return
	
	if is_instance_valid(current_interactable):
		show_current_line(current_interactable)

func close_dialogue() -> void:
	dialogue_open = false
	dialogue_lines.clear()
	current_line_index = 0
	dialogue_box.close_dialogue()

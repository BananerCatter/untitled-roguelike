class_name DialogueBox
extends Control

@onready var name_label: Label = $Background/NameLabel
@onready var dialogue_text: RichTextLabel = $Background/DialogueText
@onready var continue_label: Label = $Background/ContinueLabel

func _ready() -> void:
	hide()
	
func display_dialogue(character_name: String, text: String) -> void:
	name_label.text = character_name
	dialogue_text.text = text
	show()
	
func close_dialogue() -> void:
	hide()

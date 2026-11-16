extends Control

signal game_start
@onready var options: MenuButton = $Buttons/Options
var start_in_dungeon: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	options.get_popup().hide_on_checkable_item_selection =false
	options.get_popup().add_check_item("Spawn In Dungeon",1)
	options.get_popup().id_pressed.connect(_on_option_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	game_start.emit()


func _on_quit_pressed() -> void:
	get_tree().quit() # Replace with function body.

func _on_option_pressed(id:int) -> void:
	match id:
		1:
			options.get_popup().toggle_item_checked(0)
			start_in_dungeon = !start_in_dungeon

extends Node
@onready var main_lvl_scene= load("uid://cmu2qrnde2at7")
var main_level: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_level=main_lvl_scene.instantiate()


func _on_main_menu_game_start() -> void:
	print("start")
	%MainMenu.queue_free()

	add_child(main_level)

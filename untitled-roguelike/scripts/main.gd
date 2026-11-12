extends Node
@onready var main_lvl_scene= load("uid://cmu2qrnde2at7")

var main_level: Node2D
@export var pause_menu: CanvasLayer

var can_pause: bool = false
# Called when the node enters the scene tree for the first time.

func add_pausable_child(child:Node) ->void:
	child.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(child)

func _ready() -> void:

	main_level=main_lvl_scene.instantiate()


func _on_main_menu_game_start() -> void:
	print("start")
	%MainMenu.queue_free()
	add_pausable_child(main_level)
	can_pause = true

func toggle_pause() -> void:
	get_tree().paused = ! get_tree().paused
	pause_menu.visible = get_tree().paused
	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause") and can_pause:
		toggle_pause()

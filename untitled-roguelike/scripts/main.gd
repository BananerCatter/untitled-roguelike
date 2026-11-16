extends Node
@onready var main_lvl_scene= load("uid://cmu2qrnde2at7")
@export var main_menu: Control


var main_level: Node2D
@export var pause_menu: CanvasLayer

var can_pause: bool = false
# Called when the node enters the scene tree for the first time.

func quicksave() ->void:
	pass
	# As with like, idk, balatro, this is supposed to save where you are in the run, but you cannot make multiple saves

func add_pausable_child(child:Node) ->void:
	child.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(child)

func _ready() -> void:
	pause_menu.hide()
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


func _on_pause_menu_restart_game() -> void:
	# Add the save feature here once it uhh, exists
	get_tree().paused = false
	get_tree().reload_current_scene()

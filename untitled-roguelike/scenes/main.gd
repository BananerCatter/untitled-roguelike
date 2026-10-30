extends Node
@export var game_scene: PackedScene
var main_level: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MainMenu.game_start.connect(_on_start)

func _on_start() ->void:
	$MainMenu.queue_free()
	main_level = game_scene.instantiate()
	add_child(main_level)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

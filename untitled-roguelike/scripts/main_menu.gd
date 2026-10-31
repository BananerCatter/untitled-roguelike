extends Control

signal game_start

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	game_start.emit()

func _on_options_pressed() -> void:
	print("options") # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit() # Replace with function body.

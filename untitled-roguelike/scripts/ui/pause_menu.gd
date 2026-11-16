extends CanvasLayer
signal restart_game


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.





func _on_resume_pressed() -> void:
	hide()
	get_tree().paused = false


func _on_quit_pressed() -> void:
	get_tree().quit() 


func _on_quit_to_main_menu_pressed() -> void:
	restart_game.emit()

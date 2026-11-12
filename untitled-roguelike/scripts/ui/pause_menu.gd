extends Control



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func toggle_pause() -> void:
	var paused := not get_tree().paused
	get_tree().paused = paused
	visible = paused
	
func _input_event(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):	 
		toggle_pause()

extends CanvasLayer



func _process(delta: float) -> void:
	$InfoContainer/FPSLabel.text ="FPS: " + str(Engine.get_frames_per_second())
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_info"):
		hide()

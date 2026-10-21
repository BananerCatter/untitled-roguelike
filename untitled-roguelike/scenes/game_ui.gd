extends CanvasLayer


func _on_hp_changed(hp_value:float) -> void:
	%ProgressBar.value = hp_value

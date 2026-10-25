extends CanvasLayer

func _on_hp_changed(hp_value:float, max_hp_value:float) -> void:
	%ProgressBar._set_health((hp_value/max_hp_value)*100)
func _on_stamina_changed(stamina_value:float) ->void:
	%StaminaBar._set_health(stamina_value)
	

	
	

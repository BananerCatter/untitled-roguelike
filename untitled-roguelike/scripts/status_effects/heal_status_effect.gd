extends StatusEffect

func apply_status() -> void:
	add_child(timer)
	add_child(tick_timer)
	_on_apply.emit(status_effect_data.function, status_effect_data.args)
	tick_timer.start(status_effect_data.tick_speed)
	timer.start(status_effect_data.duration)
	timer.timeout.connect(remove_status)
	tick_timer.timeout.connect(trigger_status)
	
	
	
func physics_update(delta:float) -> void:
	pass
	
func trigger_status() -> void:

	_on_tick.emit(status_effect_data.function,status_effect_data.args)

func _remove_status():
	_on_remove.emit("pass", 0)

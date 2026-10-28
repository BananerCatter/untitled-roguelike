extends State

	
	
func exit_state() -> void:
	pass
	
	
func update(delta:float) -> void:
	pass
	
	
func physics_update(delta:float) -> void:
	character.speed= move_toward(character.speed, character.max_speed, character.acceleration*delta)
	if character.get_input() == Vector2.ZERO:
		change_state.emit("idle")
	if Input.is_action_just_pressed("dash") && character.can_dash:
			change_state.emit("dash")
	if Input.is_action_just_pressed("light_attack") && character.stamina >0:
			change_state.emit("light_attack")
	character.velocity = character.get_input()*character.speed

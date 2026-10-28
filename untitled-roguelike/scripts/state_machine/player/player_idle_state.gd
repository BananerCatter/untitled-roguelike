extends State


# Called when the node enters the scene tree for the first time.
func update(delta:float) -> void:
	character.speed = move_toward(character.speed, 0, character.acceleration*delta)
	if character.get_input() != Vector2.ZERO && character.dash_cooldown.is_stopped():
		change_state.emit("MOVING")
	if Input.is_action_just_pressed("light_attack") && character.stamina >0:
			change_state.emit("LIGHT_ATTACK")
	character.velocity=character.get_input()*character.speed

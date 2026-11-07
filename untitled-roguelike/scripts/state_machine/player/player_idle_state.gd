extends State


# Called when the node enters the scene tree for the first time.
func update(delta:float) -> void:
	character.speed = move_toward(character.speed, 0, character.acceleration*delta)
	character.velocity = character.get_input()*character.speed
	if character.get_input() != Vector2.ZERO && character.dash_cooldown.is_stopped():
		change_state.emit("MOVING")



func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_released("light_attack")  && character.stamina >0:
		
		if character.held_item and not character.held_item.animation.is_playing():
				change_state.emit("light_attack")
	

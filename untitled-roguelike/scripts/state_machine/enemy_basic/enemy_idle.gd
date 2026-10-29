extends State


# Called when the node enters the scene tree for the first time.
func enter_state() ->void:
	character.sprite.play("idle")
	character.direction=Vector2.ZERO
	
	
func physics_update(delta: float) -> void:
	character.speed = move_toward(character.speed, 0, character.acceleration*delta)
	character.velocity=character.speed*character.direction
	if character.player_found && character.dash_brake.is_stopped():
		change_state.emit("moving")
	
	

extends State
var direction: Vector2

func enter_state():
	character.timer.start()
	character.can_dash=false
	character.lose_stamina(20)
	direction =character.get_input()


func physics_update(delta:float) -> void:

	character.speed = move_toward(character.speed, character.max_speed*character.dash_mult, character.acceleration*delta*character.dash_mult)
	character.velocity = direction*character.speed
	if character.timer.is_stopped():
		change_state.emit("idle")
		
func exit_state():
	character.dash_cooldown.start()

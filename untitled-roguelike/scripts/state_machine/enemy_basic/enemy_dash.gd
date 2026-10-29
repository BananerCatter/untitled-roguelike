extends State
var dash_direction: Vector2
var dash_mult:float
# Called when the node enters the scene tree for the first time.
func enter_state() ->void:
	dash_mult=character.dash_mult
	dash_direction=( character.player.global_position - character.global_position ).normalized()
	character.sprite.play("dash")
	character.dash_duration.start()
	print("dash")
func physics_update(delta:float) -> void:
	
	character.velocity=character.speed*dash_direction
	
	character.speed = move_toward(character.speed, character.max_speed*dash_mult, character.acceleration*delta*dash_mult*dash_mult)

	if character.dash_duration.is_stopped():
		change_state.emit("idle")
func exit_state() -> void:
	character.dash_brake.start()
	character.dash_cooldown.start()
	character.can_dash=false

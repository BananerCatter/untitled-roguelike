extends State
@export var navigation_agent: NavigationAgent2D
@export var nav_recalc_timer: Timer



# Called when the node enters the scene tree for the first time.
func enter_state() ->void:
	character.sprite.play("chase")
	if not nav_recalc_timer.timeout.is_connected(_on_nav_recalc_timer_timeout):
		nav_recalc_timer.timeout.connect(_on_nav_recalc_timer_timeout)
	navigation_agent.path_desired_distance=4.0
	navigation_agent.target_desired_distance=36.0
	call_deferred("actor_setup")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func physics_update(delta:float) -> void:
	if navigation_agent.is_navigation_finished():
		change_state.emit("idle")
	var current_agent_pos:Vector2= character.global_position
	var next_path_pos:Vector2= navigation_agent.get_next_path_position()
	character.speed = move_toward(character.speed, character.max_speed, character.acceleration*delta)
	clamp(character.speed, 0, character.max_speed)
	character.direction=(current_agent_pos.direction_to(next_path_pos)).normalized()
	
	character.velocity=character.speed*character.direction

	#if character.can_dash && character.dash_cooldown.is_stopped():
		#change_state.emit("dash")

	if character.stop:
		change_state.emit("idle")
	if not character.player_found:
		change_state.emit("idle")
	if character.can_attack  && character.dash_cooldown.is_stopped(): 
		change_state.emit("light_attack")
		
func _on_nav_recalc_timer_timeout() -> void:
	set_target_position(character.player.global_position)
func actor_setup() ->void:
	await get_tree().physics_frame
	set_target_position(character.player.global_position)
	
func set_target_position(position:Vector2) -> void:
	navigation_agent.target_position = position

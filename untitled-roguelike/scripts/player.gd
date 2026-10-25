extends CharacterBody2D

signal on_death
signal hp_changed(hp_value: float)
signal stamina_changed(stamina_value:float)

@export var stats: Stats

@export var max_speed: float
@export var speed: float
@export var dash_mult: float 
var hp: int 
var max_hp: int
var hitbox: Hitbox
@export var acceleration: float
@export var timer: Timer 
@export var dash_cooldown: Timer
var can_dash:bool = true
@export var stamina: float 
@export var max_stamina: float 
@export var stamina_cooldown: Timer
@export var stamina_recovery: float
@export var hitbox_shape: Shape2D
var faction = stats.factions
#For now, the state machine is kinda pointless, but it will save us a looottt of time in the future, Ik we gotta work a lot of hours but we need to make these hours count !!!
#-----------------------------------------------------------------------------------------------------------------
enum States {IDLE, MOVING, DASH, LIGHT_ATTACK}
var state = States.IDLE
var previous_state: States
var direction: Vector2
#-----------------------------------------------------------------------------------------------------------------
func change_state(new_state:States, force_restart:bool =false) ->void:
		if state == new_state && !force_restart:
			return
		exit_state(state)	
		previous_state=state
		state =new_state
		enter_state(new_state)
			
func exit_state(exited_state:States) -> void:
		match exited_state:
			States.IDLE:
				exit_idle()

			States.MOVING:
				exit_moving()

			States.DASH:
				exit_dash()
				
			States.LIGHT_ATTACK:
				exit_light_attack()
				
func enter_state(entered_state:States) -> void:
		match entered_state:
			States.IDLE:
				enter_idle()

			States.MOVING:
				enter_moving()

			States.DASH:
				enter_dash()
				
			States.LIGHT_ATTACK:
				enter_light_attack()
#-----------------------------------------------------------------------------------------------------------------
func _ready() -> void:
	print (faction)
	max_hp=stats.current_max_health
	@warning_ignore("integer_division")
	stats.call_deferred("take_damage", 0)
	hp_changed.emit(100)
	stamina_changed.emit((stamina*100/max_stamina))
func take_damage(damage:int) -> void:
	stats.take_damage(damage)
	@warning_ignore("integer_division")
	hp_changed.emit((stats.health*100)/max_hp)
	
func heal(damage:int) -> void:

	stats.take_damage(-damage)
	@warning_ignore("integer_division")
	hp_changed.emit((stats.health*100)/max_hp)


func _input(event: InputEvent) -> void:
#Debug lines to test out the hp ui, remember to remove these lines and change the key actions for "1" and "2" once we have some real enemies !!!
		if event.is_action_pressed("debug_add_hp"):
			heal(10)
		if event.is_action_pressed("debug_deal_damage"):
			take_damage(10)

func get_input() -> Vector2:
	var direction = Input.get_vector("left", "right", "up", "down")
	return direction
	
func enter_idle():
	pass
func idle(delta:float):
	speed = move_toward(speed, 0, acceleration*delta)
	if get_input() != Vector2.ZERO && dash_cooldown.is_stopped():
		change_state(States.MOVING)
	if Input.is_action_just_pressed("light_attack") && stamina >0:
			change_state(States.LIGHT_ATTACK)
	velocity=get_input()*speed
func exit_idle():
	pass
#-----------------------------------------------------------------------------------------------------------------
func enter_moving():
	velocity = get_input()*speed
func moving(delta:float):
	speed= move_toward(speed, max_speed, acceleration*delta)
	if get_input() == Vector2.ZERO:
		change_state(States.IDLE)
	if Input.is_action_just_pressed("dash") && can_dash:
			change_state(States.DASH)
	if Input.is_action_just_pressed("light_attack") && stamina >0:
			change_state(States.LIGHT_ATTACK)
	velocity = get_input()*speed
func exit_moving():
	pass

func enter_dash():
	timer.start()
	can_dash=false
	lose_stamina(20)
	direction=get_input()


func dash(delta:float):
	speed = move_toward(speed, max_speed*dash_mult, acceleration*delta*dash_mult)
	velocity= direction*speed
	if timer.is_stopped():
		change_state(States.IDLE)
func exit_dash():
	dash_cooldown.start()
#-----------------------------------------------------------------------------------------------------------------	
func light_attack(delta:float):
	hitbox = Hitbox.new (stats, 0.5, hitbox_shape)
	add_child(hitbox)
	change_state(States.IDLE)
func enter_light_attack():
	stamina -= 10
func exit_light_attack():
	dash_cooldown.start()

func lose_stamina(lost_stamina:float):
	stamina -= lost_stamina
	stamina_cooldown.start()
	stamina_changed.emit((stamina*100/max_stamina))
	
func _on_dash_time_timeout() -> void:

	change_state(States.IDLE)
	
func _physics_process(delta: float) -> void:
	match state:
		States.IDLE:
			idle(delta)

		States.MOVING:
			moving(delta)
			

		States.DASH:
			dash(delta)
			
		States.LIGHT_ATTACK:
			light_attack(delta)
	
	if(stats.health<=0):
		on_death.emit()
	
	if stamina_cooldown.is_stopped() && stamina<max_stamina:
		stamina+=(stamina_recovery*delta)
		if(stamina>max_stamina):
			stamina=max_stamina
		stamina_changed.emit((stamina*100/max_stamina))

	move_and_slide()


func _on_dash_cooldown_timeout() -> void:
	can_dash = true

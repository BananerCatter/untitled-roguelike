extends CharacterBody2D

signal on_death
signal hp_changed(hp_value: float)
signal stamina_changed(stamina_value:float)

@export var max_speed: float = 200
@export var speed: float
@export var dash_mult: float = 2
@export var hp: int = 300
@export var max_hp: int
@export var hitbox: CollisionShape2D
@export var acceleration: float =500
@export var timer: Timer 
@export var stamina: float =100
@export var max_stamina: float =100
@export var stamina_cooldown: Timer
@export var stamina_recovery: float =24
#For now, the state machine is kinda pointless, but it will save us a looottt of time in the future, Ik we gotta work a lot of hours but we need to make these hours count !!!
enum States {IDLE, MOVING, DASH}
var state = States.IDLE
func change_state(new_state):
	state =new_state


func _ready() -> void:
	max_hp=hp
	hp_changed.emit((hp*100)/max_hp)
	stamina_changed.emit((stamina*100/max_stamina))
func take_damage(damage:int) -> void:
	hp-=damage
	@warning_ignore("integer_division")
	hp_changed.emit((hp*100)/max_hp)
	
func heal(damage:int) -> void:
	if(hp+damage>max_hp):
		hp=max_hp
	else:
		hp+=damage
	hp_changed.emit((hp*100)/max_hp)


func _input(event: InputEvent) -> void:
#Debug lines to test out the hp ui, remember to remove these lines and change the key actions for "1" and "2" once we have some real enemies !!!
		if event.is_action_pressed("debug_add_hp"):
			heal(10)
		if event.is_action_pressed("debug_deal_damage"):
			take_damage(10)

func get_input() -> Vector2:
	var direction = Input.get_vector("left", "right", "up", "down")
	return direction
func idle():
	if get_input() != Vector2.ZERO:
		change_state(States.MOVING)

func moving():

	
	if get_input() == Vector2.ZERO:
		change_state(States.IDLE)
	if Input.is_action_just_pressed("dash") && stamina >0:
		lose_stamina(20)
		if timer.is_stopped: 
			timer.start()
		change_state(States.DASH)
		

func dash():
	pass

func lose_stamina(lost_stamina:float):
	stamina -= lost_stamina
	stamina_cooldown.start()
	stamina_changed.emit((stamina*100/max_stamina))
	
func _on_dash_time_timeout() -> void:

	change_state(States.IDLE)
	
func _physics_process(delta: float) -> void:
	match state:
		States.IDLE:
			idle()
			get_input()
			speed = move_toward(speed, 0, acceleration*delta)
		States.MOVING:
			moving()
			get_input()
			speed= move_toward(speed, max_speed, acceleration*delta)
		States.DASH:
			dash()
			speed = move_toward(speed, max_speed*dash_mult, acceleration*delta*dash_mult)
	
	if(hp<=0):
		on_death.emit()
	
	if stamina_cooldown.is_stopped() && stamina<max_stamina:
		stamina+=(stamina_recovery*delta)
		if(stamina>max_stamina):
			stamina=max_stamina
		stamina_changed.emit((stamina*100/max_stamina))
		print (stamina)
	velocity = get_input()*speed
	move_and_slide()

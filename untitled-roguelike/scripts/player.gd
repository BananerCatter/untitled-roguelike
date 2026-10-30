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
@export var state_machine: StateMachine
#For now, the state machine is kinda pointless, but it will save us a looottt of time in the future, Ik we gotta work a lot of hours but we need to make these hours count !!!
#Moving the state machine to a dedicated node structure, because the player script is getting laughably bloated
#-----------------------------------------------------------------------------------------------------------------

var direction: Vector2

func _ready() -> void:
	max_hp=stats.current_max_health
	@warning_ignore("integer_division")
	stats.call_deferred("take_damage", 0)
	hp_changed.emit(100)
	stamina_changed.emit((stamina*100/max_stamina))
	print(stats.max_health_level)
	print(faction)
func take_damage(damage:int) -> void:
	stats.take_damage(damage)
	
func heal(damage:int) -> void:
	stats.take_damage(-damage)



func _input(event: InputEvent) -> void:
#Debug lines to test out the hp ui, remember to remove these lines and change the key actions for "1" and "2" once we have some real enemies !!!
		if event.is_action_pressed("debug_add_hp"):
			heal(10)
			stats.max_health_level+=1
			print (stats.max_health_level)
		if event.is_action_pressed("debug_deal_damage"):
			take_damage(10)

func get_input() -> Vector2:
	var direction = Input.get_vector("left", "right", "up", "down")
	return direction
	
func enter_idle():
	pass
func idle(delta:float):
	pass
func exit_idle():
	pass
#-----------------------------------------------------------------------------------------------------------------
func enter_moving():
	velocity = get_input()*speed

	dash_cooldown.start()

func lose_stamina(lost_stamina:float):
	stamina -= lost_stamina
	stamina_cooldown.start()
	stamina_changed.emit((stamina*100/max_stamina))
	
func _on_dash_time_timeout() -> void:
	state_machine._on_change_state("idle")
func _physics_process(delta: float) -> void:
	
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

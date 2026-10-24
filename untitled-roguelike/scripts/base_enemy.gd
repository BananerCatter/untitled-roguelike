extends CharacterBody2D

@onready var player: CharacterBody2D = get_parent().get_node("Player")
@export var sprite: AnimatedSprite2D
@export var max_speed: float
@export var speed: float
@export var acceleration: float
@export var dash_mult: float 
@export var hp: int 
@export var max_hp: int

@export var hitbox: CollisionShape2D


@export var dash_duration: Timer 
@export var dash_cooldown: Timer
@export var dash_brake: Timer
var can_dash:bool = true

@export var stamina: float 
@export var max_stamina: float 
@export var stamina_cooldown: Timer
@export var stamina_recovery: float

@export var enter_area: Area2D
@export var exit_area: Area2D

var direction: Vector2
var dash_direction: Vector2
var player_found: bool =false
var stop: bool = false
enum States {IDLE, MOVING, DASH, ATTACK}

var previous_state: States
var state:States = States.IDLE
#--------------------------------------------------------------
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
func enter_state(entered_state:States) -> void:
		match entered_state:
			States.IDLE:
				enter_idle()

			States.MOVING:
				enter_moving()

			States.DASH:
				enter_dash()
#--------------------------------------------------------------
#IDLE
func enter_idle():
	sprite.play("idle")
	direction=Vector2.ZERO
func idle(delta: float):
	speed = move_toward(speed, 0, acceleration*delta)
	velocity=speed*direction
	if previous_state == States.DASH:
		speed = move_toward(speed, max_speed, acceleration*delta*dash_mult)
		
		
	if player_found && dash_brake.is_stopped():
		change_state(States.MOVING)
func exit_idle():
	pass
#--------------------------------------------------------------	
#MOVING
func enter_moving():
	sprite.play("chase")
func moving(delta: float):
	direction = (player.global_position-global_position).normalized()
	if previous_state==States.DASH:
		change_state(States.IDLE)
		speed = move_toward(speed, max_speed, acceleration*delta)
	else:
		speed = move_toward(speed, max_speed, acceleration*delta)
	if can_dash && dash_cooldown.is_stopped():
		change_state(States.DASH)
	velocity=speed*direction
	if stop:
		change_state(States.IDLE)
	if !player_found:
		change_state(States.IDLE)
func exit_moving():
	pass
#--------------------------------------------------------------	
#DASHING
func enter_dash():
	dash_direction=direction
	sprite.play("dash")
	dash_duration.start()
func dash(delta: float):

	velocity=speed*dash_direction
	
	speed = move_toward(speed, max_speed*dash_mult, acceleration*delta*dash_mult*dash_mult)

	if dash_duration.is_stopped():
		change_state(States.IDLE)
func exit_dash():
	dash_brake.start()
	dash_cooldown.start()
	can_dash=false
#--------------------------------------------------------------
func _ready() -> void:
	change_state(States.IDLE,true)

func _physics_process(delta: float) -> void:
		match state:
			States.IDLE:
				idle(delta)

			States.MOVING:
				moving(delta)

			States.DASH:
				dash(delta)
		move_and_slide()

#--------------------------------------------------------------

func _on_exit_area_body_exited(body: Node2D) -> void:
	if body==player:
		player_found=false


func _on_enter_area_body_entered(body: Node2D) -> void:
	if body==player:
		player_found=true


func _on_enter_area_body_exited(body: Node2D) -> void:
	if body==player:
		can_dash=true


func _on_stop_area_body_entered(body: Node2D) -> void:
	if body == player:
		stop=true


func _on_stop_area_body_exited(body: Node2D) -> void:
	if body == player:
		stop=false
		player_found=true

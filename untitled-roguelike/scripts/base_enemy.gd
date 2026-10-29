extends CharacterBody2D

@export var stats: Stats

@onready var player: CharacterBody2D = get_parent().get_node("Player")
@export var sprite: AnimatedSprite2D
@export var max_speed: float
@export var speed: float
@export var acceleration: float
@export var dash_mult: float 


@export var hitbox_shape: Shape2D
var hitbox: Hitbox

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

@onready var damage_bar: ProgressBar = %ProgressBar


var direction: Vector2
var dash_direction: Vector2
var player_found: bool =false
var stop: bool = false
var can_attack: bool = false

func _ready() -> void:
	stats.health_changed.connect(damage_bar._get_value)
	stats.health_changed.emit(stats.health, stats.current_max_health)
	#add to state machine when done


func _physics_process(delta: float) -> void:
		if stats.health <=0:
			queue_free()
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


func _on_attack_range_body_entered(body: Node2D) -> void:
	if body == player:
		can_attack = true

func _on_attack_range_body_exited(body: Node2D) -> void:
	if body == player:
		can_attack = false

class_name HeldWeapon extends Node2D

@export var pivot_point: Marker2D
@export var hitbox_shape: Shape2D
@export var animation: AnimationPlayer
@export var sprite: Sprite2D
@export var rotation_speed: int 
@export var damage: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_rotation=0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
		
	

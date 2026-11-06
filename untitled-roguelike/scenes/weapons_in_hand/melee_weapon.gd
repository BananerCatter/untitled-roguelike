class_name HeldWeapon extends Node2D

@export var pivot_point: Marker2D
@export var hitbox: Hitbox
@export var animation: AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pivot_point.look_at(get_global_mouse_position())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("light_attack"):
		pass

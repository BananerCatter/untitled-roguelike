class_name HeldWeapon extends Node2D

@export var pivot_point: Marker2D
@export var hitbox_shape: Shape2D
@export var animation: AnimationPlayer
@export var sprite: Sprite2D
@export var rotation_speed: int 
@export var damage: int
@export var base_texture: Texture2D
@export var swing_texture: Texture2D
@export var animation_array: Array[String] =[]
var current_anim_index: int =0
var max_item_index: int 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for anim:String in animation.get_animation_list():
		if anim.begins_with("LightAttack"):
			animation_array.append(anim)
			max_item_index+=1

func on_light_attack():
	animation.play(animation_array[current_anim_index])
	current_anim_index +=1
	if current_anim_index >= max_item_index:
		current_anim_index =0


	
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name in animation_array:
		sprite.texture = base_texture
		await (get_tree().create_timer(0.5).timeout)
		if not animation.is_playing():
			current_anim_index=0
		


func _on_animation_player_animation_started(anim_name: StringName) -> void:
	if anim_name in animation_array:
		sprite.texture = swing_texture

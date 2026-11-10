class_name WeaponItem extends Item

@export var damage:int
@export var weapon_in_hand_scene: PackedScene
var held_weapon: PackedScene
func _init() -> void:
	item_type = TYPE.weapon_item
	call_deferred("init_hand")

func init_hand():
	held_weapon = weapon_in_hand_scene

	

	

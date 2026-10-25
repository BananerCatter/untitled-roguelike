class_name Hurtbox extends Area2D

@onready var owner_stats: Stats = owner.stats

func _ready() -> void:
	monitoring=false
	set_collision_layer_value(1,false)
	set_collision_mask_value(1,false)
	
	match owner_stats.faction:
		Stats.factions.PLAYER:
			set_collision_layer_value(2,true)
		Stats.factions.ENEMY:
			set_collision_layer_value(1,true)
	
func receive_hit(damage):
	owner_stats.take_damage(damage)

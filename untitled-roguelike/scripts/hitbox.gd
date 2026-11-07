class_name Hitbox extends Area2D
var attacker_stats: Stats
var hitbox_lifetime: float
var shape: Shape2D
var hitlog: Hitlog


func _init(_attacker_stats: Stats, _hitbox_lifetime: float, _shape: Shape2D, _weapon_damage: int, _hitlog:Hitlog) -> void:
	attacker_stats=_attacker_stats
	hitbox_lifetime=_hitbox_lifetime
	shape=_shape
	attacker_stats.current_damage+=_weapon_damage
	hitlog = _hitlog

func _ready():
	monitorable= false
	area_entered.connect(_on_area_entered)

	if hitbox_lifetime > 0.0:
		var new_timer = Timer.new()
		add_child(new_timer)
		new_timer.timeout.connect(queue_free)
		new_timer.call_deferred("start", hitbox_lifetime)
	if shape:
		var collision_shape = CollisionShape2D.new()
		collision_shape.shape = shape
		add_child(collision_shape)
		
	set_collision_layer_value(1,false)
	set_collision_mask_value(1,false)
	
	match attacker_stats.faction:
		Stats.factions.PLAYER:
			set_collision_mask_value(1,true)
		Stats.factions.ENEMY:
			set_collision_mask_value(2,true)
	
func _on_area_entered(area: Area2D):
	if not area.has_method("receive_hit"):
		return
	
	var hurbox_owner = area.owner
	if hitlog:
		if hitlog.has_hit(hurbox_owner):
			return
		else:
			hitlog.log_hit(hurbox_owner)
	
	
	area.receive_hit(attacker_stats.current_damage)

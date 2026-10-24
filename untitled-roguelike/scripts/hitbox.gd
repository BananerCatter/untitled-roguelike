class_name hitbox extends Area2D

# uncomment this when we have actual stats, for now just use an int for damage
# var attacker_stats: Stats
var attacker_damage: int
var hitbox_lifetime: float
var shape: Shape2D

func _init(_attacker_damage: int, _hitbox_lifetime: float, _shape: Shape2D) -> void:
	attacker_damage=_attacker_damage
	hitbox_lifetime=_hitbox_lifetime
	shape=_shape
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
	
func _on_area_entered(area: Area2D):
	pass

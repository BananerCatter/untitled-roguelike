class_name WeaponTrailHandler extends Node2D
@export var trail: Line2D
@export var trail_timer: Timer
@export var max_trail_size: int



@export var can_update_trail: bool


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_trail( point_position: Vector2)->void:
	if can_update_trail:
		if trail.points.size()>=max_trail_size:
			trail.remove_point(0)

		trail.add_point(to_local(point_position))
	else:
		trail.clear_points()

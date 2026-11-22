extends Node2D

signal room_revealed
signal room_entered(room: Node2D)

const DOOR_DETECTION_SCENE = preload("res://scenes/door_detection.tscn")
@export var room_width: int = 13
@export var room_height: int = 9

const TILE_SIZE: int = 32
var darkness_overlay: Polygon2D
var door_blockers: Array[StaticBody2D] = []
var door_collision_shapes: Array[CollisionShape2D] = []
var encounter_active: bool = false
var encounter_completed: bool = false

func _ready() -> void:
	for door in get_exits():
		var detection = DOOR_DETECTION_SCENE.instantiate()
		add_child(detection)
		
		detection.position = door.position - (door.position - Vector2(room_width * TILE_SIZE / 2.0, room_height * TILE_SIZE / 2.0)).normalized() * 32.0
		detection.player_entered.connect(_on_door_player_entered)
		
	darkness_overlay = Polygon2D.new()
	darkness_overlay.name = "DarknessOverlay"
	darkness_overlay.position = Vector2(16,16)
	darkness_overlay.polygon= PackedVector2Array([
		Vector2(0,0),
		Vector2(room_width * TILE_SIZE, 0),
		Vector2(room_width * TILE_SIZE, room_height * TILE_SIZE),
		Vector2(0, room_height * TILE_SIZE)
	]) 
	darkness_overlay.color = Color(0,0,0,0.85)
	darkness_overlay.z_index = 10
	add_child(darkness_overlay)

func _on_door_player_entered() -> void:
	if encounter_completed:
		return
	room_revealed.emit()
	room_entered.emit(self)
	print("Room revealed: ", name)

func get_exits() -> Array[Marker2D]:
	var doors: Array[Marker2D] = []
	
	for child in get_children():
		if child is Marker2D:
			doors.append(child)
			
	return doors
		

func get_door(direction: String) -> Marker2D:
	for door in get_exits():
		if door.name == direction:
			return door
	return null

func reveal() -> void:
	if darkness_overlay == null:
		return
	
	var tween = create_tween()
	tween.tween_property(darkness_overlay, "color:a", 0.0, 1.0)
	tween.tween_callback(darkness_overlay.queue_free)

func close_doors() -> void:
	for door in get_exits():
		var blocker = StaticBody2D.new()
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		var visual = ColorRect.new()
		visual.color = Color(1, 0, 0, 0.5)
		visual.size = Vector2(32, 32)
		visual.position = Vector2(-16, -16)
		visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
		blocker.add_child(visual)

		shape.size = Vector2(32, 32)
		collision.shape = shape

		blocker.add_child(collision)
		door_collision_shapes.append(collision)
		blocker.position = door.position

		add_child(blocker)
		door_blockers.append(blocker)

func start_encounter() -> void:
	if encounter_active or encounter_completed:
		return
	encounter_active = true
	call_deferred("close_doors")

func open_doors() -> void:
	if not encounter_active:
		return

	for collision in door_collision_shapes:
		collision.set_deferred("disabled", true)

	for blocker in door_blockers:
		blocker.queue_free()

	door_collision_shapes.clear()
	door_blockers.clear()

	encounter_active = false
	encounter_completed = true

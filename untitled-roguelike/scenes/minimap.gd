extends Control

const TILE_SIZE: int = 32
const MAP_PADDING : float = 12.0

var room_data: Dictionary = {}
var connection_data: Dictionary = {}

func _ready() -> void:
	custom_minimum_size = Vector2(320,320)

func set_dungeon_data(rooms: Dictionary, connections: Dictionary) -> void:
	room_data = rooms
	connection_data = connections
	queue_redraw()
	
func _draw() -> void:
	print("MINIMAP DRAW CALLED")
	if room_data.is_empty():
		return
	var map_bounds := Rect2()
	for cell in room_data:
		var room = room_data[cell]
		var room_rect = Rect2(
			room.global_position,
			Vector2(room.room_width, room.room_height) * TILE_SIZE
		)
		
		if map_bounds == Rect2():
			map_bounds = room_rect
		else:
			map_bounds = map_bounds.merge(room_rect)
	
	map_bounds = map_bounds.grow(TILE_SIZE)
	var available_size = size - Vector2(MAP_PADDING * 2, MAP_PADDING * 2)
	
	var scale_factor = min(
		available_size.x / map_bounds.size.x,
		available_size.y / map_bounds.size.y
	)
	
	var drawn_size = map_bounds.size * scale_factor
	var map_offset = (size - drawn_size) / 2.0
	
	for cell in connection_data:
		for neighbor_cell in connection_data[cell]:
			if cell >= neighbor_cell :
				continue
			
			if not room_data.has(cell) or not room_data.has(neighbor_cell):
				continue
			
			var room_a = room_data[cell]
			var room_b = room_data[neighbor_cell]
			
			var direction = neighbor_cell - cell
			
			var door_a_name = get_door_name(direction)
			var door_b_name = get_door_name(-direction)
			
			var door_a = room_a.get_door(door_a_name)
			var door_b = room_b.get_door(door_b_name)
			
			if door_a == null or door_b == null:
				continue
			
			var point_a = world_to_map(
				door_a.global_position, map_bounds, scale_factor, map_offset
			)
			
			var point_b = world_to_map(
				door_b.global_position, map_bounds, scale_factor, map_offset
			)
			draw_line(point_a, point_b, Color("#A0A9B8"), maxf(2.0, scale_factor * 5.0))
			
	for cell in room_data:
		var room = room_data[cell]
		
		var room_rect = Rect2(
			room.global_position,
			Vector2(room.room_width, room.room_height) * TILE_SIZE
		)
		
		var top_left = world_to_map(
			room_rect.position, map_bounds, scale_factor, map_offset
		)
		
		var drawn_rect = Rect2(
			top_left,
			room_rect.size * scale_factor
		)
		
		draw_rect(drawn_rect,Color("#52647A"), true)
		draw_rect(drawn_rect,Color("#C3D0DF"), false, 1.5)

func get_door_name(direction: Vector2i) -> String:
	match direction:
		Vector2i.RIGHT:
			return "EastH"
		Vector2i.LEFT:
			return "WestH"
		Vector2i.UP:
			return "NorthH"
		Vector2i.DOWN:
			return "SouthH"
		_:
			return ""

func world_to_map(
	world_position: Vector2,
	map_bounds:Rect2,
	scale_factor: float,
	map_offset: Vector2
) -> Vector2:
	return (world_position - map_bounds.position) * scale_factor + map_offset

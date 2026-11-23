extends Control

const TILE_SIZE: int = 32
const MAP_PADDING : float = 12.0
const VIEW_SIZE: Vector2 = Vector2(1200,1200)

@export var background_color: Color=("#1c1c1c")
@export_range(0.0,1.0) var background_opacity: float = 0.80
var room_data: Dictionary = {}
var connection_data: Dictionary = {}

var player: Node2D
var expanded: bool = false

var map_zoom: float = 1.0
var map_pan: Vector2 = Vector2.ZERO

var dragging: bool = false

var last_draw_offset: Vector2 = Vector2.ZERO
var last_fit_scale: float = 1.0

enum RoomVisibility {
	HIDDEN,
	UNDISCOVERED,
	DISCOVERED
}

signal room_discovered(cell: Vector2i)

var room_visibility: Dictionary = {}

func _ready() -> void:
	custom_minimum_size = Vector2(320,320)
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func set_dungeon_data(rooms: Dictionary, connections: Dictionary, player_ref: Node2D) -> void:
	room_data = rooms
	connection_data = connections
	room_visibility.clear()
	for cell in room_data:
		room_visibility[cell] = RoomVisibility.HIDDEN
	player = player_ref
	queue_redraw()

func _draw() -> void:
	var bg_color = background_color
	bg_color.a = background_opacity
	draw_rect(Rect2(Vector2.ZERO,size), bg_color, true)
	if room_data.is_empty():
		return
	if player == null:
		return
	
	
	var map_bounds : Rect2
	
	if expanded:
		map_bounds = get_map_bounds()
	else:
		map_bounds = Rect2(
			player.global_position - VIEW_SIZE / 2.0,
			VIEW_SIZE
		)

	var available_size = size - Vector2(MAP_PADDING * 2, MAP_PADDING * 2)

	var fit_scale = min(
		available_size.x / map_bounds.size.x,
		available_size.y / map_bounds.size.y
	)
	last_fit_scale = fit_scale
	var scale_factor = fit_scale
	
	if expanded:
		scale_factor *= map_zoom
	
	var drawn_size = map_bounds.size * scale_factor
	var map_offset = (size - drawn_size) / 2.0
	
	if expanded:
		map_offset += map_pan
	
	last_draw_offset = map_offset

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
		
		var visibility = room_visibility[cell]
		
		if visibility == RoomVisibility.HIDDEN:
			continue
			
		var is_current_room = visibility == RoomVisibility.DISCOVERED and room_rect.has_point(player.global_position)
		
		var room_color: Color
		var border_color: Color
		
		match visibility:
			RoomVisibility.UNDISCOVERED:
				room_color = Color("#252B35")
				border_color = Color("#596575")
			
			RoomVisibility.DISCOVERED:
				room_color = Color("#718EAD") if is_current_room else Color("#52647A")
				border_color = Color("#FFFFFF") if is_current_room else Color("#C3D0DF")
		
		draw_rect(drawn_rect, room_color, true)
		draw_rect(drawn_rect, border_color, false, 1.5)

	for cell in connection_data:
		for neighbor_cell in connection_data[cell]:
			if cell >= neighbor_cell :
				continue
			
			if not room_data.has(cell) or not room_data.has(neighbor_cell):
				continue
			
			if room_visibility[cell] != RoomVisibility.DISCOVERED and room_visibility[neighbor_cell] != RoomVisibility.DISCOVERED:
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
			
			var point_a_world: Vector2
			var point_b_world: Vector2
			
			match door_a_name:
				"EastH":
					point_a_world = Vector2(
						room_a.global_position.x + room_a.room_width * TILE_SIZE,
						door_a.global_position.y
					)
					point_b_world = Vector2(
						room_b.global_position.x,
						door_b.global_position.y
					)
				"WestH":
					point_a_world = Vector2(
						room_a.global_position.x,
						door_b.global_position.y
					)
					point_b_world = Vector2(
						room_b.global_position.x + room_b.room_width * TILE_SIZE,
						door_b.global_position.y
					)
				"SouthH":
					point_a_world = Vector2(
						door_a.global_position.x,
						room_a.global_position.y + room_a.room_height * TILE_SIZE
					)
					point_b_world = Vector2(
						door_b.global_position.x,
						room_b.global_position.y
					)
				"NorthH":
					point_a_world = Vector2(
						door_a.global_position.x,
						room_a.global_position.y
					)
					point_b_world = Vector2(
						door_b.global_position.x,
						room_b.global_position.y + room_b.room_height * TILE_SIZE
					)
			
			var point_a = world_to_map(
				point_a_world, map_bounds, scale_factor, map_offset
			)
			
			var point_b = world_to_map(
				point_b_world, map_bounds, scale_factor, map_offset
			)
			
			draw_line(point_a,point_b,Color("#A0A9B8"), maxf(3.0, scale_factor * 5.0))

	var player_position = world_to_map(
		player.global_position,
		map_bounds,
		scale_factor,
		map_offset
	)
	
	var facing_direction: Vector2= player.facing_direction.normalized()
	var perpendicular := Vector2(-facing_direction.y, facing_direction.x)
	
	var triangle:= PackedVector2Array([
		player_position,
		player_position + facing_direction * 12.0 + perpendicular * 6.0,
		player_position + facing_direction * 12.0 - perpendicular * 6.0
	])
	
	draw_colored_polygon(triangle, Color("#A0C8FF"))
	draw_circle(player_position, 4.0, Color("#FFFFFF"))
	
	draw_rect(Rect2(Vector2(1.0,1.0), size-Vector2(2.0,2.0)), Color("#c9c9c9"), false, 2.0)
	
func _process(_delta: float) -> void:
	update_room_visibility()
	queue_redraw()

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

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo and event.keycode == KEY_M:
			toggle_expanded()
			return
	if not expanded:
		return
	
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				if event.pressed:
					zoom_map(1.15, event.position)
			
			MOUSE_BUTTON_WHEEL_DOWN:
				if event.pressed:
					zoom_map(1.0 / 1.15, event.position)
				
			MOUSE_BUTTON_LEFT:
				dragging = event.pressed
	if event is InputEventMouseMotion and dragging:
		map_pan += event.relative
		queue_redraw()

func toggle_expanded() -> void:
	expanded = not expanded
	if expanded:
		map_zoom = 0.7
		map_pan = Vector2.ZERO
		dragging = false
		
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		position = Vector2.ZERO
	else:
		set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
		size = Vector2(320,320)
		position.x -= 8
	queue_redraw()

func zoom_map(factor: float, mouse_position: Vector2) -> void:
	var old_zoom = map_zoom
	map_zoom = clampf(map_zoom * factor, 0.5, 5.0)
	
	var actual_factor = map_zoom / old_zoom
	
	var target_offset = mouse_position - (
		mouse_position - last_draw_offset
	) * actual_factor
	
	var new_drawn_size = get_map_bounds().size * last_fit_scale * map_zoom
	var centered_offset = (size - new_drawn_size) / 2.0
	
	map_pan = target_offset - centered_offset
	queue_redraw()

func get_map_bounds() -> Rect2:
	var first_room = room_data.values()[0]
	
	var bounds = Rect2(
		first_room.global_position,
		Vector2(first_room.room_width, first_room.room_height) * TILE_SIZE
	)
	
	for room in room_data.values():
		var room_rect = Rect2(
			room.global_position,
			Vector2(room.room_width, room.room_height) * TILE_SIZE
		)
		bounds = bounds.merge(room_rect)
	
	bounds = bounds.grow(64)
	bounds.size.y += TILE_SIZE * 2
	
	return bounds

func update_room_visibility() -> void:
	if player == null:
		return
	for cell in room_data:
		var room = room_data[cell]
		
		var room_rect = Rect2(
			room.global_position,
			Vector2(room.room_width, room.room_height) * TILE_SIZE
		)
		
		if room_rect.has_point(player.global_position):
			if room_visibility[cell] != RoomVisibility.DISCOVERED:
				room_visibility[cell] = RoomVisibility.DISCOVERED
				room_discovered.emit(cell)
			
			for neighbor_cell in connection_data[cell]:
				if room_visibility[neighbor_cell] == RoomVisibility.HIDDEN:
					room_visibility[neighbor_cell] = RoomVisibility.UNDISCOVERED

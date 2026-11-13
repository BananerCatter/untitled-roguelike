extends Node2D

@export var starting_room: PackedScene
@export var basic_room: PackedScene

@export var grid_width: int = 9
@export var grid_height: int = 9

@export var start_cell: Vector2i = Vector2i(2,8)
@export var end_cell: Vector2i = Vector2i(6,1)

@onready var generated_hallways: TileMapLayer = $GeneratedHallways

const empty: int = 0
const pathI: int = 1
const start: int = 2
const end: int = 3
const branchI:int = 4
const TILE_SIZE: int = 32
const MAX_ROOM_DISPLACEMENT : int = 8
const MIN_DIAGONAL_OFFSET : int = 3

const HALLWAY_SOURCE_ID: int = 0
const HALLWAY_FLOOR: Vector2i = Vector2i(3,1)
const HALLWAY_WALL : Vector2i = Vector2i(8,3)
var grid : Array = []

func _ready() -> void:
	room_connections.clear()
	grid_create()
	
	if not coords_check(start_cell):
		push_error("Start cell outside the grid broski")
		return 
		
	if not coords_check(end_cell):
		push_error("End cell outside the grid broski")
		return
	
	if start_cell==end_cell :
		push_error("Start and end cell are in the same place bro bro brooo")
		return 
	
	set_start_and_end()
	
	var generated_path = generate_path()
	for cell in generated_path:
		if cell!=start_cell and cell!=end_cell:
			grid[cell.y][cell.x]= pathI
	
	for i in range (generated_path.size()-1):
		connect_rooms(generated_path[i], generated_path[i+1])

	var branch_cells: Array[Vector2i]= generate_branches(generated_path)
	grid_print()
	generate_rooms()
	debug_room_collision_data(spawned_rooms[start_cell])
	print("Start cell: ", start_cell)
	print("start room exists: ", spawned_rooms.has(start_cell))
	print("Start room : ", spawned_rooms.get(start_cell))
	position_rooms()
	retry_failed_room_placements()
	fix_failed_connections()
	
	var failed_connections = test_one_hallway()
	print("\nTotal failed connections: ", failed_connections.size())
	print("Failed connection data: ", failed_connections)
	
func grid_create() -> void:
	grid.clear()
	
	for y in range (grid_height):
		var row: Array=[]
		
		for x in range (grid_width):
			row.append(0)
			
		grid.append(row)
		
	print("Grid height : ", grid.size())
	print("Row width : ", grid[0].size())

func set_start_and_end() -> void:
	grid[start_cell.y][start_cell.x]= start
	grid[end_cell.y][end_cell.x]= end

func grid_print() -> void:
	for y in range (grid_height):
		var line: String =""
		for x in range (grid_width):
			match grid[y][x]:
				empty :
					line += "."
				start :
					line += "S"
				end :
					line += "E"
				pathI :
					line += "#"
				branchI:
					line +="*"
					
		print (line)

func coords_check(cell: Vector2i) -> bool:
	if (cell.x >= 0 and cell.x <grid_width and
		cell.y >= 0 and cell.y <grid_height):
		return true
	else: 
		return false

func cell_check(cell: Vector2i) -> bool:
	if coords_check(cell) == true:
		if grid[cell.y][cell.x] == empty:
			return true
	return false

func get_cell_neighbors(cell: Vector2i) -> Array[Vector2i]:
	var neighbors : Array[Vector2i] =[]
	var directions : Array[Vector2i] = [
		Vector2i(1,0),
		Vector2i(-1,0),
		Vector2i(0,1),
		Vector2i(0,-1)
	]
	
	for direction in directions:
		var neighbor=cell+direction
		if cell_check(neighbor) or neighbor== end_cell:
			neighbors.append(neighbor)
	
	return neighbors

func distance_to_end(cell: Vector2i) -> int:
	return abs(cell.x-end_cell.x) + abs(cell.y-end_cell.y)

@export_range(0,10) var min_turns : int= 5
@export_range(0,10) var max_turns : int= 7
@export_range(0,100) var turn_chance : int = 25
var steps_since_turn: int = 0 

@export var auto_set_turns: bool = true
@export var steps_between_turns: int = 3

@export_range(1,5) var branch_rooms: int = 3
@export_range(1,5) var branch_length: int = 3
@export_range(1,5) var min_branch_distance: int = 1

func calculate_max_turns() -> int:
	var distance: int = distance_to_end(start_cell)
	return int(distance / steps_between_turns)

func generate_path() -> Array[Vector2i]:
	if auto_set_turns :
		max_turns=calculate_max_turns()
		min_turns=max_turns/2 + 1
		
	var turns_used: int = 0
	var last_dir : Vector2i = Vector2i.ZERO
	
	var path: Array[Vector2i]= []
	var tried_moves: Dictionary = {}
	path.append(start_cell)
	var current= start_cell
	
	while current!=end_cell:
		last_dir = Vector2i.ZERO
		if path.size()>=2:
			last_dir= path[path.size()-1] - path[path.size()-2]
		
		if not tried_moves.has(current):
			tried_moves[current]=[]
			
		var valid_neighbors: Array[Vector2i]= []
		
		for neighbor in get_cell_neighbors(current):
			if not path.has(neighbor) and not tried_moves[current].has(neighbor):
				valid_neighbors.append(neighbor)
				
		var best_moves: Array[Vector2i] = []
		var alternate_moves: Array[Vector2i]= []
		
		var best_distance: int = 99999
		
		for neighbor in valid_neighbors:
			var distance=distance_to_end(neighbor)
			if distance < best_distance:
				best_distance=distance
		
		for neighbor in valid_neighbors:
			var move_dir: Vector2i= neighbor - current 
			var distance: int = distance_to_end(neighbor)
			
			if last_dir!=Vector2i.ZERO and move_dir == last_dir and distance == best_distance:
				best_moves.append(neighbor)
			elif distance == best_distance and last_dir == Vector2i.ZERO:
				best_moves.append(neighbor)
			elif distance<=distance_to_end(current):
				alternate_moves.append(neighbor)
		
		if (best_moves.is_empty() and not valid_neighbors.is_empty()):
			for neighbor in valid_neighbors:
				if distance_to_end(neighbor) == best_distance:
					best_moves.append(neighbor)
					alternate_moves.erase(neighbor)
		
		if (valid_neighbors.is_empty() and path.size()==1):
			return []
		elif (valid_neighbors.is_empty() and path.size()>1):
			path.pop_back()
			current=path.back()
		else:
			
			var chosen_neighbor: Vector2i
			
			if not alternate_moves.is_empty() and turns_used <max_turns:
				if turns_used< min_turns and steps_since_turn>=steps_between_turns:
					chosen_neighbor=alternate_moves.pick_random()
					turns_used+=1
					steps_since_turn=0
					print("Turn ", turns_used, " at ", current, " -> ", chosen_neighbor)
				elif steps_since_turn>=steps_between_turns and randi_range(1,100) <= turn_chance:
					chosen_neighbor = alternate_moves.pick_random()
					turns_used+=1
					steps_since_turn=0
					print("Turn ", turns_used, " at ", current, " -> ", chosen_neighbor)
				else :
					chosen_neighbor= best_moves.pick_random()
			else :
				chosen_neighbor = best_moves.pick_random()
			
			tried_moves[current].append(chosen_neighbor)
			path.append(chosen_neighbor)
			current= chosen_neighbor
			steps_since_turn+=1
	
	print("The Path:", path)
	return path

func generate_branches(generated_path: Array[Vector2i]) -> Array[Vector2i] :
	var branch_cells: Array[Vector2i] = []
	var branch_origins: Array[Vector2i] = []
	var possible_starts = generated_path.duplicate()
	possible_starts.shuffle()
	
	var branches_made: int = 0
	
	for branch_start in possible_starts:
		if branches_made >= branch_rooms:
			break;
		if branch_start==start_cell or branch_start==end_cell:
			continue;
			
		var too_close: bool = false
		
		for branch_cell in branch_cells:
			var distance = abs(branch_start.x-branch_cell.x) + abs(branch_start.y-branch_cell.y)
			if distance <= min_branch_distance:
				too_close=true
				break;
		if not too_close:
			for branch in branch_origins:
				var distance = abs(branch_start.x-branch.x) + abs(branch_start.y-branch.y)
				if distance <= min_branch_distance:
					too_close=true
					break;
		if too_close:
			continue
		var current_branch: Array[Vector2i] = []
		var current_cell: Vector2i = branch_start
		
		for i in range(branch_length):
			var neighbors=get_cell_neighbors(current_cell)
			neighbors.shuffle()
			
			var next_cell: Vector2i = Vector2i(-1,-1)

			for neighbor in neighbors:
				if cell_check(neighbor) and neighbor!=end_cell:
					next_cell=neighbor
					break;
			
			if next_cell== Vector2i(-1,-1):
				break;
			
			grid[next_cell.y][next_cell.x]= branchI
			current_branch.append(next_cell)
			branch_cells.append(next_cell)
			
			current_cell=next_cell
		if not current_branch.is_empty():
			connect_rooms(branch_start,current_branch[0])
			
			for i in range(current_branch.size()-1):
				connect_rooms(current_branch[i],current_branch[i+1])
			
			branches_made+=1
			branch_origins.append(branch_start)
			print("Branch from ", branch_start, ": ", current_branch)
	return branch_cells

func get_first_marker(room: Vector2i, room2: Vector2i) -> String:
	
	var direction = room2 - room
	match direction:
		Vector2i(1,0):
			return "EastH"
		Vector2i(-1,0):
			return "WestH"
		Vector2i(0,1):
			return "SouthH"
		Vector2i(0,-1): 
			return "NorthH"
		_:
			push_error("Not Valid direction") 
			return ""
	
func get_opposite_marker(direction: String) -> String:
	match direction:
		"EastH":
			return "WestH"
		"WestH":
			return "EastH"
		"NorthH":
			return "SouthH"
		"SouthH": 
			return "NorthH"
		_:
			push_error("Not Valid direction") 
			return ""

func is_room(cell:Vector2i) -> bool:
	if not coords_check(cell):
		return false
	return grid[cell.y][cell.x] != empty

func get_required_door(cell: Vector2i) -> String:
	var required_doors=""
	if not room_connections.has(cell):
		return required_doors
	var directions: Array[Vector2i] = [
		Vector2i(0,-1),
		Vector2i(1,0),
		Vector2i(0,1),
		Vector2i(-1,0)
	]
	for direction in directions:
		var neighbor = cell + direction
		if room_connections[cell].has(neighbor):
			match direction:
				Vector2i(1,0):
					required_doors+="E"
				Vector2i(-1,0):
					required_doors+="W"
				Vector2i(0,1):
					required_doors+="S"
				Vector2i(0,-1): 
					required_doors+="N"
				_:
					push_error("Connected rooms aren't next to each other") 
	return required_doors

var room_connections: Dictionary = {}
var spawned_rooms: Dictionary = {}
var spawned_hallways: Array= []
var positioned_rooms: Dictionary = {}
var room_parents: Dictionary = {}

func connect_rooms(a: Vector2i, b: Vector2i) -> void:
	if not room_connections.has(a):
		room_connections[a]=[]
	if not room_connections.has(b):
		room_connections[b]=[]
	room_connections[a].append(b)
	room_connections[b].append(a)

func get_room_path(size: String, doors: String, variation: int) -> String:
	return "res://scenes/rooms/" + size + "/" + doors + "/room_" + size + "_" + doors + "_" + str(variation)  + ".tscn"

func get_hallway_path(type: String, hallway_name: String) -> String :
	return "res://scenes/hallways/" + type + "/" + hallway_name + ".tscn"

func load_room(size: String, doors: String, variation: int) -> PackedScene:
	var path=get_room_path(size,doors,variation)
	var room_scene = load(path) as PackedScene
	
	if room_scene == null:
		push_error("invalid path")
		return null
	return room_scene

func load_hallway(type: String, hallway_name: String) -> PackedScene:
	var Hpath= get_hallway_path(type,hallway_name)
	var hallway_scene = load(Hpath) as PackedScene
	
	if hallway_scene == null:
		push_error("invalid hallway path")
		return null
	return hallway_scene

func generate_rooms() -> void:
	for y in range(grid_height):
		for x in range(grid_width):
			var cell=Vector2i(x,y)
			if not is_room(cell):
				continue
			var doors = get_required_door(cell)
			var room_scene = load_room("small", doors, 1)
			if room_scene == null:
				continue
			var room_instance=room_scene.instantiate()
			add_child(room_instance)
			spawned_rooms[cell]=room_instance

func position_neighbor(current_room, neighbor_room, current_cell, neighbor_cell, extra_offset: Vector2i = Vector2i.ZERO) -> bool:
	var direction = neighbor_cell - current_cell
	var movement = Vector2(direction) * TILE_SIZE
	var first_marker = get_first_marker(current_cell,neighbor_cell)
	var second_marker = get_opposite_marker(first_marker)

	var first_door = current_room.get_door(first_marker)
	var second_door = neighbor_room.get_door(second_marker)
	if first_door == null or second_door == null:
		push_error("marker did NOT load")
		return false

	var target_pos = first_door.global_position + movement

	match first_marker:
		"EastH":
			neighbor_room.global_position.x= current_room.global_position.x + current_room.room_width * 32
			neighbor_room.global_position.y+= target_pos.y - second_door.global_position.y
		"WestH":
			neighbor_room.global_position.x= current_room.global_position.x - neighbor_room.room_width * 32
			neighbor_room.global_position.y+= target_pos.y - second_door.global_position.y
		"NorthH":
			neighbor_room.global_position.y= current_room.global_position.y - neighbor_room.room_height * 32
			neighbor_room.global_position.x+= target_pos.x - second_door.global_position.x
		"SouthH":
			neighbor_room.global_position.y= current_room.global_position.y + current_room.room_height * 32
			neighbor_room.global_position.x+= target_pos.x - second_door.global_position.x
		_:
			push_error("invalid marker")
			return false

	var base_position = neighbor_room.global_position + Vector2(extra_offset) * TILE_SIZE
	var axis_direction: int
	match first_marker:
		"EastH":
			axis_direction = 1
		"WestH":
			axis_direction = -1
		"NorthH":
			axis_direction = -1
		"SouthH":
			axis_direction = 1

	for radius in range(MAX_ROOM_DISPLACEMENT + 1):
		var offsets: Array[Vector2i] = []

		for y in range(-radius, radius + 1):
			var horizontal_distance= radius - abs(y)

			if horizontal_distance==0:
				offsets.append(Vector2i(0, y))
			else:
				offsets.append(Vector2i(horizontal_distance, y))
				offsets.append(Vector2i(-horizontal_distance, y))

		var perpendicular_offsets: Array[Vector2i] = []
		var forward_offsets: Array[Vector2i] = []
		var backward_offsets: Array[Vector2i] = []

		for offset in offsets:
			var axis_offset: int

			if first_marker== "EastH" or first_marker == "WestH":
				axis_offset= offset.x
			else:
				axis_offset= offset.y

			if axis_offset == 0:
				perpendicular_offsets.append(offset)
			elif axis_offset * axis_direction > 0:
				forward_offsets.append(offset)
			else:
				backward_offsets.append(offset)

		var ordered_offsets: Array[Vector2i] = []
		ordered_offsets.append_array(perpendicular_offsets)
		ordered_offsets.append_array(forward_offsets)
		ordered_offsets.append_array(backward_offsets)

		for offset in ordered_offsets:
			var perpendicular_offset: int

			if first_marker == "EastH" or first_marker == "WestH":
				perpendicular_offset= offset.y
			else:
				perpendicular_offset= offset.x

			if perpendicular_offset!= 0 and abs(perpendicular_offset) < MIN_DIAGONAL_OFFSET:
				continue

			neighbor_room.global_position = base_position + Vector2(offset) * TILE_SIZE
			if not room_collides_with_placed(neighbor_room, neighbor_cell):
				print(
					"Placed Room ", neighbor_cell,
					" relative to", current_cell,
					" with offset: ", offset
				)
				return true

	print("Failed to place room: ", neighbor_cell)
	print("Parent room: ", current_cell)
	print("Parent position: ", current_room.global_position)
	print("Last attemped position: ", neighbor_room.global_position)
	push_error("No valid position for room: " + str(neighbor_cell))
	return false
func position_rooms() -> void:
	positioned_rooms.clear()
	room_parents.clear()
	
	var to_visit: Array[Vector2i] = [start_cell]
	positioned_rooms[start_cell]= true
	while not to_visit.is_empty():
		var current_cell= to_visit.pop_front()
		var current_room = spawned_rooms[current_cell]
		var neighbors = room_connections[current_cell]
		for neighbor_cell in neighbors:
			if not positioned_rooms.has(neighbor_cell):
				var neighbor_room = spawned_rooms[neighbor_cell]
				room_parents[neighbor_cell]= current_cell
				if position_neighbor(current_room, neighbor_room, current_cell, neighbor_cell):
					positioned_rooms[neighbor_cell]= true
					to_visit.append(neighbor_cell)

func retry_failed_room_placements() -> void:
	var retry_offsets: Array[Vector2i] = []

	for distance in range(1, 4):
		retry_offsets.append(Vector2i(distance, 0))
		retry_offsets.append(Vector2i(-distance, 0))
		retry_offsets.append(Vector2i(0, distance))
		retry_offsets.append(Vector2i(0, -distance))

	var made_progress = true

	while made_progress:
		made_progress = false
		var positioned_cells = positioned_rooms.keys()

		for parent_cell in positioned_cells:
			for neighbor_cell in room_connections[parent_cell]:
				if positioned_rooms.has(neighbor_cell):
					continue

				if not room_parents.has(neighbor_cell):
					room_parents[neighbor_cell] = parent_cell

				if room_parents[neighbor_cell] != parent_cell:
					continue

				var parent_room = spawned_rooms[parent_cell]
				var neighbor_room = spawned_rooms[neighbor_cell]

				for offset in retry_offsets:
					neighbor_room.global_position = Vector2.ZERO

					if position_neighbor(
						parent_room,
						neighbor_room,
						parent_cell,
						neighbor_cell,
						offset
					):
						positioned_rooms[neighbor_cell] = true
						made_progress = true

						print(
							"Retry placed room ",
							neighbor_cell,
							" relative to ",
							parent_cell,
							" with extra offset: ",
							offset
						)

						break

func get_room_rect(room) -> Rect2 :
	var position = room.global_position
	var size = Vector2(room.room_width, room.room_height) * TILE_SIZE
	return Rect2(position, size)

func debug_room_collision_data(room) -> Array[PackedVector2Array]:
	var tilemap=room.get_node("tilemap")
	var polygons: Array[PackedVector2Array] = []
	for cell in tilemap.get_used_cells() :
		var tile_data = tilemap.get_cell_tile_data(cell)
		if tile_data == null:
			continue
		var polygon_count = tile_data.get_collision_polygons_count(0)
		for polygon_index in range(polygon_count):
			var points = tile_data.get_collision_polygon_points(0,polygon_index)
			var cell_position = tilemap.map_to_local(cell)
			var world_polygon : PackedVector2Array = []
			
			for point in points : 
				world_polygon.append(tilemap.to_global(cell_position+point))
			polygons.append(world_polygon)
	return polygons

func polygons_overlap(poly_a: PackedVector2Array, poly_b: PackedVector2Array) -> bool:
	var intersection = Geometry2D.intersect_polygons(poly_a, poly_b)
	return not intersection.is_empty()
	
func rooms_overlap(room_a,room_b) -> bool:
	var polygons_a = debug_room_collision_data(room_a)
	var polygons_b = debug_room_collision_data(room_b)
	
	for poly_a in polygons_a:
		for poly_b in polygons_b:
			if polygons_overlap(poly_a,poly_b):
				return true
	return false

func room_collides_with_placed(candidate_room, ignored_cell: Vector2i) -> bool:
	for cell in positioned_rooms:
		if cell== ignored_cell:
			continue
		var other_room = spawned_rooms[cell]
		if rooms_overlap(candidate_room,other_room):
			if ignored_cell == Vector2i(4,5):
				print(
					"Room (4,5) at ", candidate_room.global_position,
					" overlaps room", cell,
					" at ", other_room.global_position
				)
			return true
	return false

func test_one_hallway() -> Array[Dictionary]:
	var failed_connections: Array[Dictionary] = []

	for cell in room_connections:
		for neighbor_cell in room_connections[cell]:

			if cell >= neighbor_cell:
				continue

			if not positioned_rooms.has(cell) or not positioned_rooms.has(neighbor_cell):
				failed_connections.append({
					"a": cell,
					"b": neighbor_cell,
					"reason": "room_not_placed"
				})

				push_warning(
					"Connection " + str(cell) + " -> " + str(neighbor_cell)
					+ " skipped: one or both rooms were not placed."
				)
				continue

			var room_a = spawned_rooms[cell]
			var room_b = spawned_rooms[neighbor_cell]

			var door_a_name = get_first_marker(cell, neighbor_cell)
			var door_b_name = get_opposite_marker(door_a_name)

			var door_a = room_a.get_door(door_a_name)
			var door_b = room_b.get_door(door_b_name)
			

			var start = generated_hallways.local_to_map(
				generated_hallways.to_local(door_a.global_position)
			)

			var finish = generated_hallways.local_to_map(
				generated_hallways.to_local(door_b.global_position)
			)

			print("\nTesting connection: ", cell, " -> ", neighbor_cell)
			print("Start door: ", door_a_name)
			print("End door: ", door_b_name)

			var path = find_hallway_path(
				start,
				finish,
				door_a_name,
				door_b_name
			)
			
			if not path.is_empty() and path.size() > abs(start.x-finish.x) + abs(start.y-finish.y) + 12:
				print ("\n--- LONG PATH DIAGNOSTIC ---")
				print("Connection: ", cell, " -> ", neighbor_cell)
				print("Start door: ", get_first_marker(cell, neighbor_cell))
				print("End door: ", get_opposite_marker(get_first_marker(cell, neighbor_cell)))
				print("Room A position: ", room_a.global_position)
				print("Room B position: ", room_b.global_position)
				print("Door A position: ", door_a.global_position)
				print("Door B position: ", door_b.global_position)
				print("Start tile: ", start)
				print("Finish tile: ", finish)
				print("Path length: ", path.size())

			var distance = (
				abs(start.x - finish.x)
				+ abs(start.y - finish.y)
			)

			var max_path_length = distance + 12

			var failure_reason = ""

			if path.is_empty():
				failure_reason = "no_path_found"
			elif path.size() > max_path_length:
				failure_reason = "path_too_long"

			if failure_reason != "":
				failed_connections.append({
					"a": cell,
					"b": neighbor_cell,
					"door_a": door_a_name,
					"door_b": door_b_name,
					"start": start,
					"finish": finish,
					"path_length": path.size(),
					"max_path_length": max_path_length,
					"reason": failure_reason
				})

				push_warning(
					"Invalid hallway: " + str(cell) + " -> "
					+ str(neighbor_cell) + " | Reason: "
					+ failure_reason
				)

			print("Start: ", start, " Finish: ", finish)
			print("Path: ", path)
			print("Path length: ", path.size())
			print("Maximum allowed length: ", max_path_length)

	return failed_connections
				
func find_hallway_path(
	start_cell: Vector2i,
	end_cell: Vector2i,
	start_door: String,
	end_door: String
	) -> Array[Vector2i]:

	var solid_cells: Dictionary = {}
	var min_cell = start_cell
	var max_cell = start_cell

	for room_cell in positioned_rooms:
		var room = spawned_rooms[room_cell]
		var world_polygons = debug_room_collision_data(room)

		for world_polygon in world_polygons:
			if world_polygon.size() < 3:
				continue

			var hallway_polygon: PackedVector2Array = []

			for point in world_polygon:
				hallway_polygon.append(generated_hallways.to_local(point))

			var min_x = hallway_polygon[0].x
			var max_x = hallway_polygon[0].x
			var min_y = hallway_polygon[0].y
			var max_y = hallway_polygon[0].y

			for point in hallway_polygon:
				min_x = minf(min_x, point.x)
				max_x = maxf(max_x, point.x)
				min_y = minf(min_y, point.y)
				max_y = maxf(max_y, point.y)

			var min_tile = generated_hallways.local_to_map(Vector2(min_x, min_y))
			var max_tile = generated_hallways.local_to_map(Vector2(max_x, max_y))

			for y in range(min_tile.y, max_tile.y + 1):
				for x in range(min_tile.x, max_tile.x + 1):
					var hallway_cell = Vector2i(x, y)
					var tile_center = generated_hallways.map_to_local(hallway_cell)

					if polygon_intersects_tile(hallway_polygon, tile_center):
						solid_cells[hallway_cell] = true

					min_cell.x = mini(min_cell.x, hallway_cell.x)
					min_cell.y = mini(min_cell.y, hallway_cell.y)
					max_cell.x = maxi(max_cell.x, hallway_cell.x)
					max_cell.y = maxi(max_cell.y, hallway_cell.y)

	var Astar = AStarGrid2D.new()
	var margin = Vector2i(10, 10)

	Astar.region = Rect2i(
		min_cell - margin,
		max_cell - min_cell + margin * 2 + Vector2i.ONE
	)

	Astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	Astar.update()

	for cell in solid_cells:
		Astar.set_point_solid(cell, true)

	var door_directions = {
		"NorthH": Vector2i(0, -1),
		"SouthH": Vector2i(0, 1),
		"EastH": Vector2i(1, 0),
		"WestH": Vector2i(-1, 0)
	}

	var start_outside = start_cell + door_directions[start_door]
	var end_outside = end_cell + door_directions[end_door]

	Astar.set_point_solid(start_cell, false)
	Astar.set_point_solid(end_cell, false)
	Astar.set_point_solid(start_outside, false)
	Astar.set_point_solid(end_outside, false)

	var path = Astar.get_id_path(start_cell, end_cell)

	if path.is_empty():
		print("\nFAILED PATH")
		print("Start is blocked: ", solid_cells.has(start_cell))
		print("End is blocked: ", solid_cells.has(end_cell))
		print("Start outside is blocked: ", solid_cells.has(start_outside))
		print("End outside is blocked: ", solid_cells.has(end_outside))

		print("\n--- LOCAL OBSTACLE MAP ---")

		var debug_min_x = mini(start_cell.x, end_cell.x) - 5
		var debug_max_x = maxi(start_cell.x, end_cell.x) + 5
		var debug_min_y = mini(start_cell.y, end_cell.y) - 5
		var debug_max_y = maxi(start_cell.y, end_cell.y) + 5

		for y in range(debug_min_y, debug_max_y + 1):
			var line = ""

			for x in range(debug_min_x, debug_max_x + 1):
				var cell = Vector2i(x, y)

				if cell == start_cell:
					line += "S"
				elif cell == end_cell:
					line += "E"
				elif solid_cells.has(cell):
					line += "#"
				else:
					line += "."

			print(line)

	return path

func polygon_intersects_tile(polygon: PackedVector2Array, tile_center: Vector2) -> bool:
	var half_tile = Vector2(TILE_SIZE, TILE_SIZE) / 2.0

	var tile_polygon: PackedVector2Array = [
		tile_center+ Vector2(-half_tile.x, -half_tile.y),
		tile_center+ Vector2(half_tile.x, -half_tile.y),
		tile_center+ Vector2(half_tile.x, half_tile.y),
		tile_center+ Vector2(-half_tile.x, half_tile.y)
	]

	return not Geometry2D.intersect_polygons(polygon, tile_polygon).is_empty()


func get_room_descendants(parent_cell: Vector2i) -> Array[Vector2i]:
	var descendants: Array[Vector2i] = []
	var to_check: Array[Vector2i] = [parent_cell]

	while not to_check.is_empty():
		var current_cell= to_check.pop_front()

		for child_cell in room_parents:
			if room_parents[child_cell]== current_cell:
				descendants.append(child_cell)
				to_check.append(child_cell)

	return descendants


func room_group_collides(moving_cells: Array[Vector2i]) -> bool:
	for cell in moving_cells:
		var room = spawned_rooms[cell]

		for other_cell in positioned_rooms:
			if moving_cells.has(other_cell):
				continue

			var other_room = spawned_rooms[other_cell]

			if rooms_overlap(room, other_room):
				return true

	return false


func move_room_subtree(parent_cell: Vector2i, direction: Vector2i) -> bool:
	var moving_cells: Array[Vector2i] = [parent_cell]
	moving_cells.append_array(get_room_descendants(parent_cell))

	for cell in moving_cells:
		spawned_rooms[cell].global_position += Vector2(direction) * TILE_SIZE

	if room_group_collides(moving_cells):
		for cell in moving_cells:
			spawned_rooms[cell].global_position -= Vector2(direction) * TILE_SIZE

		return false

	return true


func try_fix_connection(cell: Vector2i, neighbor_cell: Vector2i) -> bool:
	var room_a = spawned_rooms[cell]
	var room_b = spawned_rooms[neighbor_cell]

	var door_a_name = get_first_marker(cell, neighbor_cell)
	var door_b_name = get_opposite_marker(door_a_name)

	var door_a = room_a.get_door(door_a_name)
	var door_b = room_b.get_door(door_b_name)

	var start = generated_hallways.local_to_map(
		generated_hallways.to_local(door_a.global_position)
	)

	var finish= generated_hallways.local_to_map(
		generated_hallways.to_local(door_b.global_position)
	)
	var distance = abs(start.x - finish.x) + abs(start.y - finish.y)
	var max_path_length = distance + 12
	var path = find_hallway_path(start, finish, door_a_name, door_b_name)

	if not path.is_empty() and path.size() <= max_path_length:
		return true

	var direction = neighbor_cell - cell
	var moving_cell = neighbor_cell
	var movement_direction = direction
	
	if room_parents.has(cell) and room_parents[cell] == neighbor_cell:
		moving_cell = cell
		movement_direction = -direction
	
	var moving_room = spawned_rooms[moving_cell]
	var moving_door
	var fixed_door
	
	if moving_cell == neighbor_cell:
		moving_door = room_b.get_door(door_b_name)
		fixed_door = room_a.get_door(door_a_name)
	else:
		moving_door = room_a.get_door(door_a_name)
		fixed_door = room_b.get_door(door_b_name)
		
	var alignment_direction = Vector2i.ZERO
	var alignment_difference: float
	
	if door_a_name == "EastH" or door_a_name == "WestH":
		alignment_difference = fixed_door.global_position.y - moving_door.global_position.y
		alignment_direction = Vector2i(0, signi(alignment_difference))
	else:
		alignment_difference = fixed_door.global_position.x - moving_door.global_position.x
		alignment_direction = Vector2i(signi(alignment_difference), 0)
	
	var alignment_steps = min(
		roundi(abs(alignment_difference) / TILE_SIZE),
		MAX_ROOM_DISPLACEMENT
	)
	
	var perpendicular_directions: Array[Vector2i] = []
	
	if alignment_direction != Vector2i.ZERO:
		perpendicular_directions.append(alignment_direction)
		perpendicular_directions.append(-alignment_direction)
	else:
		perpendicular_directions.append(Vector2i.ZERO)
	
	for perpendicular_direction in perpendicular_directions:
		var moves_made: Array[Vector2i]= []
		var perpendicular_steps = alignment_steps
		
		if perpendicular_direction == -alignment_direction and alignment_direction != Vector2i.ZERO:
			perpendicular_steps = MAX_ROOM_DISPLACEMENT
		
		for attempt in range(perpendicular_steps):
			if not move_room_subtree(moving_cell, perpendicular_direction):
				print("PERPENDICULAR MOVE BLOCKED: ", perpendicular_direction)
				break
			
			moves_made.append(perpendicular_direction)

			door_a = room_a.get_door(door_a_name)
			door_b = room_b.get_door(door_b_name)

			start = generated_hallways.local_to_map(
				generated_hallways.to_local(door_a.global_position)
			)
			finish = generated_hallways.local_to_map(
				generated_hallways.to_local(door_b.global_position)
			)

			distance = abs(start.x - finish.x) + abs(start.y - finish.y)
			max_path_length = distance + 12
			path = find_hallway_path(start, finish, door_a_name, door_b_name)

			if not path.is_empty() and path.size() <= max_path_length:
				print("Fixed connection: ", cell, " -> ", neighbor_cell)
				return true

		for attempt in range(MAX_ROOM_DISPLACEMENT):
			if not move_room_subtree(moving_cell, movement_direction):
				print("CONNECTION MOVE BLOCKED: ", movement_direction)
				break

			moves_made.append(movement_direction)

			door_a = room_a.get_door(door_a_name)
			door_b = room_b.get_door(door_b_name)

			start = generated_hallways.local_to_map(
				generated_hallways.to_local(door_a.global_position)
			)
			finish = generated_hallways.local_to_map(
				generated_hallways.to_local(door_b.global_position)
			)

			distance = abs(start.x - finish.x) + abs(start.y - finish.y)
			max_path_length = distance + 12
			path = find_hallway_path(start, finish, door_a_name, door_b_name)

			if not path.is_empty() and path.size() <= max_path_length:
				print("Fixed connection: ", cell, " -> ", neighbor_cell)
				return true

		for i in range(moves_made.size() - 1, -1, -1):
			move_room_subtree(moving_cell, -moves_made[i])

	return false


func fix_failed_connections() -> void:
	for cell in room_connections:
		for neighbor_cell in room_connections[cell]:
			if cell >= neighbor_cell:
				continue

			if not positioned_rooms.has(cell) or not positioned_rooms.has(neighbor_cell):
				continue

			if not try_fix_connection(cell, neighbor_cell):
				push_warning(
					"Could not fix connection: "
					+ str(cell) + " -> " + str(neighbor_cell)
				)

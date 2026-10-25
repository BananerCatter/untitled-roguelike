extends Node2D

@export var starting_room: PackedScene
@export var basic_room: PackedScene

@export var grid_width: int = 9
@export var grid_height: int = 9

@export var start_cell: Vector2i = Vector2i(2,8)
@export var end_cell: Vector2i = Vector2i(6,1)

const empty = 0
const pathI = 1
const start = 2
const end = 3

var grid : Array = []

func _ready() -> void:
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
	
	grid_print()
	
	var firstRoom = starting_room.instantiate()
	add_child(firstRoom)
	
	var secondRoom = basic_room.instantiate()
	add_child(secondRoom)
	
	var first_door=firstRoom.get_door("EastH")
	var second_door=secondRoom.get_door("WestH")
	
	secondRoom.position.x = firstRoom.position.x + 416
	secondRoom.position.y = first_door.global_position.y -second_door.global_position.y
	
	print(max_turns)

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

func calculate_max_turns() -> int:
	var distance: int = distance_to_end(start_cell)
	return int(distance / steps_between_turns)

func generate_path() -> Array[Vector2i]:
	if auto_set_turns :
		max_turns=calculate_max_turns()
		min_turns=max_turns/2
		
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

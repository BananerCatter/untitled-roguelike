extends Node2D


# Called when the node enters the scene tree for the first time.
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
	

class_name StatusHandler extends Node

var status_dict: Dictionary[String,StatusEffect] ={}
@export var character: Node2D

func add_status_effect(status:StatusEffect) ->void:
	check_status(status)
	

func remove_status_effect(status:StatusEffect) ->void:
		status_dict.erase(status.status_effect_name.to_lower())



func check_status(status:StatusEffect) -> void:
	var status_name:String = status.status_effect_name.to_lower()
	if status_dict.has(status_name):
		if status.tier >= status_dict[status_name].tier:
			status_dict[status_name] = status
		
func _run_status_function(function_name:String, function_argument:float):
	if character.stats:  
		character.stats.call_deffered(function_name, function_argument)
		
func _physics_process(delta: float) -> void:
	for key:String in status_dict:
		status_dict[key].update(delta)

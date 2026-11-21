class_name StatusHandler extends Node
signal add_icon(status:StatusEffect)
signal remove_icon(status:StatusEffect)

var status_dict: Dictionary[String,StatusEffect] ={}

@export var character: Node2D

func _ready() -> void:
	if character.stats:
		character.stats._add_status_effect.connect(add_status_effect.call_deferred)
	

func add_status_effect(status:StatusEffect) ->void:

	if status:

		check_status(status)
		add_icon.emit(status)
		status._on_apply.connect(_run_status_function)
		status._on_tick.connect(_run_status_function)
		status._on_remove.connect(_run_status_function)
		status.remove.connect(remove_status_effect)

func remove_status_effect(status:StatusEffect) ->void:
	if status:
		status.queue_free()
		status_dict.erase(status.status_effect_data.status_effect_name.to_lower())
		remove_icon.emit(status)


func check_status(status:StatusEffect) -> void:
	if status:
		var status_name:String = status.status_effect_data.status_effect_name.to_lower()
		if status_dict.has(status_name):
			if status.tier >= status_dict[status_name].tier:
				status_dict[status_name].queue_free()
				status_dict[status_name] = status

				add_child(status_dict[status_name])
				status_dict[status_name].apply_status()



		else:
			status_dict[status_name] = status
			add_child(status_dict[status_name])
			status_dict[status_name].apply_status()

		
func _run_status_function(function_name:String, function_argument:float):
	if character.stats:  
		if function_argument and function_name:
			character.stats.call(function_name, function_argument)
		
		
func _physics_process(delta: float) -> void:
	for child:StatusEffect in get_children():
		child.physics_update(delta)

class_name ConsumableItem extends Item
@export var _stats_function: String
@export var _stats_function_args: Array
var stats_function:String 
var stats_function_args: Array



func _init() -> void:
	item_type = TYPE.consumable_item
	call_deferred("init_on_use")
	

func init_on_use() -> void:
	stats_function = _stats_function
	stats_function_args = _stats_function_args
	

func _on_use() -> Dictionary[String,Array]:
	if stats_function != '':
		return {stats_function:stats_function_args}
	return {"pass":[]}
	

class_name StatusEffect extends Node
@export var status_effect_data: StatusEffectData

var timer:Timer =Timer.new()
var tick_timer:Timer =Timer.new()

signal _on_apply(function:String, argument:Array)
signal _on_remove(function:String, argument:Array)
signal _on_tick(function:String, argument:Array)
signal remove(status:StatusEffect)



func apply_status() -> void:
	pass
	
	
func remove_status() -> void:
	remove.emit(self)
	
func trigger_status() -> void:
	pass

func physics_update(delta:float) -> void:
	pass

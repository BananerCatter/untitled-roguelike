extends Resource
class_name StatusEffectData

enum EFFECT_TYPE{
	TRIGGER_ONCE,
	TRIGGER_ON_TIMER,
}



@export var icon : Texture2D
@export var tier : int
@export var duration : float
@export var tick_speed: float
@export var status_effect_name : String
@export var function : String
@export var args : float




	

		
	

func _init(_icon:Texture2D= null, _tier:int = 1, _duration:float = 0.0, _name:String = "none", _tick_speed: float = 1.0) -> void:
	icon=_icon
	tier=_tier
	duration=_duration
	tick_speed = _tick_speed
	status_effect_name=_name

	
	

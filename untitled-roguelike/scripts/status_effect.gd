extends Resource
class_name StatusEffect

@export var icon : Texture2D
@export var tier : int
@export var duration : float
@export var name : String

func _init(_icon:Texture2D= null, _tier:int = 1, _duration:float = 0.0, _name:String = "none") -> void:
	icon=_icon
	tier=_tier
	duration=_duration
	name=_name

extends ProgressBar

@onready var timer =$Timer
@onready var damage_bar =$DamageBar
var health = value

	
#WHY DO YOU KEEP DISSAPPEARINGGGG
func _get_value(hp:int, max_health:int) -> void:
	max_value=max_health
	value=hp
	timer.start()
func init_health(_health):
	health= _health	
	max_value = _health
	value=health
	damage_bar.max_value=health
	damage_bar.value=health
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	damage_bar.value=value



# Called every frame. 'delta' is the elapsed time since the previous frame.



func _on_timer_timeout() -> void:

	damage_bar.value=value
	damage_bar.max_value=value
	
		

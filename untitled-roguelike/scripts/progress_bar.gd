extends ProgressBar

@onready var timer =$Timer
@onready var damage_bar =$DamageBar
var health = value

func _set_health(new_health):
	var prev = health
	health=min(max_value, new_health)
	value=health
#	if(new_health<=0):
#		queue_free()
	if prev > new_health:
		timer.start()
	if prev < new_health:
		damage_bar.value=new_health

func init_health(_health):
	health= _health	
	max_value = _health
	value=health
	damage_bar.max_value=health
	damage_bar.value=health
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health=100
	damage_bar.value=value



# Called every frame. 'delta' is the elapsed time since the previous frame.



func _on_timer_timeout() -> void:

	damage_bar.value=health
		

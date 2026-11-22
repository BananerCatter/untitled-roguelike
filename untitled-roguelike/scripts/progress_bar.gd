extends ProgressBar
@onready var timer =$Timer
@onready var damage_bar =$DamageBar
var health = value

func _set_health(new_health):
	var prev = health
	health=min(max_value, new_health)
	var tween :Tween = get_tree().create_tween()
	tween.tween_property(self, "value", health, 0.3).set_trans(Tween.TRANS_CUBIC)

	if prev > new_health:
		timer.start()
	if damage_bar.value < value:
		
		damage_bar.value= value


func init_health(_health):
	health= _health	
	max_value = _health
	value=100
	damage_bar.max_value=100
	damage_bar.value=100
	

func _ready() -> void:
	health=100
	damage_bar.value=value


func _on_timer_timeout() -> void:
	var tween :Tween = get_tree().create_tween()
	tween.tween_property(damage_bar, "value", value, 0.4).set_trans(Tween.TRANS_LINEAR)

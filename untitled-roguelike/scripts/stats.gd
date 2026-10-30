extends Resource
#how do i resource im scared
class_name Stats
signal  on_death()
signal  health_changed(current_health: int, max_health: int)
enum buffable_stats{
	MAX_HEALTH,
	DAMAGE,
	DEFENCE,
}
const StatCurves: Dictionary[buffable_stats, Curve] = {
	buffable_stats.MAX_HEALTH: preload("res://resources/stat_curves/max_health_stat_curve.tres"),
	buffable_stats.DAMAGE: preload("uid://behjtvl5ud83h"),
	buffable_stats.DEFENCE: preload("uid://ck45oovgccckr"),
}
@export var max_health_level: int: set =_on_max_health_level_set
@export var damage_level: int: set =_on_damage_level_set
@export var defence_level: int: set =_on_defence_level_set

@export var base_max_health: int
@export var base_damage: float
@export var base_defence: float
@export var faction: factions



enum factions {PLAYER,ENEMY}
#will be relevant once I add a leveling system
var current_max_health: int
var current_damage: float
var current_defence: float

var health: int =base_max_health: set = _on_health_set

func _init() -> void:
	
	setup_stats.call_deferred()
	
func setup_stats() -> void:

	current_max_health=base_max_health
	health=current_max_health
	current_damage=base_damage
	_on_max_health_level_set(max_health_level)
	_on_damage_level_set(damage_level)
	_on_defence_level_set(defence_level)
	recalculate_stats()
	health=current_max_health
	
func take_damage(dmg:int):
	_on_health_set(health-dmg)
	
	
func recalculate_stats() ->void:
	var max_health_stats_curve_pos: float = (float(max_health_level)/ 100.0 ) - 0.01
	var damage_stats_curve_pos: float = (float(damage_level)/ 100.0) - 0.01
	var defence_stats_curve_pos: float = (float(defence_level)/ 100.0 ) - 0.01
	@warning_ignore("narrowing_conversion")
	current_max_health = base_max_health * StatCurves[buffable_stats.MAX_HEALTH].sample(max_health_stats_curve_pos)
	current_damage = base_damage * StatCurves[buffable_stats.DAMAGE].sample(damage_stats_curve_pos)
	current_defence = base_defence * StatCurves[buffable_stats.DEFENCE].sample( defence_stats_curve_pos)

	
func _on_health_set(new_value:int):
	health=clampi(new_value,0,current_max_health)
	if health <= 0:
		on_death.emit()
	health_changed.emit(health,current_max_health)

func  _on_max_health_level_set(new_value:int) ->void:
	var old_level = max_health_level 
	if not old_level == new_value:
		max_health_level=new_value
		recalculate_stats()
		
		
func  _on_damage_level_set(new_value:int) ->void:
	var old_level = damage_level
	if not old_level == new_value:
		damage_level= new_value
		recalculate_stats()
		

func  _on_defence_level_set(new_value:int) ->void:
	var old_level = defence_level
	if not old_level == new_value:
		defence_level= new_value
		recalculate_stats()

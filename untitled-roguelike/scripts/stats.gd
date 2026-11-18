extends Resource
#how do i resource im scared
class_name Stats
signal  on_death()
signal  health_changed(current_health: int, max_health: int)
signal  stamina_changed(new_stamina:float, max_stamina:float)
signal  start_stamina_timer()
enum  buffable_stats{
	MAX_HEALTH,
	DAMAGE,
	DEFENCE,
}
const StatCurves: Dictionary[buffable_stats, Curve] = {
	buffable_stats.MAX_HEALTH: preload("res://resources/stat_curves/max_health_stat_curve.tres"),
	buffable_stats.DAMAGE: preload("uid://behjtvl5ud83h"),
	buffable_stats.DEFENCE: preload("uid://ck45oovgccckr"),
}
@export_group("Base Levels")
@export var max_health_level: int: set =_on_max_health_level_set
@export var damage_level: int: set =_on_damage_level_set
@export var defence_level: int: set =_on_defence_level_set
@export_group("Base Stats")
@export var current_stamina: float 
@export var base_max_health: int
@export var base_damage: float
@export var base_defence: float
@export_group("Extras")
@export var faction: factions
@export var stamina_cooldown: float
@export var stamina_recovery: int


enum factions {PLAYER,ENEMY}
#will be relevant once I add a leveling system
var current_max_health: int
var current_damage: float
var current_defence: float

var health: int =base_max_health: set = _on_health_set
var stamina: float: set = _on_stamina_set
var stamina_cooldown_over: bool = true

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
	stamina = current_stamina

	
	
func take_damage(dmg:int) -> void:
	_on_health_set(health-dmg)

	
func heal(hp:int) -> void:
	_on_health_set(health+hp)

func lose_stamina(stm:float) -> void:
	stamina -= stm
	stamina_cooldown_over = false
	start_stamina_timer.emit()



func recover_stamina(delta:float) -> void:
	@warning_ignore("narrowing_conversion")
	stamina+=stamina_recovery*delta

	
func recalculate_stats() ->void:
	var max_health_stats_curve_pos: float = (float(max_health_level)/ 100.0 ) - 0.01
	var damage_stats_curve_pos: float = (float(damage_level)/ 100.0) - 0.01
	var defence_stats_curve_pos: float = (float(defence_level)/ 100.0 ) - 0.01
	@warning_ignore("narrowing_conversion")
	current_max_health = base_max_health * StatCurves[buffable_stats.MAX_HEALTH].sample(max_health_stats_curve_pos)
	current_damage = base_damage * StatCurves[buffable_stats.DAMAGE].sample(damage_stats_curve_pos)
	current_defence = base_defence * StatCurves[buffable_stats.DEFENCE].sample( defence_stats_curve_pos)

	
func _on_health_set(new_value:int) -> void:
	health=clampi(new_value,0,current_max_health)
	if health <= 0:
		on_death.emit()
	health_changed.emit(health,current_max_health)
	
func _on_stamina_set(new_value:float) -> void:
	stamina = clamp(new_value,-current_stamina,current_stamina)
	stamina_changed.emit(stamina, current_stamina)


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


func use_consumable(consumable_func:Dictionary[String,Array]) -> void:
		for key in consumable_func:
				callv(key, consumable_func[key]) 

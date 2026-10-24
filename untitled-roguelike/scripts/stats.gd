extends Resource
#how do i resource im scared
class_name Stats
signal  on_death()
signal  health_changed(current_health: int, max_health: int)
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
func _on_health_set(new_value:int):
	health=clampi(new_value,0,current_max_health)
	if health <= 0:
		on_death.emit()
	health_changed.emit(health,current_max_health)

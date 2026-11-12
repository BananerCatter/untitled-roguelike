extends Node2D


@onready var UI: CanvasLayer= $GameUi
@onready var game_ui: CanvasLayer = $GameUi
var player:Player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	call_deferred("init_player")


func init_player() -> void:
	player.stamina_changed.connect(UI._on_stamina_changed)
	player.stats.health_changed.connect(UI._on_hp_changed)
	player.stats.health_changed.emit(player.stats.health, player.stats.current_max_health)
	game_ui.inventory_dialogue.item_selected.connect(player._on_item_selected)

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(_delta: float) -> void:
	pass
	
	


func _on_player_on_death() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	queue_free()

extends Node2D
signal _on_player_death
var dungeon_test: Node2D
@onready var UI: CanvasLayer= $GameUi
@onready var game_ui: CanvasLayer = $GameUi
const DUNGEON_TEST = preload("uid://ib5t11nrr4fd")

var player:Player
var start_in_dungeon: bool
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if start_in_dungeon:
		dungeon_test = DUNGEON_TEST.instantiate()

	if dungeon_test:
		print("dungeon test")
		dungeon_test.move_player.connect(_on_dungeon_test_move_player)
		add_child(dungeon_test)
	call_deferred("init_player")


func init_player() -> void:

	player.stats.health_changed.connect(UI._on_hp_changed)
	player.stats.stamina_changed.connect(UI._on_stamina_changed)
	player.stats.health_changed.emit(player.stats.health, player.stats.current_max_health)
	player.stats.stamina_changed.emit(player.stats.stamina, player.stats.current_stamina)
	game_ui.inventory_dialogue.item_selected.connect(player._on_item_selected)
	game_ui.init_player(player)
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(_delta: float) -> void:
	pass
	
	


func _on_player_on_death() -> void:
	_on_player_death.emit()


func _on_dungeon_test_move_player(pos: Vector2) -> void:
	
	player.global_position = pos
	print ("should_move")

extends Node2D

@onready var Player: CharacterBody2D = $Player
@onready var UI: CanvasLayer= $GameUi

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Player.stats.health_changed.connect(UI._on_hp_changed)
	Player.stamina_changed.connect(UI._on_stamina_changed)
	Player.stats.health_changed.emit(Player.stats.health, Player.stats.current_max_health)
	Player.hp_changed.emit((Player.stats.health*100)/Player.stats.current_max_health)



# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(_delta: float) -> void:
	pass
	
	


func _on_player_on_death() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

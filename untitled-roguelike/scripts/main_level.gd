extends Node2D

@onready var Player: CharacterBody2D = $Player
@onready var UI: CanvasLayer= $GameUi

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Player.hp_changed.connect(UI._on_hp_changed)
	Player.stamina_changed.connect(UI._on_stamina_changed)
	Player.stamina_changed.emit((Player.stamina*100)/Player.max_stamina)
	Player.hp_changed.emit((Player.hp*100)/Player.max_hp)



# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(_delta: float) -> void:
	pass
	
	


func _on_player_on_death() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

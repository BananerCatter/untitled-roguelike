extends Node2D

@onready var Player: CharacterBody2D = $Player
@onready var UI: CanvasLayer= $GameUi

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Player.hp_changed.connect(UI._on_hp_changed)
	Player.hp_changed.emit((Player.hp*100)/Player.max_hp)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	

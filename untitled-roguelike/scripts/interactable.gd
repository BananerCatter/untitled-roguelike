extends Area2D

@export var character_name: String = "Object"
@export_multiline var dialogue: Array[String] = []

var player_in_range: bool = false
var player: Player = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	print("Interactable initialized: ", character_name)

func _on_body_entered(body: Node2D) -> void:
	print("Somebody entered: ", body.name)
	if body is Player:
		print("Player Detected!")
		player = body
		player_in_range = true
		DialogueManager.set_interactable(self)

func _on_body_exited(body: Node2D) -> void:
	print("Somebody exited: ", body.name)
	if body == player:
		print("Player Left!")
		DialogueManager.clear_interactable(self)
		player = null
		player_in_range = false
		
func is_player_facing_object() -> bool:
	if not player_in_range or player == null:
		return false
	
	var direction_to_object := (global_position - player.global_position).normalized()
	var facing := player.facing_direction.normalized()
	
	return facing.dot(direction_to_object) > 0.5

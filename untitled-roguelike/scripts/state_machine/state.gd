class_name State extends Node
@export var character: CharacterBody2D
#@export var animated_sprte: AnimatedSprite2D

signal change_state(state_name: String)
	

func enter_state() ->void:
	pass
	
	
func exit_state() -> void:
	pass
	
	
func update(delta:float) -> void:
	pass
	
	
func physics_update(delta:float) -> void:
	pass

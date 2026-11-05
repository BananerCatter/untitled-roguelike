extends Node2D

@export var closed_sprite: Texture2D
@export var open_sprite: Texture2D
@export var loot_table: Dictionary[Item,int]
@export var key_item: Item
@onready var sprite: Sprite2D = $Sprite2D
@onready var detection_area: Area2D = $Area2D

signal give_items(item_dict: Dictionary[Item,int])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.texture = closed_sprite


func _on_chest_opened(inventory:Inventory):
	if inventory.has_item(key_item):
		give_items.emit(loot_table)
		sprite.texture = open_sprite
		detection_area.queue_free()
	else:
		print("Get a key first")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_signal("open_chest"):
		body.open_chest.connect(_on_chest_opened)
	
	if body.has_method("get_items_from_chest"):
		give_items.connect(body.get_items_from_chest)

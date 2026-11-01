class_name Item extends Resource

enum ItemType  {
	WEAPON,
	CONSUMABLE,
	THROWABLE,
	
}

@export var name: String
@export var scene: PackedScene
@export var icon: Texture2D
@export var type: ItemType
@export var is_stackable: bool

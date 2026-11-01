extends CanvasLayer

@onready var player: CharacterBody2D = %Player
@onready var inventory_dialogue: InventoryDialogue = %InventoryDialogue

func _ready() -> void:
	player.update_inventory.connect(_on_update_inventory)

func _on_hp_changed(hp_value:float, max_hp_value:float) -> void:
	%ProgressBar._set_health((hp_value/max_hp_value)*100)
	
	
func _on_stamina_changed(stamina_value:float) ->void:
	%StaminaBar._set_health(stamina_value)
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("inventory"):
		inventory_dialogue.open(player.inventory)

func _on_update_inventory():
	inventory_dialogue._on_update_inventory(player.inventory)

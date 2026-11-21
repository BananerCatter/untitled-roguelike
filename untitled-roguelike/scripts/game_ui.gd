extends CanvasLayer

@onready var player: CharacterBody2D 
@onready var inventory_dialogue: InventoryDialogue = %InventoryDialogue
@onready var status_effects: =%StatusEffects
@onready var label: Label = $Label

func init_player(current_player:Player) -> void:
	player = current_player
	player.inventory.update_inventory.connect(_on_update_inventory)

func _on_hp_changed(hp_value:float, max_hp_value:float) -> void:
	%ProgressBar._set_health((hp_value/max_hp_value)*100)
	
	
func _on_stamina_changed(new_stamina:float, max_stamina:float) ->void:
	%StaminaBar._set_health((new_stamina/max_stamina)*100)
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("inventory"):
		inventory_dialogue.toggle(player.inventory)

func _on_update_inventory():
	inventory_dialogue._on_update_inventory(player.inventory)

func _process(_delta: float) -> void:
	label.text = ("current damage: " +  str(player.stats.current_damage))

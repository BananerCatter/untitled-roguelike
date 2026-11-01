class_name InventoryDialogue
extends PanelContainer

signal item_selected(item:Item)

@export var item_slot: PackedScene
@onready var grid_container: GridContainer = %GridContainer

	

func _on_update_inventory(inventory:Inventory):
	for child in grid_container.get_children():
		child.queue_free()
	
	for item in inventory.get_items():
		var slot = item_slot.instantiate()
		grid_container.add_child(slot)
		slot.display(item)
		slot.connect("item_clicked", on_item_clicked)


func open(inventory:Inventory):
	show()
	_on_update_inventory(inventory)


func _on_close_button_pressed() -> void:
	hide()


func on_item_clicked(item:Item):
	print(item.name)
	item_selected.emit(item)

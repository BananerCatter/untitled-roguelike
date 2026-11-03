class_name InventoryDialogue
extends PanelContainer

signal item_selected(item:Item)

@export var item_icon: PackedScene
@onready var grid_container: GridContainer = %GridContainer

	

func _on_update_inventory(inventory:Inventory):
	for child in grid_container.get_children():
		child.queue_free()
	
	for item in inventory.get_slots():
		var icon = item_icon.instantiate()
		grid_container.add_child(icon)
		icon.display(item)
		icon.connect("item_clicked", on_slot_clicked)


func open(inventory:Inventory):
	show()
	_on_update_inventory(inventory)


func _on_close_button_pressed() -> void:
	hide()


func on_slot_clicked(item:Item):
	print(item.name)
	item_selected.emit(item)

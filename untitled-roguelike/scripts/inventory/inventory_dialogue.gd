class_name InventoryDialogue
extends PanelContainer

signal item_selected(item:Item)
var hotbar_icons: Array[HotbarIcon] = []
var initialized: bool = false
var currently_selected: int =0
var selected_item:Item
@export var item_icon: PackedScene
@export var selector: Sprite2D
@onready var grid_container: GridContainer = %GridContainer
var player_inventory: Inventory
	
	
	
func _init_inventory(size:int) ->void :
	if !initialized:
		for child:HotbarIcon in grid_container.get_children():
			hotbar_icons.append(child)
		initialized = true
	else:
		for child:HotbarIcon in grid_container.get_children():
			hotbar_icons[child.index] = child
	

func _on_update_inventory(inventory:Inventory):
	for child in grid_container.get_children():
		child.queue_free()
	var index:int = 0
	for slot in inventory.get_slots():
		var icon:HotbarIcon = item_icon.instantiate()
		if icon:
			icon.index = index
			print(icon.index)
			grid_container.add_child(icon)
			icon.display(slot)
			icon.connect("item_clicked", on_slot_clicked)
			index+=1
	_init_inventory(inventory.size)
	
	
func _move_selector(index:int) ->void:
	currently_selected = index
	if hotbar_icons[currently_selected]:
		selector.global_position = hotbar_icons[currently_selected].global_position
		print(hotbar_icons[currently_selected].index)
	else :
		pass
	
	
func toggle(inventory:Inventory):
	visible = !visible
	_on_update_inventory(inventory)




func on_slot_clicked(item:Item, icon_index:int):
	_move_selector(icon_index)
	selected_item = item
	
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("use_item"):
		item_selected.emit(selected_item)
	
		

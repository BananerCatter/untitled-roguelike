class_name Inventory
extends Resource


signal UpdatedSlot(slot:ItemSlot)
signal update_inventory()

	

var _content: Array[ItemSlot] =[]
@export var size:int
@export var start_items: Dictionary[Item,int]


func _ready():
	for i in range(size):
		_content.append(ItemSlot.new)
	for key in start_items:
		for i in range(start_items[key]):
			add_item(key)


func add_item(item:Item) -> bool:
	var slot: ItemSlot = get_item_slot(item)
	if slot and slot.amount < item.max_stack_size:
		slot.amount +=1
	else:
		slot = get_empty_slot()
		if not slot:
			return false
		slot.item=item
		slot.amount+=1
	update_inventory.emit()
	UpdatedSlot.emit(slot)
	_content.append(slot)
	return true
	
	
func remove_item(item:Item):
	if not has_item(item):
		return
	var slot:ItemSlot = get_item_slot(item)
	remove_item_from_slot(slot)

func remove_item_from_slot(slot:ItemSlot):
	if not slot.item:
		return
	if slot.amount == 1:
		slot.item=null
	else:
		slot.amount-=1
	update_inventory.emit()
	UpdatedSlot.emit(slot)
	
	
func get_slots() -> Array [ItemSlot]:
	return _content


func get_item_slot(item:Item) -> ItemSlot:
	for slot in _content:
		if slot.item==item:
			return slot
	return null

	
func get_empty_slot() -> ItemSlot:
	for slot in _content:
		if slot.item==null:
			return slot
	return null


func has_item(item:Item)-> bool:
	for slot in _content:
		if slot.item==item:
			return true
	return false

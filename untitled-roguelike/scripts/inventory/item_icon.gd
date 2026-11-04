extends PanelContainer
signal item_clicked(item:Item)
var displayed_item:Item

@onready var amount_label: Label = $Label
@onready var texture_rect: TextureRect = $TextureRect

func display(slot:ItemSlot):
	if slot.item:	
		texture_rect.texture = slot.item.icon
		displayed_item=slot.item
		var count:int =slot.amount
		amount_label.text = str(count)
		if count >1:
			amount_label.show()
		else:
			amount_label.hide()
	

func _on_button_pressed() -> void:
	item_clicked.emit(displayed_item)

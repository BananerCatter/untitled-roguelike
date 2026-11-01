extends PanelContainer
signal item_clicked(item:Item)
var displayed_item:Item

@onready var texture_rect: TextureRect = $TextureRect

func display(item:Item):
	texture_rect.texture = item.icon
	displayed_item=item


func _on_button_pressed() -> void:
	item_clicked.emit(displayed_item)

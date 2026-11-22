class_name StatusDialogue extends PanelContainer
@onready var status_container: HBoxContainer = $HBoxContainer
@export var status_icon_scene: PackedScene




func _update_icons(dict:Dictionary[String,StatusEffect]):
	for child in status_container.get_children():
		child.queue_free()
	for key:String in dict:
		var icon: StatusIcon = status_icon_scene.instantiate()
		if icon:
			status_container.add_child(icon)
			icon.texture_rect.texture = dict[key].status_effect_data.icon

			

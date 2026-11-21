extends PanelContainer
@onready var StatusContainer: HBoxContainer = $HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _add_status_icon(status:StatusEffect) -> void:
	var status_icon:StatusIcon
	status_icon.initialize(status)
	for child:StatusIcon in get_children():
		if child.status_name == status.status_effect_data.status_effect_name:
			if child.tier < status.status_effect_data.tier:
				child.queue_free()
				add_child(status_icon)
			else:
				return
		else:
			add_child(status_icon)
				

func _remove_status_icon(status:StatusEffect) ->void:
	for child:StatusIcon in StatusContainer.get_children():
		if child.status_name == status.status_effect_data.status_effect_name:
			child.queue_free()
					
				
			

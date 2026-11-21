class_name StatusIcon extends PanelContainer
@onready var texture_rect: TextureRect = $TextureRect


var status_name: String
var tier: int


func initialize(status:StatusEffect) -> void:
	texture_rect.texture = status.status_effect_data.icon
	status_name = status.status_effect_data.status_effect_name
	tier = status.status_effect_data.tier

func _ready() -> void:
	initialize.call_deferred()

extends Resource
class_name StatBuff

enum BuffType{
	MULTIPLY,
	ADD,
}

@export var stat: Stats.buffable_stats
@export var buff_amount: float
@export var buff_type: BuffType

func _init(_stat : Stats.buffable_stats = Stats.buffable_stats.MAX_HEALTH, _buff_amount: float = 1.0, _buff_type: BuffType = BuffType.MULTIPLY) -> void:
	buff_amount = buff_amount
	buff_type = buff_type

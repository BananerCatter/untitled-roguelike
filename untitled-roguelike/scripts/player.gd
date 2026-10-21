extends CharacterBody2D

signal on_death
signal hp_changed(hp_value: float)

@export var speed: float = 300
@export var hp: int = 300
@export var max_hp: int
@export var hitbox: CollisionShape2D

func _ready() -> void:
	max_hp=hp
	hp_changed.emit((hp*100)/max_hp)

func take_damage(damage:int) -> void:
	hp-=damage
	@warning_ignore("integer_division")
	hp_changed.emit((hp*100)/max_hp)
	
func heal(damage:int) -> void:
	if(hp+damage>max_hp):
		hp=max_hp
	else:
		hp+=damage
	hp_changed.emit((hp*100)/max_hp)
func _input(event: InputEvent) -> void:
		if event.is_action_pressed("debug_add_hp"):
			heal(10)
		if event.is_action_pressed("debug_deal_damage"):
			take_damage(10)

func get_input() -> void:
	
	var direction = Input.get_vector("left", "right", "up", "down")
	
	velocity = direction*speed


	
func _physics_process(_delta: float) -> void:
	# Add the gravity.
	if(hp<=0):
		on_death.emit()
	get_input()
	
	move_and_slide()

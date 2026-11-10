extends CharacterBody2D

signal on_death
signal hp_changed(hp_value: float)
signal stamina_changed(stamina_value:float)
signal update_inventory
signal open_chest

@export var stats: Stats
@export var inventory:Inventory


@export var max_speed: float
@export var speed: float
@export var dash_mult: float 
var hp: int 
var max_hp: int
var hitbox: Hitbox
@export var acceleration: float
@export var timer: Timer 
@export var dash_cooldown: Timer
var can_dash:bool = true
@export var stamina: float 
@export var max_stamina: float 
@export var stamina_cooldown: Timer
@export var stamina_recovery: float
@export var hitbox_shape: Shape2D

var held_item: HeldWeapon




func _ready() -> void:
	print(inventory)
	max_hp=stats.current_max_health
	@warning_ignore("integer_division")
	stats.call_deferred("take_damage", 0)
	hp_changed.emit(100)
	stamina_changed.emit((stamina*100/max_stamina))
	inventory.get_slots()
	


func take_damage(damage:int) -> void:
	stats.take_damage(damage)
	
	
func heal(damage:int) -> void:
	stats.take_damage(-damage)



func _input(event: InputEvent) -> void:
#Debug lines to test out the hp ui, remember to remove these lines and change the key actions for "1" and "2" once we have some real enemies !!!
		if event.is_action_pressed("debug_add_hp"):
			heal(10)
		if event.is_action_pressed("debug_deal_damage"):
			take_damage(10)
		if event.is_action_released("interact"):
			open_chest.emit(inventory)
			



func get_input() -> Vector2:
	var direction = Input.get_vector("left", "right", "up", "down")
	return direction
	
	
func on_item_picked_up(item: Item):
	inventory.add_item(item)
	
	
func _on_item_selected(item:Item):
	if item:
		if item.item_type== Item.TYPE.consumable_item:
			stats.use_consumable(item.name)
			inventory.remove_item(item)
			update_inventory.emit()
			
		if item.item_type == Item.TYPE.weapon_item:
			if held_item:
				inventory.add_item(held_item.item_from)
				inventory.remove_item(item)
				update_inventory.emit()
				held_item.queue_free()

				
			held_item = item.held_weapon.instantiate()
			held_item.item_from = item
			add_child(held_item)
			inventory.remove_item(item)
			update_inventory.emit()
			
	

func get_items_from_chest(item_dict:Dictionary[Item,int], key_item:Item):
	if inventory.has_item(key_item):
		inventory.remove_item(key_item)
	inventory.get_items_from_dict(item_dict)

func lose_stamina(lost_stamina:float):
	stamina -= lost_stamina
	stamina_cooldown.start()
	stamina_changed.emit((stamina*100/max_stamina))

func weapon_orbit_mouse(delta:float):
	if not held_item.animation.is_playing():
		var direction = get_global_mouse_position() - held_item.global_position
		if direction.length() >8:
			held_item.global_rotation = lerp_angle(held_item.global_rotation, direction.angle(), delta*held_item.rotation_speed)


func _physics_process(delta: float) -> void:
	
	if(stats.health<=0):
		on_death.emit()
	
	if stamina_cooldown.is_stopped() && stamina<max_stamina:
		stamina+=(stamina_recovery*delta)
		if(stamina>max_stamina):
			stamina=max_stamina
		stamina_changed.emit((stamina*100/max_stamina))
	if held_item:
		weapon_orbit_mouse(delta)

	move_and_slide()


func _on_dash_cooldown_timeout() -> void:
	can_dash = true

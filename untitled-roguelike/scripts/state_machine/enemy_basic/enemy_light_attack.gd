extends State
var hitbox:Hitbox

# Called when the node enters the scene tree for the first time.
func enter_state() ->void:
	character.held_item.animation.play("LightAttack1")
	hitbox = Hitbox.new (character.stats, 0.4, character.held_item.hitbox_shape, character.held_item.damage, Hitlog.new())
	character.held_item.sprite.add_child(hitbox)
	change_state.emit("idle")
	
	
func update(delta:float) -> void:
	if not character.held_item.animation.is_playing():
		character.held_item.on_light_attack()

	
func exit_state() -> void:
	character.dash_cooldown.start()

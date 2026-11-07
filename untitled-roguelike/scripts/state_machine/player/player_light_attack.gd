extends State
var direction: Vector2
var hitbox: Hitbox
func enter_state():
	character.lose_stamina(20)
	direction=character.get_input()
	hitbox = Hitbox.new (character.stats, 0.4, character.held_item.hitbox_shape, character.held_item.damage, Hitlog.new())
	character.held_item.sprite.add_child(hitbox)

func update(delta:float) -> void:
	if not character.held_item.animation.is_playing():
		character.held_item.animation.play("LightAttack1")
	change_state.emit("idle")

func physics_update(delta:float) -> void:
	if character.held_item.animation.is_playing():
			character.speed = move_toward(character.speed, 0, character.acceleration*delta)
	character.velocity = character.get_input()*character.speed

		
		
func exit_state():
	character.dash_cooldown.start()

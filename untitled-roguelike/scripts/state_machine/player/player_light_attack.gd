extends State
var direction: Vector2
var hitbox: Hitbox
func enter_state():
	character.lose_stamina(20)
	direction=character.get_input()


func physics_update(delta:float) -> void:
	hitbox = Hitbox.new (character.stats, 0.5, character.hitbox_shape)
	character.add_child(hitbox)
	change_state.emit("idle")
		
		
func exit_state():
	character.dash_cooldown.start()

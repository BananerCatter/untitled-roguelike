extends State
var hitbox:Hitbox

# Called when the node enters the scene tree for the first time.
func enter_state() ->void:
	hitbox = Hitbox.new (character.stats, 0.5, character.hitbox_shape)
	character.add_child(hitbox)
	change_state.emit("idle")
func exit_state() -> void:
	character.dash_cooldown.start()

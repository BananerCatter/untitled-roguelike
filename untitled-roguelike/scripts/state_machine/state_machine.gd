class_name StateMachine extends Node
@export var initial_state: State
var current_state: State
var current_state_name: String
var state_dict: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child_state:State in get_children():
		state_dict[child_state.name.to_lower()]= child_state
		child_state.change_state.connect(_on_change_state)
	if initial_state:
		initial_state.enter_state()
		current_state=initial_state


func _on_change_state(new_state_name: String) ->void:
	if new_state_name == current_state_name.to_lower():
		return
		
	var new_state: State=state_dict.get(new_state_name.to_lower())
	
	if !new_state:
		return
		
	if current_state:
		current_state.exit_state()

	current_state=new_state
	current_state_name=new_state_name.to_lower()
	
	if current_state:
		current_state.enter_state()
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)
		
		
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

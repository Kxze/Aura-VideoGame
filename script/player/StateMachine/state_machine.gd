class_name StateMachine extends Node

@export var initial_state : State = null

@onready var state : State = (func get_initial_state() -> State:
	return initial_state if initial_state != null else get_child(0)).call()

func _ready() -> void:
	for state_node : State in get_children():
		state_node.finished.connect(_transition_to_next_state)
	
	await  owner.ready
	state.enter("")

#region que sustituye las funciones base por las que nosotros creamos en el state	
func _input(event: InputEvent) -> void:
	state.handled_input(event)

func _process(delta: float) -> void:
	state.update(delta)
	
func _physics_process(delta: float) -> void:
	state.physics_update(delta)
#endregion
	
func _transition_to_next_state(target_state_path: String, data : Dictionary = {}):
	if not has_node(target_state_path):
		print(owner.name + ": trying to transition to state" + target_state_path + "but it does not exist")
		return
	var previous_state_path := state.name
	state.exit()
	state = get_node(target_state_path)
	state.enter(previous_state_path, data)

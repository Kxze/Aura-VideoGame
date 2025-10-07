class_name Odil_state extends State

var odil: Odil

func _ready() -> void:
	await owner.ready
	odil = owner as Odil
	assert(odil != null, "The PlayerState state type must be used only in the player scene. It needs the owner to be a Player node.")

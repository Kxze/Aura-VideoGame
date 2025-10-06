class_name Julieta_state extends State

var julieta: Julieta

func _ready() -> void:
	await owner.ready
	julieta = owner as Julieta
	assert(julieta != null, "The PlayerState state type must be used only in the player scene. It needs the owner to be a Player node.")

class_name Cascanueces_state extends State

var cascanueces: CascaNueces

func _ready() -> void:
	await owner.ready
	cascanueces = owner as CascaNueces
	assert(cascanueces != null, "The PlayerState state type must be used only in the player scene. It needs the owner to be a Player node.")

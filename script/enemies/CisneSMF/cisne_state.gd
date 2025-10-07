class_name CisneState extends State

var cisne: Cisne

func _ready() -> void:
	await owner.ready
	cisne = owner as Cisne
	assert(cisne != null, "The PlayerState state type must be used only in the player scene. It needs the owner to be a Player node.")

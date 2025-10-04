extends Area3D

@export var next_level_path: String = ""   # Escena del siguiente nivel
@export var prev_level_path: String = ""   # Escena del nivel anterior
@export var is_next: bool = true           # true = siguiente, false = anterior
@export var start_point : Marker3D

func _on_body_entered(body: Node3D) -> void:
	if body.name != "Player":
		return
	
	if body.has_method("set_controls_enabled"):
		body.set_controls_enabled(false)

	# Elegir escena
	var scene_path = ""
	if is_next and next_level_path != "":
		scene_path = next_level_path
	elif not is_next and prev_level_path != "":
		scene_path = prev_level_path

	if scene_path == "":
		return

	print("Entre a la puerta, iniciando transición...")

	# Guardar spawnPoint del nuevo nivel
	if start_point:
		Player.spawnPoint = start_point

	# Ejecutar transición y esperar
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished

	# Cargar nueva escena
	var tree = get_tree()
	var current_scene = tree.get_current_scene()
	var new_scene = load(scene_path).instantiate()
	tree.get_root().add_child(new_scene)
	tree.set_current_scene(new_scene)

	# Liberar escena anterior
	current_scene.queue_free()

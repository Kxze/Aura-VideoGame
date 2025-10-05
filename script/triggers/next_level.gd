extends Area3D

@export var next_level_path: String = ""   # Escena del siguiente nivel
@export var prev_level_path: String = ""   # Escena del nivel anterior
@export var is_next: bool = true           # true = siguiente, false = anterior
@export var start_point : Marker3D

# 🔊 Precarga del sonido
@onready var inicio_nivel_sound: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready():
	inicio_nivel_sound.stream = preload("res://sonidos/inicio_nivel.mp3")
	inicio_nivel_sound.autoplay = false
	inicio_nivel_sound.volume_db = 0.0  # Puedes ajustar volumen
	add_child(inicio_nivel_sound)


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

	# 🔊 Clon temporal del sonido persistente
	var persistent_player := AudioStreamPlayer.new()
	persistent_player.stream = inicio_nivel_sound.stream
	persistent_player.volume_db = inicio_nivel_sound.volume_db
	persistent_player.autoplay = false

	# ⚙️ Se agrega al root para que no se destruya con la escena
	get_tree().get_root().add_child(persistent_player)
	persistent_player.owner = null  # evita warnings
	persistent_player.play()

	# 🕒 Espera la duración completa del sonido sin cortarlo
	var sound_length = persistent_player.stream.get_length()
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished

	# Cargar nueva escena
	var tree = get_tree()
	var current_scene = tree.get_current_scene()
	var new_scene = load(scene_path).instantiate()
	tree.get_root().add_child(new_scene)
	tree.set_current_scene(new_scene)

	current_scene.queue_free()

	# Espera hasta que termine el audio y luego lo elimina
	await get_tree().create_timer(sound_length).timeout
	if persistent_player and persistent_player.is_inside_tree():
		persistent_player.queue_free()

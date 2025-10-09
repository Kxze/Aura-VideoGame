extends Node3D

@onready var musica_level = preload("res://musica/MelodiaPrincipal.mp3")

func _ready() -> void:
	var audio_manager = get_node_or_null("/root/AudioManager")
	if audio_manager == null:
		push_warning("No se encontró AudioManager en /root/")
		return

	# No reproducir esta música si vienes desde una batalla final
	var escena_actual = get_tree().current_scene.name
	if escena_actual in ["BossBattlePT1", "BossBattlePT2", "BossBattlePT3"]:
		return

	# Si ya está sonando otra canción o ninguna, fuerza esta
	if audio_manager.musica_player.stream != musica_level:
		audio_manager.play_music(musica_level, true)

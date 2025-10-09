extends Node3D

@onready var musica_level2 = preload("res://musica/MelodiaPrincipal.mp3")

func _ready() -> void:
	# 🎵 Música del nivel (solo cambia si no está ya sonando)
	if AudioManager.musica_player.stream != musica_level2:
		AudioManager.play_music(musica_level2, true)

	# 🕓 Esperar un poco tras cargar la escena
	await get_tree().create_timer(2.0).timeout

extends Node3D

@onready var musica_level1 = preload("res://musica/MelodiaPrincipal.mp3")

func _ready():
	# 🎵 Iniciar música del nivel
	if AudioManager.musica_player.stream != musica_level1:
		AudioManager.play_music(musica_level1, true)

	# 🕐 Espera un poco antes de reproducir el diálogo
	await get_tree().create_timer(1.5).timeout

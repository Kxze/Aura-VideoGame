extends Node3D  # o Control, según tu escena
@onready var musica_level1 = preload("res://musica/MelodiaPrincipal.mp3")

func _ready():
	# Cambia la música solo si no es la misma
	if AudioManager.musica_player.stream != musica_level1:
		AudioManager.play_music(musica_level1, true)

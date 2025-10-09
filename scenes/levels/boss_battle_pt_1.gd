extends Node3D

@onready var battle_track: AudioStream = preload("res://musica/MelodiaBatallaFinal.mp3")

func _ready() -> void:
	print("BossBattle cargada")
	_play_battle_music()

func _play_battle_music() -> void:
	var audio_manager = get_node_or_null("/root/AudioManager")
	if audio_manager == null:
		push_warning("No se encontró AudioManager en /root/")
		return

	# Si ya está sonando otra pista, aplicar un fade antes de cambiar
	if audio_manager.musica_player.playing and audio_manager.musica_player.stream != battle_track:
		await audio_manager.fade_out()

	# Reproducir MelodiaBatallaFinal.mp3 en loop
	audio_manager.play_music(battle_track, true)
	print("Reproduciendo MelodiaBatallaFinal.mp3 en BossBattle")

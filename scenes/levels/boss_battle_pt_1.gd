extends Node3D

@onready var battle_track: AudioStream = preload("res://musica/MelodiaBatallaFinal.mp3")

func _ready() -> void:
	print("🎬 BossBattlePT1 cargada")
	_play_battle_music()

func _play_battle_music() -> void:
	var audio_manager = get_node_or_null("/root/AudioManager")
	
	if audio_manager == null:
		push_warning("⚠️ No se encontró el AudioManager en /root/")
		return

	if audio_manager.musica_player == null:
		push_warning("⚠️ El AudioManager no tiene un musica_player asignado.")
		return

	# Detiene cualquier música anterior si está sonando otra
	if audio_manager.musica_player.playing:
		await audio_manager.fade_out()

	# Configura la nueva canción
	audio_manager.musica_player.stream = battle_track
	audio_manager.musica_player.volume_db = -4
	audio_manager.musica_player.stream_paused = false
	audio_manager.musica_player.play()

	# 🔁 Activa el loop correctamente según el tipo de stream
	if audio_manager.musica_player.stream is AudioStream:
		var stream = audio_manager.musica_player.stream
		if stream.has_method("set_loop"):
			stream.set_loop(true)
		elif "loop" in stream:
			stream.loop = true

	print("🎵 Reproduciendo MelodiaBatallaFinal.mp3")

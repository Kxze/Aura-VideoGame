extends Node

# --- Players ---
var efectos_player: AudioStreamPlayer
var musica_player: AudioStreamPlayer

func _ready():
	# Efectos
	efectos_player = AudioStreamPlayer.new()
	efectos_player.name = "SFX_Player"
	add_child(efectos_player)
	efectos_player.volume_db = +6  # 🔊 volumen normal (ajusta aquí)
	
	# Música
	musica_player = AudioStreamPlayer.new()
	musica_player.name = "Music_Player"
	add_child(musica_player)
	musica_player.volume_db = -4  # 🔉 un poco más bajo para equilibrar con efectos


# --------- SFX ----------
# Función base: reproduce y devuelve la duración (si el stream la reporta)
func play_and_get_duration(sound: AudioStream) -> float:
	if sound == null:
		return 0.0
	efectos_player.stream = sound
	efectos_player.play()
	if sound.has_method("get_length"):
		return sound.get_length()
	return 0.0

# Wrappers compatibles con tu menú
func play_click(sound: AudioStream) -> float:
	return play_and_get_duration(sound)

func play_hover(sound: AudioStream) -> float:
	return play_and_get_duration(sound)

# --------- Música ----------
func play_music(track: AudioStream, loop := true) -> void:
	if track == null:
		return
	# Si el stream soporta loop (p.ej. OGG), lo activamos
	if track.has_method("set_loop"):
		track.set_loop(loop)
	elif "loop" in track:
		track.loop = loop
	musica_player.stream = track
	musica_player.play()

func stop_music() -> void:
	musica_player.stop()

func pause_music() -> void:
	musica_player.stream_paused = true

func resume_music() -> void:
	musica_player.stream_paused = false
	
	# --------- EFECTOS ALEATORIOS ----------
func play_random_sfx(sounds: Array) -> void:
	if sounds.is_empty():
		return
	var sound = sounds[randi() % sounds.size()]
	play_and_get_duration(sound)

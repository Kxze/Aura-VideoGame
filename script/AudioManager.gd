extends Node

# --- Players ---
var efectos_player: AudioStreamPlayer
var musica_player: AudioStreamPlayer

# --- Fade config ---
@export var fade_time := 0.8  # segundos para la transición
var fading := false

# --- Nivelación de volumen ---
@export var target_volume_db := -6.0  # nivel objetivo al que se normalizan los audios
@export var normalize_sfx := true
@export var normalize_music := true

func _ready():
	# Efectos
	efectos_player = AudioStreamPlayer.new()
	efectos_player.name = "SFX_Player"
	add_child(efectos_player)
	efectos_player.bus = "Efectos"
	efectos_player.volume_db = 0  # punto neutro
	
	# Música
	musica_player = AudioStreamPlayer.new()
	musica_player.name = "Music_Player"
	add_child(musica_player)
	musica_player.bus = "Musica"
	musica_player.volume_db = -4  # un poco más baja

# --------- UTILIDAD DE NORMALIZACIÓN ----------
func normalize_audio(stream: AudioStream) -> float:
	if stream == null:
		return 0.0
	if not stream is AudioStreamWAV:
		return target_volume_db  # solo WAV permite medir picos fácilmente

	var data = stream.data
	if data.size() == 0:
		return target_volume_db

	# Analizamos volumen máximo (rango -1.0 a 1.0)
	var max_sample := 0.0
	for i in range(0, data.size(), 2):  # saltos de 2 bytes por muestra (16 bits)
		var sample: float = abs(data.decode_float(i))
		if sample > max_sample:
			max_sample = sample

	if max_sample <= 0.0001:
		return target_volume_db

	# Calcula el ajuste en decibelios para igualar a target
	var current_db := linear_to_db(max_sample)
	var diff := target_volume_db - current_db
	return clamp(diff, -12.0, +12.0)  # evita sobrecompensar

# --------- SFX ----------
func play_and_get_duration(sound: AudioStream) -> float:
	if sound == null:
		return 0.0
	
	efectos_player.stream = sound

	if normalize_sfx:
		var adjustment = normalize_audio(sound)
		efectos_player.volume_db = adjustment
	else:
		efectos_player.volume_db = 0
	
	efectos_player.play()

	if sound.has_method("get_length"):
		return sound.get_length()
	return 0.0

func play_click(sound: AudioStream) -> float:
	return play_and_get_duration(sound)

func play_hover(sound: AudioStream) -> float:
	return play_and_get_duration(sound)

func play_random_sfx(sounds: Array) -> void:
	if sounds.is_empty():
		return
	var sound = sounds[randi() % sounds.size()]
	play_and_get_duration(sound)

# --------- MÚSICA ----------
func play_music(track: AudioStream, loop := true, crossfade := true) -> void:
	if track == null:
		return
	
	if musica_player.playing and crossfade:
		await fade_out()

	# Configuramos loop
	if track.has_method("set_loop"):
		track.set_loop(loop)
	elif "loop" in track:
		track.loop = loop
	
	musica_player.stream = track

	if normalize_music:
		var adjustment = normalize_audio(track)
		musica_player.volume_db = adjustment
	else:
		musica_player.volume_db = -4
	
	musica_player.play()

	if crossfade:
		await fade_in()

func stop_music() -> void:
	musica_player.stop()

func pause_music() -> void:
	musica_player.stream_paused = true

func resume_music() -> void:
	musica_player.stream_paused = false

# --------- TRANSICIONES ----------
func fade_out():
	if fading:
		return
	fading = true
	var start_vol = musica_player.volume_db
	var t := 0.0
	while t < fade_time:
		t += get_process_delta_time()
		var vol = lerp(start_vol, -80.0, t / fade_time)
		musica_player.volume_db = vol
		await get_tree().process_frame
	musica_player.stop()
	musica_player.volume_db = start_vol
	fading = false

func fade_in():
	if fading:
		return
	fading = true
	musica_player.volume_db = -80.0
	var t := 0.0
	while t < fade_time:
		t += get_process_delta_time()
		var vol = lerp(-80.0, target_volume_db, t / fade_time)
		musica_player.volume_db = vol
		await get_tree().process_frame
	fading = false

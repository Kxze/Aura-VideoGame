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

# --- Estado global del juego ---
var lampara_desbloqueada := false  # 🌙 se mantiene globalmente mientras el juego esté abierto
var dash_desbloqueado := false     # 🌪️ se mantiene globalmente durante toda la sesión

# ---------------------------------------------------------
#                   CONFIGURACIÓN INICIAL
# ---------------------------------------------------------
func _ready():
	# Efectos
	efectos_player = AudioStreamPlayer.new()
	efectos_player.name = "SFX_Player"
	add_child(efectos_player)
	efectos_player.bus = "Efectos"
	efectos_player.volume_db = 0
	
	# Música
	musica_player = AudioStreamPlayer.new()
	musica_player.name = "Music_Player"
	add_child(musica_player)
	musica_player.bus = "Musica"
	musica_player.volume_db = -4

# ---------------------------------------------------------
#                   NORMALIZACIÓN DE AUDIO
# ---------------------------------------------------------
func normalize_audio(stream: AudioStream) -> float:
	if stream == null:
		return 0.0
	if not stream is AudioStreamWAV:
		return target_volume_db

	var data = stream.data
	if data.size() == 0:
		return target_volume_db

	var max_sample := 0.0
	for i in range(0, data.size(), 2):
		var sample: float = abs(data.decode_float(i))
		if sample > max_sample:
			max_sample = sample

	if max_sample <= 0.0001:
		return target_volume_db

	var current_db := linear_to_db(max_sample)
	var diff := target_volume_db - current_db
	return clamp(diff, -12.0, +12.0)

# ---------------------------------------------------------
#                         SFX
# ---------------------------------------------------------
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

# ---------------------------------------------------------
#             🎇 SONIDOS DE DESBLOQUEO ÚNICO
# ---------------------------------------------------------

# --- LÁMPARA ---
func play_lampara_desbloqueo(sound: AudioStream) -> void:
	if lampara_desbloqueada:
		return
	lampara_desbloqueada = true
	play_and_get_duration(sound)
	print("🔓 Sonido de desbloqueo reproducido por primera vez")

# --- LÁMPARA (persistente, no se corta al cambiar escena) ---
func play_lampara_desbloqueo_persistente(sound: AudioStream) -> void:
	if lampara_desbloqueada:
		print("🔒 Sonido de desbloqueo ya reproducido")
		return

	print("🔓 Reproduciendo sonido de desbloqueo...")
	lampara_desbloqueada = true

	var temp_player := AudioStreamPlayer.new()
	temp_player.stream = sound
	temp_player.bus = "Efectos"
	temp_player.volume_db = 0

	get_tree().get_root().add_child(temp_player)
	temp_player.play()

	var duracion := 0.0
	if sound and sound.has_method("get_length"):
		duracion = sound.get_length()
	if duracion <= 0.0:
		duracion = 2.0

	await get_tree().create_timer(duracion).timeout
	temp_player.queue_free()
	print("✅ Sonido completado y liberado.")

# --- DASH (persistente, no se corta al cambiar escena) ---
func play_dash_desbloqueo_persistente(sound: AudioStream) -> void:
	if dash_desbloqueado:
		print("🔒 Dash ya desbloqueado")
		return

	print("💨 Reproduciendo sonido de desbloqueo del dash...")
	dash_desbloqueado = true

	var temp_player := AudioStreamPlayer.new()
	temp_player.stream = sound
	temp_player.bus = "Efectos"
	temp_player.volume_db = 0

	get_tree().get_root().add_child(temp_player)
	temp_player.play()

	var duracion := 0.0
	if sound and sound.has_method("get_length"):
		duracion = sound.get_length()
	if duracion <= 0.0:
		duracion = 2.0

	await get_tree().create_timer(duracion).timeout
	temp_player.queue_free()
	print("✅ Sonido de dash completado y liberado.")
	
# ---------------------------------------------------------
#             🔊 SONIDOS SFX PERSISTENTES (NO SE CORTAN)
# ---------------------------------------------------------
func play_sfx_persistente(sound: AudioStream) -> void:
	if sound == null:
		return
	
	var temp_player := AudioStreamPlayer.new()
	temp_player.stream = sound
	temp_player.bus = "Efectos"
	temp_player.volume_db = 0
	temp_player.autoplay = false

	get_tree().get_root().add_child(temp_player)
	temp_player.play()

	var duracion := 0.0
	if sound and sound.has_method("get_length"):
		duracion = sound.get_length()
	if duracion <= 0.0:
		duracion = 2.0  # seguridad por si no detecta longitud

	await get_tree().create_timer(duracion).timeout
	temp_player.queue_free()

# ---------------------------------------------------------
#                         MÚSICA
# ---------------------------------------------------------
func play_music(track: AudioStream, loop := true, crossfade := true) -> void:
	if track == null:
		return
	
	if musica_player.playing and crossfade:
		await fade_out()

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

# ---------------------------------------------------------
#                     TRANSICIONES
# ---------------------------------------------------------
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

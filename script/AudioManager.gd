extends Node

# --- Players ---
var efectos_player: AudioStreamPlayer
var musica_player: AudioStreamPlayer

# --- Fade config ---
@export var fade_time := 0.8  # segundos para la transición
var fading := false

# --- Nivelación de volumen ---
@export var target_volume_db := -6.0
@export var normalize_sfx := true
@export var normalize_music := true

# --- Estado global del juego ---
var lampara_desbloqueada := false  # 🌙 se mantiene globalmente
var dash_desbloqueado := false     # 🌪️
var coleccionable_sonado := false  # 🔔

# ---------------------------------------------------------
#                   CONFIGURACIÓN INICIAL
# ---------------------------------------------------------
func _ready():
	# --- SFX Player ---
	efectos_player = AudioStreamPlayer.new()
	efectos_player.name = "SFX_Player"
	add_child(efectos_player)
	efectos_player.bus = "Efectos"
	efectos_player.volume_db = 0

	# --- Music Player ---
	musica_player = AudioStreamPlayer.new()
	musica_player.name = "Music_Player"
	add_child(musica_player)
	musica_player.bus = "Musica"
	musica_player.volume_db = -4
	
	get_tree().connect("scene_changed", Callable(self, "_on_scene_changed_global"))


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
#                         🔊 SFX
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


# 🔹 SFX genérico (para áreas, botones, desbloqueos, etc.)
func play_sfx(sound: AudioStream) -> void:
	if sound == null:
		return
	play_and_get_duration(sound)


# 🔹 SFX persistente (no se corta si cambia de escena)
func play_sfx_persistente(sound: AudioStream) -> void:
	if sound == null:
		return
	
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

# ---------------------------------------------------------
# 🎯 SONIDO DE DAÑO DEL JUGADOR
# ---------------------------------------------------------
func play_daño(sound: AudioStream) -> void:
	if sound == null:
		return

	# Evita que se corte otro sonido de daño si ocurre muy rápido
	if efectos_player.playing and efectos_player.stream == sound:
		return

	efectos_player.stream = sound
	efectos_player.volume_db = 0
	efectos_player.bus = "Efectos"
	efectos_player.play()
	
# ---------------------------------------------------------
# 🎯 SONIDO DE ATAQUE DEL CASCANUECES
# ---------------------------------------------------------
func play_ataque(sound: AudioStream) -> void:
	if sound == null:
		return

	# Evita que se corte otro sonido de daño si ocurre muy rápido
	if efectos_player.playing and efectos_player.stream == sound:
		return

	efectos_player.stream = sound
	efectos_player.volume_db = 0
	efectos_player.bus = "Efectos"
	efectos_player.play()
	
# ---------------------------------------------------------
# 🎯 SONIDO DE MUERTE SKELETON
# ---------------------------------------------------------
func play_skeleton(sound: AudioStream) -> void:
	if sound == null:
		return

	# Evita que se corte otro sonido de daño si ocurre muy rápido
	if efectos_player.playing and efectos_player.stream == sound:
		return

	efectos_player.stream = sound
	efectos_player.volume_db = 0
	efectos_player.bus = "Efectos"
	efectos_player.play()
	
# ---------------------------------------------------------
# 💧 SONIDO DE LLANTO JULIETA (variaciones continuas durante el nivel)
# ---------------------------------------------------------
var julieta_player: AudioStreamPlayer = null
var julieta_sounds: Array[AudioStream] = []
var julieta_timer: Timer = null
var julieta_activa: bool = false

# ---------------------------------------------------------
# Cargar sonidos de Julieta
# ---------------------------------------------------------
func _load_julieta_sounds():
	var paths = [
		"res://sonidos/julietaEco.wav",
	]

	julieta_sounds.clear()
	for p in paths:
		if ResourceLoader.exists(p):
			var s = load(p)
			if s:
				julieta_sounds.append(s)

	if julieta_sounds.is_empty():
		push_warning("⚠️ No se encontraron sonidos de Julieta.")
	else:
		print("💧 Sonidos de Julieta cargados:", julieta_sounds.size())

# ---------------------------------------------------------
# 🔊 Inicia la secuencia continua de llanto aleatorio
# ---------------------------------------------------------
func play_julieta():
	if julieta_activa:
		return # ya se está reproduciendo

	if julieta_sounds.is_empty():
		_load_julieta_sounds()

	if julieta_player == null:
		julieta_player = AudioStreamPlayer.new()
		julieta_player.name = "Julieta_Player"
		julieta_player.bus = "Efectos"
		add_child(julieta_player)

	# Crear o reiniciar el timer que maneja el cambio automático
	if julieta_timer == null:
		julieta_timer = Timer.new()
		julieta_timer.one_shot = true
		add_child(julieta_timer)
		julieta_timer.timeout.connect(_on_julieta_timer_timeout)

	julieta_activa = true
	print("💧 Llanto de Julieta iniciado (nivel activo).")
	_play_random_julieta()

# ---------------------------------------------------------
# 🌀 Reproduce un sonido aleatorio y programa el siguiente
# ---------------------------------------------------------
func _play_random_julieta():
	if not julieta_activa or julieta_sounds.is_empty():
		return

	# Escoge un sonido aleatorio diferente al actual si es posible
	var selected_sound: AudioStream = julieta_sounds.pick_random()
	if julieta_player.stream == selected_sound and julieta_sounds.size() > 1:
		selected_sound = julieta_sounds.filter(func(s): return s != selected_sound).pick_random()

	julieta_player.stream = selected_sound

	# Loop no necesario: nosotros manejamos el cambio
	if selected_sound.has_method("set_loop"):
		selected_sound.set_loop(false)

	# 🎚️ Variaciones naturales más notorias
	var random_pitch := randf_range(0.85, 1.15)
	var random_volume := randf_range(-3.0, 3.0)

	julieta_player.pitch_scale = random_pitch
	julieta_player.volume_db = random_volume
	julieta_player.play()

	print("💧 Reproduciendo:", selected_sound.resource_path,
		" | pitch:", random_pitch, " | vol:", random_volume)

	# Duración del clip o valor de respaldo
	var dur := 5.0
	if selected_sound.has_method("get_length"):
		dur = selected_sound.get_length()

	# ⚡ Variación del tiempo entre clips (más natural)
	var next_delay := dur + randf_range(0.2, 1.0)
	julieta_timer.start(next_delay)

# ---------------------------------------------------------
# 🔁 Cuando termina un clip → reproducir el siguiente
# ---------------------------------------------------------
func _on_julieta_timer_timeout():
	if not julieta_activa:
		return
	_play_random_julieta()

# ---------------------------------------------------------
# 🛑 Detiene toda la secuencia y libera recursos
# ---------------------------------------------------------
func stop_julieta():
	if julieta_player and julieta_player.playing:
		julieta_player.stop()
	if julieta_timer:
		julieta_timer.stop()

	julieta_activa = false
	print("🔇 Llanto de Julieta detenido completamente.")

# ---------------------------------------------------------
# 🎬 Detener llanto al cambiar de nivel
# ---------------------------------------------------------
func _on_scene_changed_global(new_scene):
	if julieta_activa:
		stop_julieta()
		print("🏁 Escena cambiada → llanto de Julieta detenido automáticamente.")

# ---------------------------------------------------------
#        🔔 SONIDO COLECCIONABLE CERCA (UNA SOLA VEZ)
# ---------------------------------------------------------
func play_coleccionable_cerca(sound: AudioStream) -> void:
	if coleccionable_sonado:
		print("🔕 Sonido de coleccionable ya reproducido, no se repetirá.")
		return

	coleccionable_sonado = true
	print("🔔 Reproduciendo sonido de coleccionable cerca...")

	play_sfx_persistente(sound)
	print("✅ Sonido de coleccionable completado.")


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
	
	

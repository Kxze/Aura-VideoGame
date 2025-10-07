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
var casco_sonado := false  # 🔔 evita que el sonido del coleccionable se repita
var oso_sonado := false  
var pluma_sonada := false     # 🪶 evita que el sonido de la pluma se repita

# --- Coleccionables obtenidos (persisten mientras dure la partida) ---
var casco_obtenido := false
var oso_obtenido := false
var pluma_obtenida := false

# --- Diálogos ---
var dialogo_en_progreso := false   # 🔒 Evita que se superpongan diálogos
var dialogo_player_actual: AudioStreamPlayer = null
var alex1_sonado := false  # ✅ evita repetir el primer diálogo de Alex
var alex2_sonado := false 
var alex3_sonado := false
var alex7_sonado := false
var alex4_sonado := false  
var alex6_sonado := false  
var alex_dialogos_sonados := {}  # 🔒 Guarda qué diálogos de Alex ya sonaron por ID

var cisne_convertido := false  # 🕊️ true = ya se transformó en Cisne Blanco


# ---------------------------------------------------------
#                   CONFIGURACIÓN INICIAL
# ---------------------------------------------------------
func _ready():
	# --- SFX Player ---
	efectos_player = AudioStreamPlayer.new()
	efectos_player.name = "SFX_Player"
	add_child(efectos_player)
	efectos_player.bus = "Efectos"
	efectos_player.volume_db = +10.0  # 🔊 SFX mucho más presentes (≈ el triple de volumen percibido)
	process_mode = Node.PROCESS_MODE_ALWAYS  # ✅ sigue funcionando aunque el juego esté pausado

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
		efectos_player.volume_db = adjustment + 10.0  # 🔊 refuerzo extra
	else:
		efectos_player.volume_db = +10.0
	
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
	temp_player.volume_db = +10.0  # mismo refuerzo que el principal

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
# 🎙️ DIÁLOGOS DE AURA 
# ---------------------------------------------------------
func play_dialogo_aura(stream: AudioStream) -> void:
	if not stream:
		push_warning("⚠️ No se encontró el audio del diálogo de Aura.")
		return

	# 🚫 No reproducir si el juego está pausado
	if get_tree().paused:
		print("⏸️ Juego pausado → no iniciar diálogo de Aura.")
		return

	if dialogo_en_progreso:
		print("🕓 Esperando a que termine el diálogo anterior antes de reproducir Aura.")
		await esperar_dialogo_anterior()

	dialogo_en_progreso = true

	# ✅ Si ya hay un diálogo en curso, no crear otro
	if dialogo_player_actual:
		dialogo_player_actual.stop()
		dialogo_player_actual.queue_free()

	dialogo_player_actual = AudioStreamPlayer.new()
	dialogo_player_actual.name = "AuraDialogPlayer"
	dialogo_player_actual.stream = stream
	dialogo_player_actual.bus = "Dialogos"
	dialogo_player_actual.volume_db = +6.0
	add_child(dialogo_player_actual)
	dialogo_player_actual.owner = null  # 👈 evita ser destruido al cambiar de escena

	dialogo_player_actual.play()

	dialogo_player_actual.finished.connect(func():
		dialogo_en_progreso = false
		dialogo_player_actual.queue_free()
		dialogo_player_actual = null
	)
	print("🎧 Diálogo de Aura iniciado.")

# ---------------------------------------------------------
# 🎙️ DIÁLOGOS DE ALEX (PERSISTENTES ENTRE NIVELES)
# ---------------------------------------------------------
func play_dialogo_alex(stream: AudioStream, id: String = "") -> void:
	if not stream:
		push_warning("⚠️ No se encontró el audio del diálogo de Alex.")
		return

	# 🚫 No reproducir si el juego está pausado
	if get_tree().paused:
		print("⏸️ Juego pausado → no iniciar diálogo de Alex (%s)." % id)
		return

	# 🚫 Evitar repetir diálogos individuales (según ID)
	if id != "" and alex_dialogos_sonados.has(id) and alex_dialogos_sonados[id]:
		print("🔇 Diálogo de Alex '%s' ya fue reproducido." % id)
		return

	# 🔒 Marcar este diálogo como reproducido
	if id != "":
		alex_dialogos_sonados[id] = true

	# ⏳ Esperar si otro diálogo está activo
	if dialogo_en_progreso:
		print("🕓 Esperando a que termine el diálogo anterior antes de reproducir Alex (%s)..." % id)
		await esperar_dialogo_anterior()

	dialogo_en_progreso = true

	# ✅ Limpiar si existía otro diálogo viejo
	if dialogo_player_actual:
		dialogo_player_actual.stop()
		dialogo_player_actual.queue_free()

	dialogo_player_actual = AudioStreamPlayer.new()
	dialogo_player_actual.name = "AlexDialogPlayer_%s" % id
	dialogo_player_actual.stream = stream
	dialogo_player_actual.bus = "Dialogos"
	dialogo_player_actual.volume_db = +10.0  # 🎧 más fuerte sobre música
	add_child(dialogo_player_actual)
	dialogo_player_actual.owner = null

	dialogo_player_actual.play()

	dialogo_player_actual.finished.connect(func():
		dialogo_en_progreso = false
		dialogo_player_actual.queue_free()
		dialogo_player_actual = null
	)
	print("🎧 Diálogo de Alex (%s) iniciado." % id)

# ---------------------------------------------------------
# 🕓 FUNCIÓN AUXILIAR
# ---------------------------------------------------------
func esperar_dialogo_anterior() -> void:
	while dialogo_en_progreso:
		await get_tree().process_frame
		
# ---------------------------------------------------------
# 🛑 CONTROL DE DIÁLOGOS DURANTE LA PAUSA
# ---------------------------------------------------------
var pausa_activa := false

func set_pausa_activa(valor: bool) -> void:
	pausa_activa = valor

	# Si no hay diálogo activo, no hacer nada
	if dialogo_player_actual == null:
		return

	# Pausar o reanudar el diálogo sin reiniciarlo
	if pausa_activa:
		if dialogo_player_actual.playing:
			dialogo_player_actual.stream_paused = true
			print("⏸️ Diálogo pausado por menú de pausa.")
	else:
		if dialogo_player_actual.stream_paused:
			dialogo_player_actual.stream_paused = false
			print("▶️ Diálogo reanudado tras salir de pausa.")

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
	efectos_player.volume_db = +10.0
	efectos_player.bus = "Efectos"
	efectos_player.play()
	
# ---------------------------------------------------------
# ⚔️ SONIDO DE ATAQUE CASCANUECES
# ---------------------------------------------------------
func play_ataque(sound: AudioStream) -> void:
	if sound == null:
		return

	# 🚫 Evita solapamiento si ya se está reproduciendo el mismo sonido
	if efectos_player.playing and efectos_player.stream == sound:
		return

	# 🎵 Asigna el sonido al reproductor global de efectos
	efectos_player.stream = sound
	efectos_player.bus = "Efectos"

	# 🎚️ Volumen alto para destacar sobre la música y otros efectos
	efectos_player.volume_db = +10.0

	# ▶️ Reproduce
	efectos_player.play()

	print("⚔️ Sonido de ataque reproducido:", sound.resource_path)
	
# ---------------------------------------------------------
# 🕊️ SONIDO PAS DE LUMIÈRE (Cisne Blanco)
# ---------------------------------------------------------
var paso_cisne_en_progreso := false  # ⏳ evita solapamientos

func play_paso_cisne(sound: AudioStream) -> void:
	if sound == null:
		return

	# 🚫 No reproducir si ya está en progreso
	if paso_cisne_en_progreso:
		print("⏳ Pas de Lumière aún en reproducción, esperando...")
		return

	paso_cisne_en_progreso = true  # 🔒 bloquear mientras suena

	# 🎵 Configuración del reproductor
	efectos_player.stream = sound
	efectos_player.bus = "Efectos"
	efectos_player.volume_db = +3.0

	efectos_player.play()
	print("🩰 Sonido de paso del Cisne Blanco reproducido:", sound.resource_path)

	# 🕒 Esperar hasta que termine el sonido antes de desbloquear
	var duracion := 0.0
	if sound.has_method("get_length"):
		duracion = sound.get_length()
	if duracion <= 0.0:
		duracion = 1.5  # ⏱️ fallback si no se puede leer duración

	await get_tree().create_timer(duracion).timeout

	paso_cisne_en_progreso = false  # 🔓 desbloquear
	print("✅ Pas de Lumière finalizado, se puede reproducir de nuevo.")

# ---------------------------------------------------------
# 🌀 SONIDO DE GIRO (ODIL) — no espacial, loop constante
# ---------------------------------------------------------
var spin_player: AudioStreamPlayer = null
var spin_loop_active := false

func play_spin_odil(sound: AudioStream) -> void:
	if sound == null:
		return
	if spin_loop_active:
		return  # ya sonando

	# 🔊 Crear reproductor global si no existe
	if not spin_player:
		spin_player = AudioStreamPlayer.new()
		spin_player.name = "SpinPlayer"
		spin_player.bus = "Efectos"
		spin_player.stream = sound
		spin_player.volume_db = +4.0
		spin_player.autoplay = false
		spin_player.process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().root.add_child(spin_player)  # fuera del mundo 3D (no se pausa ni atenúa)

	spin_loop_active = true
	spin_player.stream = sound
	spin_player.play()
	spin_player.finished.connect(_on_spin_finished.bind(sound), CONNECT_ONE_SHOT)
	print("🌀 Loop de giro iniciado.")


func _on_spin_finished(sound: AudioStream) -> void:
	if spin_loop_active and spin_player:
		spin_player.play()  # reinicia el mismo sonido
		spin_player.finished.connect(_on_spin_finished.bind(sound), CONNECT_ONE_SHOT)


func stop_spin_odil() -> void:
	spin_loop_active = false
	if spin_player and spin_player.playing:
		spin_player.stop()
	print("🛑 Loop de giro detenido.")



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
	efectos_player.volume_db = +10.0
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
#  Reproduce un sonido aleatorio y programa el siguiente
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
#        🔔 SONIDO COLECCIONABLE CASCO
# ---------------------------------------------------------
func play_sonidoCasco(sound: AudioStream) -> void:
	if casco_sonado:
		print("🔕 Sonido de coleccionable ya reproducido, no se repetirá.")
		return

	casco_sonado = true
	print("🔔 Reproduciendo sonido de coleccionable cerca...")

	play_sfx_persistente(sound)
	print("✅ Sonido de coleccionable completado.")
	
# ---------------------------------------------------------
#        🧸 SONIDO COLECCIONABLE OSO
# ---------------------------------------------------------
func play_sonidoOso(sound: AudioStream) -> void:
	if oso_sonado:
		print("🔕 Sonido del oso ya reproducido, no se repetirá.")
		return

	oso_sonado = true
	print("🧸 Reproduciendo sonido del coleccionable OSO...")
	play_sfx_persistente(sound)
	print("✅ Sonido de oso completado.")
	
	# ---------------------------------------------------------
#        🪶 SONIDO COLECCIONABLE PLUMA
# ---------------------------------------------------------
func play_sonidoPluma(sound: AudioStream) -> void:
	if pluma_sonada:
		print("🔕 Sonido de la pluma ya reproducido, no se repetirá.")
		return

	pluma_sonada = true
	print("🪶 Reproduciendo sonido del coleccionable PLUMA...")
	play_sfx_persistente(sound)
	print("✅ Sonido de pluma completado.")

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
	

extends Node

signal dialogo_iniciado_con_stream(stream: AudioStream)
signal dialogo_terminado(stream_path: String)

# -----------------------
# Flags y estado
# -----------------------
var _buses_muteados_por_ajustes: Array = []
var ajustes_popup_abierto: bool = false
var _efectos_muteados_por_ajustes: bool = false
var _dialogo_pausado_por_ajustes: bool = false
var _dialogos_muteados_por_ajustes: bool = false

var mostrar_subtitulos := true

# Bus index para Dialogos
var dialogos_bus: int = -1

# Players
var efectos_player: AudioStreamPlayer
var musica_player: AudioStreamPlayer

# Pool opcional
var _sfx_pool: Array = []
@export var sfx_pool_size := 6

# Fade config
@export var fade_time := 0.8
var fading := false

# Normalización
@export var target_volume_db := -6.0
@export var normalize_sfx := true
@export var normalize_music := true

# Estado global
var play_skeleton := false
var lampara_desbloqueada := false
var dash_desbloqueado := false
var coleccionable_sonado := false
var coleccionable_cerca := false
var casco_sonado := false
var oso_sonado := false
var pluma_sonada := false

var casco_obtenido := false
var oso_obtenido := false
var pluma_obtenida := false

# Diálogos
var dialogo_en_progreso := false
var dialogo_player_actual: AudioStreamPlayer = null

var cisne_convertido := false

# ---------------------------------------------------------
# INICIALIZACIÓN
# ---------------------------------------------------------
func _ready():
	# SFX player
	efectos_player = AudioStreamPlayer.new()
	efectos_player.name = "SFX_Player"
	add_child(efectos_player)
	efectos_player.bus = "Efectos"
	efectos_player.volume_db = +10.0
	efectos_player.process_mode = Node.PROCESS_MODE_ALWAYS
	efectos_player.owner = null

	# Music player
	musica_player = AudioStreamPlayer.new()
	musica_player.name = "Music_Player"
	add_child(musica_player)
	musica_player.bus = "Musica"
	musica_player.volume_db = -4
	musica_player.process_mode = Node.PROCESS_MODE_ALWAYS
	musica_player.owner = null

	# índice del bus de diálogos
	dialogos_bus = AudioServer.get_bus_index("Dialogos")
	if dialogos_bus == -1:
		print("Aviso: no se encontró el bus 'Dialogos'. Crea el bus en Project Settings → Audio → Buses.")

	get_tree().connect("scene_changed", Callable(self, "_on_scene_changed_global"))


# ---------------------------------------------------------
# Normalización de audio
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
# SFX
# ---------------------------------------------------------
func play_and_get_duration(sound: AudioStream) -> float:
	if sound == null:
		return 0.0

	efectos_player.stream = sound

	if normalize_sfx:
		var adjustment = normalize_audio(sound)
		efectos_player.volume_db = adjustment + 10.0
	else:
		efectos_player.volume_db = +10.0

	efectos_player.play()

	if sound.has_method("get_length"):
		return sound.get_length()
	return 0.0


func play_sfx(sound: AudioStream) -> void:
	if sound == null:
		return

	var tmp := AudioStreamPlayer.new()
	tmp.stream = sound
	tmp.bus = "Efectos"
	tmp.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().get_root().add_child(tmp)
	tmp.owner = null
	tmp.play()

	var dur := 2.0
	if sound.has_method("get_length"):
		dur = sound.get_length()
	await get_tree().create_timer(dur).timeout
	if tmp and tmp.is_inside_tree():
		tmp.queue_free()


func play_click(sound: AudioStream) -> float:
	return play_and_get_duration(sound)


func play_hover(sound: AudioStream) -> float:
	return play_and_get_duration(sound)


func play_random_sfx(sounds: Array) -> void:
	if sounds.is_empty():
		return
	var sound = sounds[randi() % sounds.size()]
	play_sfx(sound)


func play_sfx_persistente(sound: AudioStream) -> void:
	if sound == null:
		return

	var temp_player := AudioStreamPlayer.new()
	temp_player.stream = sound
	temp_player.bus = "Efectos"
	temp_player.volume_db = +10.0
	temp_player.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().get_root().add_child(temp_player)
	temp_player.owner = null
	temp_player.play()

	var duracion := 0.0
	if sound and sound.has_method("get_length"):
		duracion = sound.get_length()
	if duracion <= 0.0:
		duracion = 2.0

	await get_tree().create_timer(duracion).timeout
	temp_player.queue_free()

# Carga dinámica por ruta (para Lumiere y otros)
func play_sfx_by_path(path: String) -> void:
	if path.is_empty():
		push_warning("Ruta de audio vacía.")
		return

	var sound: AudioStream = load(path)
	if sound:
		play_sfx(sound)
	else:
		push_warning("No se pudo cargar el AudioStream desde la ruta: " + path)

# Wrappers de compatibilidad
func play_sonidoCasco(sound: AudioStream) -> void:
	play_sfx(sound)

func play_sonidoPluma(sound: AudioStream) -> void:
	play_sfx(sound)

func play_sonidoOso(sound: AudioStream) -> void:
	play_sfx(sound)


# ---------------------------------------------------------
# Diálogos (CORREGIDOS Y CON SEÑAL)
# ---------------------------------------------------------
# arriba con las otras vars (si no existe)
var last_dialog_stream_path: String = ""

# ---------------------------------------------------------
# Diálogos (mejorado: evita loop y añade watchdog)
# ---------------------------------------------------------
func play_dialogo_aura(stream: AudioStream) -> void:
	if not stream:
		push_warning("No se encontró el audio del diálogo de Aura.")
		return

	# Debug
	print("[AudioManager] play_dialogo_aura pedido ->", stream.resource_path, " frame:", Engine.get_frames_drawn())

	# Evitar reproducir justo al inicio si algo lo llama por accidente (opcional)
	if Engine.get_frames_drawn() < 1:
		# comentar esta línea si quieres permitir en frame 0
		# print("[AudioManager] Ignorando petición en frames muy tempranos.")
		# return
		pass

	# Evitar reproducir el mismo diálogo si ya está en curso
	if dialogo_en_progreso and last_dialog_stream_path == stream.resource_path:
		if dialogo_player_actual and dialogo_player_actual.playing:
			print("[AudioManager] Mismo diálogo ya en curso, ignorando petición:", stream.resource_path)
			return

	if get_tree().paused:
		print("Juego pausado → no iniciar diálogo.")
		return

	# Esperar diálogo anterior si existe
	if dialogo_en_progreso:
		await esperar_dialogo_anterior()

	dialogo_en_progreso = true

	# Limpiar player previo si existe
	if dialogo_player_actual:
		dialogo_player_actual.stop()
		if dialogo_player_actual.is_inside_tree():
			dialogo_player_actual.queue_free()
		dialogo_player_actual = null

	# Intentar forzar que el recurso no haga loop
	if stream.has_method("set_loop"):
		stream.set_loop(false)
	elif "loop" in stream:
		# si el resource expone la propiedad loop
		stream.loop = false

	# Crear y configurar player
	dialogo_player_actual = AudioStreamPlayer.new()
	dialogo_player_actual.name = "AuraDialogPlayer"
	dialogo_player_actual.stream = stream
	dialogo_player_actual.bus = "Dialogos"
	dialogo_player_actual.volume_db = +6.0
	dialogo_player_actual.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(dialogo_player_actual)
	dialogo_player_actual.owner = null

	# Aseguramos que el player no esté en loop por si acaso (defensa)
	# Nota: AudioStreamPlayer no siempre tiene la propiedad 'loop' directamente; se controla en el stream.
	# Pero intentamos limpiarlo por si acaso:
	if "loop" in dialogo_player_actual:
		dialogo_player_actual.loop = false

	# Conectar finished con callable (más fiable que lambdas anónimas en algunos casos)
	if not dialogo_player_actual.is_connected("finished", Callable(self, "_on_dialogo_player_finished")):
		dialogo_player_actual.finished.connect(Callable(self, "_on_dialogo_player_finished"))

	# Guardar ruta para evitar reentradas
	last_dialog_stream_path = stream.resource_path

	# Reproducir
	dialogo_player_actual.play()

	# Emitir señal para SubtitleManager (tal como lo tienes)
	emit_signal("dialogo_iniciado_con_stream", stream)

	# Watchdog: si la señal 'finished' no llega (por ejemplo el stream reporta longitud 0),
	# forzamos stop después de la duración conocida + un pequeño margen.
	var dur := 0.0
	if stream.has_method("get_length"):
		dur = stream.get_length()
	# si la duración no es válida, ponemos un fallback corto
	if dur <= 0.0:
		dur = 10.0
	# lanzamos una espera asíncrona no bloqueante
	_spawn_watchdog(dur + 0.2)

	print("[AudioManager] Diálogo iniciado (watchdog en", dur + 0.2, "s ) ->", stream.resource_path)


func _spawn_watchdog(wait_time: float) -> void:
	await get_tree().create_timer(wait_time).timeout

	# Si sigue sonando, forzamos detener y limpiar
	if dialogo_player_actual and dialogo_player_actual.playing:
		print("[AudioManager][WATCHDOG] El diálogo sigue sonando tras timeout. Forzando stop.")
		dialogo_player_actual.stop()
		
		var path := ""
		if dialogo_player_actual and dialogo_player_actual.stream:
			path = dialogo_player_actual.stream.resource_path
# ... luego
		if dialogo_player_actual and dialogo_player_actual.is_inside_tree():
			dialogo_player_actual.queue_free()
			dialogo_player_actual = null
			dialogo_en_progreso = false
			last_dialog_stream_path = ""
			emit_signal("dialogo_terminado", path)
			print("[AudioManager][WATCHDOG] limpieza completada y señal emitida.")


# Handler llamado cuando el player emite 'finished'
func _on_dialogo_player_finished() -> void:
	print("[AudioManager] Señal finished recibida.")
	# Emitir señal para que quien esté mostrando subtítulos sepa que terminó
	var path := ""
	if dialogo_player_actual and dialogo_player_actual.stream:
		path = dialogo_player_actual.stream.resource_path

	# Limpiar player
	if dialogo_player_actual and dialogo_player_actual.is_inside_tree():
		dialogo_player_actual.queue_free()

	dialogo_player_actual = null
	dialogo_en_progreso = false
	last_dialog_stream_path = ""

	# Emitir la señal *después* de limpiar para que otros nodos puedan reaccionar
	emit_signal("dialogo_terminado", path)
	print("[AudioManager] dialogo terminado. señal emitida y limpieza completada.")


# Aux
func esperar_dialogo_anterior() -> void:
	while dialogo_en_progreso:
		await get_tree().process_frame


# ---------------------------------------------------------
# Control de diálogos durante la pausa
# ---------------------------------------------------------
var pausa_activa := false

func set_pausa_activa(valor: bool) -> void:
	pausa_activa = valor

	# Diálogos: pausar/reanudar mediante el player
	if dialogo_player_actual:
		if pausa_activa:
			if dialogo_player_actual.playing and not dialogo_player_actual.stream_paused:
				dialogo_player_actual.stream_paused = true
				print("Diálogo pausado por menú de pausa.")
		else:
			if dialogo_player_actual.stream_paused:
				dialogo_player_actual.stream_paused = false
				print("Diálogo reanudado tras salir de pausa.")

	# Efectos: mutear/reanudar el bus "Efectos"
	var efectos_idx = AudioServer.get_bus_index("Efectos")
	if efectos_idx != -1:
		AudioServer.set_bus_mute(efectos_idx, pausa_activa)
		if pausa_activa:
			print("Bus 'Efectos' silenciado por pausa.")
		else:
			print("Bus 'Efectos' reactivado tras salir de pausa.")

	# Dialogos: mutear/reanudar el bus "Dialogos" si existe
	if dialogos_bus != -1:
		AudioServer.set_bus_mute(dialogos_bus, pausa_activa)
		if pausa_activa:
			print("Bus 'Dialogos' silenciado por pausa.")
		else:
			print("Bus 'Dialogos' reactivado tras salir de pausa.")


# ---------------------------------------------------------
# Ajustes popup
# ---------------------------------------------------------
func set_ajustes_popup_abierto(valor: bool) -> void:
	ajustes_popup_abierto = valor
	var efectos_idx = AudioServer.get_bus_index("Efectos")

	if ajustes_popup_abierto:
		# Pausar diálogo
		if dialogo_player_actual:
			if dialogo_player_actual.playing and not dialogo_player_actual.stream_paused:
				dialogo_player_actual.stream_paused = true
				_dialogo_pausado_por_ajustes = true
				print("Diálogo pausado por ajustes.")
			else:
				_dialogo_pausado_por_ajustes = false
		else:
			_dialogo_pausado_por_ajustes = false

		# Mutear efectos
		_efectos_muteados_por_ajustes = false
		if efectos_idx != -1:
			if not AudioServer.is_bus_mute(efectos_idx):
				AudioServer.set_bus_mute(efectos_idx, true)
				_efectos_muteados_por_ajustes = true
				print("Bus 'Efectos' muteado por ajustes.")

		# Mutear dialogos
		_dialogos_muteados_por_ajustes = false
		if dialogos_bus != -1:
			if not AudioServer.is_bus_mute(dialogos_bus):
				AudioServer.set_bus_mute(dialogos_bus, true)
				_dialogos_muteados_por_ajustes = true
				print("Bus 'Dialogos' muteado por ajustes.")

	else:
		# Restaurar diálogo
		if _dialogo_pausado_por_ajustes and dialogo_player_actual and dialogo_player_actual.stream_paused:
			dialogo_player_actual.stream_paused = false
			print("Diálogo reanudado tras cerrar ajustes.")
		_dialogo_pausado_por_ajustes = false

		# Restaurar efectos
		if _efectos_muteados_por_ajustes and efectos_idx != -1 and AudioServer.is_bus_mute(efectos_idx):
			AudioServer.set_bus_mute(efectos_idx, false)
			print("Bus 'Efectos' desmuteado tras cerrar ajustes.")
		_efectos_muteados_por_ajustes = false

		# Restaurar dialogos
		if _dialogos_muteados_por_ajustes and dialogos_bus != -1 and AudioServer.is_bus_mute(dialogos_bus):
			AudioServer.set_bus_mute(dialogos_bus, false)
			print("Bus 'Dialogos' desmuteado tras cerrar ajustes.")
		_dialogos_muteados_por_ajustes = false


# ---------------------------------------------------------
# SFX específicos
# ---------------------------------------------------------
func play_daño(sound: AudioStream) -> void:
	if sound == null:
		return
	var tmp := AudioStreamPlayer.new()
	tmp.stream = sound
	tmp.bus = "Efectos"
	tmp.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().get_root().add_child(tmp)
	tmp.owner = null
	tmp.play()
	var dur := 2.0
	if sound.has_method("get_length"):
		dur = sound.get_length()
	await get_tree().create_timer(dur).timeout
	if tmp and tmp.is_inside_tree():
		tmp.queue_free()


func play_ataque(sound: AudioStream) -> void:
	if sound == null:
		return
	var tmp := AudioStreamPlayer.new()
	tmp.stream = sound
	tmp.bus = "Efectos"
	tmp.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().get_root().add_child(tmp)
	tmp.owner = null
	tmp.play()
	var dur := 2.0
	if sound.has_method("get_length"):
		dur = sound.get_length()
	await get_tree().create_timer(dur).timeout
	if tmp and tmp.is_inside_tree():
		tmp.queue_free()


func play_daño_odette(sonido):
	if sonido == null:
		return
	var sfx = AudioStreamPlayer.new()
	sfx.stream = sonido
	sfx.bus = "Efectos"
	add_child(sfx)
	sfx.process_mode = Node.PROCESS_MODE_ALWAYS
	sfx.owner = null
	sfx.play()
	var dur := 2.0
	if sonido.has_method("get_length"):
		dur = sonido.get_length()
	await get_tree().create_timer(dur).timeout
	if sfx and sfx.is_inside_tree():
		sfx.queue_free()


# ---------------------------------------------------------
# Ejemplo Julieta
# ---------------------------------------------------------
var julieta_player: AudioStreamPlayer = null
var julieta_sounds: Array[AudioStream] = []
var julieta_timer: Timer = null
var julieta_activa: bool = false

func _load_julieta_sounds():
	var paths = ["res://sonidos/julietaEco.wav"]
	julieta_sounds.clear()
	for p in paths:
		if ResourceLoader.exists(p):
			var s = load(p)
			if s:
				julieta_sounds.append(s)
	if julieta_sounds.is_empty():
		push_warning("No se encontraron sonidos de Julieta.")
	else:
		print("Sonidos de Julieta cargados:", julieta_sounds.size())


func play_julieta():
	if julieta_activa:
		return
	if julieta_sounds.is_empty():
		_load_julieta_sounds()
	if julieta_player == null:
		julieta_player = AudioStreamPlayer.new()
		julieta_player.name = "Julieta_Player"
		julieta_player.bus = "Efectos"
		add_child(julieta_player)
	if julieta_timer == null:
		julieta_timer = Timer.new()
		julieta_timer.one_shot = true
		add_child(julieta_timer)
		julieta_timer.timeout.connect(Callable(self, "_on_julieta_timer_timeout"))
	julieta_activa = true
	_play_random_julieta()


func _play_random_julieta():
	if not julieta_activa or julieta_sounds.is_empty():
		return
	var selected_sound: AudioStream = julieta_sounds.pick_random()
	if julieta_player.stream == selected_sound and julieta_sounds.size() > 1:
		selected_sound = julieta_sounds.filter(func(s): return s != selected_sound).pick_random()
	julieta_player.stream = selected_sound
	if selected_sound.has_method("set_loop"):
		selected_sound.set_loop(false)
	var random_pitch := randf_range(0.85, 1.15)
	var random_volume := randf_range(-3.0, 3.0)
	julieta_player.pitch_scale = random_pitch
	julieta_player.volume_db = random_volume
	julieta_player.play()
	var dur := 5.0
	if selected_sound.has_method("get_length"):
		dur = selected_sound.get_length()
	var next_delay := dur + randf_range(0.2, 1.0)
	julieta_timer.start(next_delay)


func _on_julieta_timer_timeout():
	if not julieta_activa:
		return
	_play_random_julieta()


func stop_julieta():
	if julieta_player and julieta_player.playing:
		julieta_player.stop()
	if julieta_timer:
		julieta_timer.stop()
	julieta_activa = false
	print("Llanto de Julieta detenido.")


func _on_scene_changed_global(new_scene = null):
	# detener sonido de Julieta (tu codigo)
	if julieta_activa:
		stop_julieta()
		print("Escena cambiada → llanto de Julieta detenido.")

	# Si hay un diálogo en curso, pararlo y emitir terminado (limpieza)
	if dialogo_player_actual:
		print("[AudioManager] Escena cambiada → deteniendo diálogo activo.")
		var path := ""
		if dialogo_player_actual.stream:
			path = dialogo_player_actual.stream.resource_path
		dialogo_player_actual.stop()
		if dialogo_player_actual.is_inside_tree():
			dialogo_player_actual.queue_free()
		dialogo_player_actual = null
		dialogo_en_progreso = false
		last_dialog_stream_path = ""
		emit_signal("dialogo_terminado", path)



# ---------------------------------------------------------
# Música
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


# ---------------------------------------------------------
# Reactivar audio total
# ---------------------------------------------------------
func _reactivar_audio_total() -> void:
	var master_idx = AudioServer.get_bus_index("Master")
	if master_idx != -1 and AudioServer.is_bus_mute(master_idx):
		AudioServer.set_bus_mute(master_idx, false)
		print("Bus MASTER reactivado.")

	if musica_player and musica_player.stream_paused:
		musica_player.stream_paused = false
		print("Música reanudada.")

	if dialogo_player_actual and dialogo_player_actual.stream_paused:
		dialogo_player_actual.stream_paused = false
		print("Diálogo reanudado.")

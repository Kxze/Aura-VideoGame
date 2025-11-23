extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var label: RichTextLabel = $Panel/RichTextLabel

var audio_player: AudioStreamPlayer = null
var subtitles: Array = []
var current_index := -1

@export var fade_duration := 0.3
var fade_timer := 0.0
var fading_in := false
var fading_out := false

# DICCIONARIO DE SUBTÍTULOS
# IMPORTANTE: Las claves (ej: "Aura2-RV.wav") deben ser IDÉNTICAS al nombre del archivo.
var subtitulos_por_audio = {
	"Aura2-RV.wav": [
		{"time": 0.0, "text": "Tantos cuentos de caballeros, y aún así"},
		{"time": 2.0, "text": "niguno pudo protegerlo a él"},
		{"time": 4.0, "text": "ni siquiera yo."}
	],
	"Aura3-RV.wav": [
		{"time": 0.0, "text": "Ahora sí, avanzamos más rápido."},
		{"time": 1.8, "text": "No pierdas de vista el objetivo."},
		{"time": 3.5, "text": "¡Sigue así!"}
	],
	"Aura4-RV.wav": [
		{"time": 0.0, "text": "Este es un momento crítico."},
		{"time": 2.5, "text": "Debemos concentrarnos mucho."},
		{"time": 5.0, "text": "Casi lo logramos."}
	]
}

func _ready():
	# Forzamos que se oculte al arrancar el juego
	if panel:
		panel.visible = false
		print("🙈 SubtitleManager: Panel ocultado al inicio.")
	
	if label:
		label.text = ""
		label.modulate.a = 0.0

	# Conectamos con el AudioManager
	var am = get_node_or_null("/root/AudioManager")
	if am:
		# Aseguramos que no haya señales duplicadas
		if not am.is_connected("dialogo_iniciado_con_stream", Callable(self, "_on_dialogo_iniciado")):
			am.connect("dialogo_iniciado_con_stream", Callable(self, "_on_dialogo_iniciado"))
	else:
		print("⚠️ SubtitleManager: No se encontró '/root/AudioManager'")

	set_process(false)

# --- FUNCIÓN CORREGIDA PARA RECIBIR SOLO STREAM ---
func _on_dialogo_iniciado(stream: AudioStream) -> void:
	var am = get_node_or_null("/root/AudioManager")
	
	# Verificamos que exista el AudioManager y el player
	if am == null or am.dialogo_player_actual == null:
		return

	audio_player = am.dialogo_player_actual
	current_index = -1

	# 1. OBTENEMOS EL NOMBRE DEL ARCHIVO DESDE EL STREAM
	# Esto convierte "res://dialogos/Aura/Aura2-RV.wav" en "Aura2-RV.wav"
	var nombre_audio = stream.resource_path.get_file()
	
	print("🎧 Subtítulos detectaron archivo: ", nombre_audio)

	# 2. BUSCAMOS EN EL DICCIONARIO
	subtitles = subtitulos_por_audio.get(nombre_audio, [])

	# 3. SI NO HAY SUBTÍTULOS, NOS SALIMOS
	if subtitles.size() == 0:
		print("❌ No hay texto configurado para: ", nombre_audio)
		if panel: 
			panel.visible = false
		set_process(false)
		return

	# 4. SI HAY SUBTÍTULOS, MOSTRAMOS EL PANEL
	print("✅ Cargando subtítulos...")
	if panel:
		panel.visible = true
	if label:
		label.text = ""
		label.modulate.a = 0.0

	fading_in = true
	fade_timer = 0.0
	set_process(true)

func _process(delta: float) -> void:
	# Si el player desapareció (se liberó) o dejó de sonar
	if not audio_player or not is_instance_valid(audio_player):
		_clear_and_stop()
		return
		
	if not audio_player.playing and not audio_player.stream_paused:
		_clear_and_stop()
		return

	# Obtenemos el tiempo actual del audio
	var t = audio_player.get_playback_position()
	_show_subtitle_for_time(t)
	_update_fade(delta)

func _show_subtitle_for_time(current_time: float) -> void:
	# Recorremos los subtítulos que faltan por mostrar
	for i in range(current_index + 1, subtitles.size()):
		var s = subtitles[i]
		# El +0.05 es un pequeño margen para asegurar que salga a tiempo
		if current_time + 0.05 >= s["time"]:
			if label:
				label.text = s["text"]
			current_index = i
		else:
			# Como están ordenados por tiempo, si no toca el actual, no toca ninguno siguiente
			break

func _update_fade(delta: float) -> void:
	if fading_in:
		fade_timer += delta
		if label:
			label.modulate.a = clamp(fade_timer / fade_duration, 0.0, 1.0)
		if fade_timer >= fade_duration:
			fading_in = false
			
	elif fading_out:
		fade_timer += delta
		if label:
			label.modulate.a = clamp(1.0 - (fade_timer / fade_duration), 0.0, 1.0)
		if fade_timer >= fade_duration:
			if panel:
				panel.visible = false
			fading_out = false
			set_process(false) # Dejamos de procesar al terminar el fade out

func _clear_and_stop() -> void:
	# Iniciamos la secuencia de salida
	if not fading_out and panel and panel.visible:
		fading_out = true
		fade_timer = 0.0
		audio_player = null # Desconectamos la referencia
	else:
		# Si ya estaba oculto, solo aseguramos
		set_process(false)

# --- AGREGA ESTO AL FINAL DE SubtitleManager.gd ---
func _input(event):
	# Si presionas ESPACIO, forzamos que suene el audio y salga el subtítulo
	if event.is_action_pressed("ui_accept"): # Barra espaciadora o Enter
		print("🧪 PRUEBA: Forzando diálogo Aura2-RV con barra espaciadora")
		
		# CARGA AQUÍ UN AUDIO QUE SEPAS QUE EXISTE 100%
		var audio_prueba = load("res://dialogos/Aura/Aura2-RV.wav") 
		
		if audio_prueba:
			var am = get_node("/root/AudioManager")
			am.play_dialogo_aura(audio_prueba)
		else:
			print("❌ ERROR: No encontré el audio para la prueba. Revisa la ruta en _input")

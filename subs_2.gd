extends CanvasLayer

# Referencias a las 4 etiquetas
@onready var label_1: RichTextLabel = $RichTextLabel
@onready var label_2: RichTextLabel = $RichTextLabel2
@onready var label_3: RichTextLabel = $RichTextLabel3
@onready var label_4: RichTextLabel = $RichTextLabel4

func _ready() -> void:
	# 1. Ocultamos todo al inicio
	label_1.visible = false
	label_2.visible = false
	label_3.visible = false
	label_4.visible = false
	
	# 2. Iniciamos la secuencia automáticamente
	_iniciar_secuencia()

func _iniciar_secuencia() -> void:
	# --- FRASE 1 ---
	label_1.visible = true
	await _esperar_pausable(3.0) 
	label_1.visible = false
	
	# --- FRASE 2 ---
	label_2.visible = true
	await _esperar_pausable(1.0)
	label_2.visible = false
	
	# --- FRASE 3 ---
	label_3.visible = true
	await _esperar_pausable(2.0)
	label_3.visible = false
	
	# --- FRASE 4 ---
	label_4.visible = true
	await _esperar_pausable(3.0)
	label_4.visible = false
	
	# -------------------------------------------------------------
	# CORRECCIÓN DE SINCRONIZACIÓN
	# -------------------------------------------------------------
	# Verificamos si el audio sigue sonando (por si dura más de 9 segundos)
	if AudioManager.dialogo_player_actual and AudioManager.dialogo_player_actual.playing:
		await AudioManager.dialogo_terminado
	# -------------------------------------------------------------

	# 3. Al terminar, eliminamos los subtítulos
	queue_free()

# --- FUNCIÓN DE ESPERA INTELIGENTE Y REACTIVA ---
func _esperar_pausable(tiempo_objetivo: float) -> void:
	var tiempo_actual = 0.0
	
	while tiempo_actual < tiempo_objetivo:
		await get_tree().process_frame
		
		# --- ACTUALIZACIÓN EN TIEMPO REAL ---
		# Ocultamos o mostramos todo el CanvasLayer según la opción del menú
		visible = AudioManager.mostrar_subtitulos
		
		# Solo avanzamos el tiempo si el popup NO está abierto
		if not AudioManager.ajustes_popup_abierto:
			tiempo_actual += get_process_delta_time()

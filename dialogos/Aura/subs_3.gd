extends CanvasLayer

# Referencias a tus 4 etiquetas de texto
@onready var label_1: RichTextLabel = $RichTextLabel
@onready var label_2: RichTextLabel = $RichTextLabel2
@onready var label_3: RichTextLabel = $RichTextLabel3
@onready var label_4: RichTextLabel = $RichTextLabel4

func _ready() -> void:
	# NOTA: Quitamos el "queue_free" del inicio.
	# Ahora permitimos que el script exista aunque los subtítulos estén apagados,
	# pero estarán invisibles. Así, si el jugador los activa a mitad, aparecerán.

	# 1. Ocultamos todo al iniciar
	label_1.visible = false
	label_2.visible = false
	label_3.visible = false
	label_4.visible = false
	
	# 2. Arrancamos la secuencia
	_iniciar_secuencia()

func _iniciar_secuencia() -> void:
	# --- PARTE 1 ---
	label_1.visible = true
	await _esperar_pausable(2.0) 
	label_1.visible = false
	
	# --- PARTE 2 ---
	label_2.visible = true
	await _esperar_pausable(2.0)
	label_2.visible = false
	
	# --- PARTE 3 ---
	label_3.visible = true
	await _esperar_pausable(2.0)
	label_3.visible = false
	
	# --- PARTE 4 ---
	label_4.visible = true
	await _esperar_pausable(3.0)
	label_4.visible = false
	
	# 3. Limpieza final
	queue_free()

# --- FUNCIÓN DE ESPERA INTELIGENTE Y REACTIVA ---
func _esperar_pausable(tiempo_objetivo: float) -> void:
	var tiempo_actual = 0.0
	
	while tiempo_actual < tiempo_objetivo:
		await get_tree().process_frame
		
		# --- NUEVO: ACTUALIZACIÓN EN TIEMPO REAL ---
		# En cada frame, verificamos si el interruptor está encendido o apagado.
		# Como este script es un CanvasLayer, "visible = false" oculta todo lo que tiene dentro.
		visible = AudioManager.mostrar_subtitulos
		# -------------------------------------------
		
		# Solo sumamos tiempo si el popup NO está abierto
		if not AudioManager.ajustes_popup_abierto:
			tiempo_actual += get_process_delta_time()

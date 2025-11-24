extends CanvasLayer 

# Referencias a tus etiquetas de texto
@onready var label_1: RichTextLabel = $RichTextLabel
@onready var label_2: RichTextLabel = $RichTextLabel2
@onready var label_3: RichTextLabel = $RichTextLabel3

func _ready() -> void:
	# 1. Ocultamos todos al inicio
	label_1.visible = false
	label_2.visible = false
	label_3.visible = false
	
	# 2. Iniciamos la secuencia
	iniciar_secuencia_subtitulos()

func iniciar_secuencia_subtitulos() -> void:
	# --- FRASE 1 ---
	label_1.visible = true
	await _esperar_pausable(2.5) 
	label_1.visible = false
	
	# --- FRASE 2 ---
	label_2.visible = true
	await _esperar_pausable(3.0)
	label_2.visible = false
	
	# --- FRASE 3 ---
	label_3.visible = true
	await _esperar_pausable(3.0) 
	label_3.visible = false
	
	# -------------------------------------------------------------
	# CORRECCIÓN PARA EVITAR CORTES DE AUDIO
	# -------------------------------------------------------------
	# Si desactivaste los subtítulos, este código llega aquí muy rápido.
	# Pero el audio puede seguir sonando. Antes de borrar este nodo,
	# verificamos si el AudioManager sigue ocupado.
	
	if AudioManager.dialogo_player_actual and AudioManager.dialogo_player_actual.playing:
		# El audio sigue sonando. Esperamos la señal de que terminó.
		await AudioManager.dialogo_terminado

	# -------------------------------------------------------------
	
	# 3. Ahora sí, es seguro borrar la escena
	queue_free()

# --- FUNCIÓN DE ESPERA INTELIGENTE Y REACTIVA ---
func _esperar_pausable(tiempo_objetivo: float) -> void:
	var tiempo_actual = 0.0
	
	while tiempo_actual < tiempo_objetivo:
		await get_tree().process_frame
		
		# --- ACTUALIZACIÓN EN TIEMPO REAL ---
		# Ocultamos o mostramos todo el CanvasLayer según la opción del menú
		visible = AudioManager.mostrar_subtitulos
		
		# Si el popup de ajustes está abierto, NO sumamos tiempo (se congela)
		if not AudioManager.ajustes_popup_abierto:
			tiempo_actual += get_process_delta_time()

extends CanvasLayer 

# Referencias a tus etiquetas de texto
@onready var label_1: RichTextLabel = $RichTextLabel
@onready var label_2: RichTextLabel = $RichTextLabel2
@onready var label_3: RichTextLabel = $RichTextLabel3

func _ready() -> void:
	# NOTA: Ya no borramos el nodo al inicio.
	# Lo mantenemos vivo (pero invisible si la opción está apagada) para poder activarlo después.

	# 1. Ocultamos todos al inicio por seguridad
	label_1.visible = false
	label_2.visible = false
	label_3.visible = false
	
	# 2. Iniciamos la secuencia
	iniciar_secuencia_subtitulos()

func iniciar_secuencia_subtitulos() -> void:
	# --- FRASE 1 ---
	label_1.visible = true
	# Usamos la espera inteligente (2.5 seg)
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
	
	# 3. Al terminar, borramos la escena
	queue_free()

# --- FUNCIÓN DE ESPERA INTELIGENTE Y REACTIVA ---
func _esperar_pausable(tiempo_objetivo: float) -> void:
	var tiempo_actual = 0.0
	
	while tiempo_actual < tiempo_objetivo:
		await get_tree().process_frame
		
		# --- ACTUALIZACIÓN EN TIEMPO REAL ---
		# Ocultamos o mostramos todo el CanvasLayer según la opción del menú
		visible = AudioManager.mostrar_subtitulos
		# ------------------------------------

		# Si el popup de ajustes está abierto, NO sumamos tiempo (se congela)
		if not AudioManager.ajustes_popup_abierto:
			tiempo_actual += get_process_delta_time()

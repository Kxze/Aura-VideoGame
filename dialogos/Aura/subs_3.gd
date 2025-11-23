extends CanvasLayer

# Referencias a tus 4 etiquetas de texto
@onready var label_1: RichTextLabel = $RichTextLabel
@onready var label_2: RichTextLabel = $RichTextLabel2
@onready var label_3: RichTextLabel = $RichTextLabel3
@onready var label_4: RichTextLabel = $RichTextLabel4

func _ready() -> void:
	# 1. Ocultamos todo al iniciar para que no se vea nada de golpe
	label_1.visible = false
	label_2.visible = false
	label_3.visible = false
	label_4.visible = false
	
	# 2. Arrancamos la secuencia
	_iniciar_secuencia()

func _iniciar_secuencia() -> void:
	# --- PARTE 1 ---
	label_1.visible = true
	# IMPORTANTE: Cambia el 3.0 por los segundos que dura esta frase en el audio
	await get_tree().create_timer(2.0).timeout 
	label_1.visible = false
	
	# --- PARTE 2 ---
	label_2.visible = true
	await get_tree().create_timer(2.0).timeout
	label_2.visible = false
	
	# --- PARTE 3 ---
	label_3.visible = true
	await get_tree().create_timer(2.0).timeout
	label_3.visible = false
	
	# --- PARTE 4 ---
	label_4.visible = true
	await get_tree().create_timer(3.0).timeout # La última suele durar un poco más
	label_4.visible = false
	
	# 3. Limpieza final
	queue_free()

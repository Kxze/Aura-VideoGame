extends CanvasLayer # O Node2D, dependiendo de qué sea tu nodo raíz "subs1"

# Referencias a tus etiquetas de texto
@onready var label_1: RichTextLabel = $RichTextLabel
@onready var label_2: RichTextLabel = $RichTextLabel2
@onready var label_3: RichTextLabel = $RichTextLabel3

func _ready() -> void:
	# 1. Ocultamos todos al inicio por seguridad
	label_1.visible = false
	label_2.visible = false
	label_3.visible = false
	
	# 2. Iniciamos la secuencia
	iniciar_secuencia_subtitulos()

func iniciar_secuencia_subtitulos() -> void:
	# --- FRASE 1 ---
	label_1.visible = true
	# Ajusta el tiempo (3.0) a lo que dure el audio de esta parte
	await get_tree().create_timer(2.5).timeout 
	label_1.visible = false
	
	# --- FRASE 2 ---
	label_2.visible = true
	await get_tree().create_timer(3.0).timeout
	label_2.visible = false
	
	# --- FRASE 3 ---
	label_3.visible = true
	await get_tree().create_timer(3.0).timeout # Quizás la última dure más
	label_3.visible = false
	
	# 3. Al terminar, borramos la escena de subtítulos para liberar memoria
	queue_free()

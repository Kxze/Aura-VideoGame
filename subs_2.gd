extends CanvasLayer

# Referencias a las 4 etiquetas que se ven en tu foto
@onready var label_1: RichTextLabel = $RichTextLabel
@onready var label_2: RichTextLabel = $RichTextLabel2
@onready var label_3: RichTextLabel = $RichTextLabel3
@onready var label_4: RichTextLabel = $RichTextLabel4

func _ready() -> void:
	# 1. Ocultamos todo al inicio por seguridad
	label_1.visible = false
	label_2.visible = false
	label_3.visible = false
	label_4.visible = false
	
	# 2. Iniciamos la secuencia automáticamente
	_iniciar_secuencia()

func _iniciar_secuencia() -> void:
	# --- FRASE 1 ---
	label_1.visible = true
	# Cambia el '3.0' por lo que dure el audio de esta parte
	await get_tree().create_timer(3.0).timeout 
	label_1.visible = false
	
	# --- FRASE 2 ---
	label_2.visible = true
	await get_tree().create_timer(1.0).timeout
	label_2.visible = false
	
	# --- FRASE 3 ---
	label_3.visible = true
	await get_tree().create_timer(2.0).timeout
	label_3.visible = false
	
	# --- FRASE 4 ---
	label_4.visible = true
	await get_tree().create_timer(3.0).timeout
	label_4.visible = false
	
	# 3. Al terminar, eliminamos los subtítulos de la memoria
	queue_free()

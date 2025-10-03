extends Control
@onready var click_sound = preload("res://sonidos/botón2.wav")   # 🔊 sonido click

func _ready():
	# Conectar botones
	$flecha_izq.pressed.connect(_on_flecha_izq_pressed)
	$salir.pressed.connect(_on_salir_pressed)

func _input(event):
	# Navegar con teclado
	if event.is_action_pressed("ui_left"):  # tecla Flecha Derecha
		get_tree().change_scene_to_file("res://scenes/coleccionista2.tscn")
	elif event.is_action_pressed("ui_cancel"):  # tecla Esc
		get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")

# Funciones de botones
func _on_flecha_izq_pressed():
	_play_click()
	get_tree().change_scene_to_file("res://scenes/coleccionista2.tscn")

func _on_salir_pressed():
	_play_click()
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")

# --- 🔊 Reproducir sonidos ---
func _play_click():
	AudioManager.play_click(click_sound)

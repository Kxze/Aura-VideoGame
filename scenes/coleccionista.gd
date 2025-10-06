extends Control

@onready var click_sound = preload("res://sonidos/botón2.wav")   # 🔊 sonido click

func _ready():
	# Conectar botones
	$flecha_der.pressed.connect(_on_flecha_der_pressed)
	$salir.pressed.connect(_on_salir_pressed)

func _input(event):
	# Navegar con teclado
	if event.is_action_pressed("ui_right"):  # Flecha Derecha
		_play_click()  # 🔊 ahora también suena
		get_tree().change_scene_to_file("res://scenes/coleccionista2.tscn")

	elif event.is_action_pressed("ui_cancel"):  # Esc
		_play_click()  # 🔊 suena al regresar
		get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")

# --- Funciones de botones ---
func _on_flecha_der_pressed():
	_play_click()
	get_tree().change_scene_to_file("res://scenes/coleccionista2.tscn")

func _on_salir_pressed():
	_play_click()
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")

# --- 🔊 Reproducir sonido ---
func _play_click():
	AudioManager.play_click(click_sound)

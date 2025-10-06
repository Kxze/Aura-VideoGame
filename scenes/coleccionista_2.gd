extends Control

@onready var click_sound = preload("res://sonidos/botón2.wav")   # 🔊 sonido click

func _ready():
	# Conectar botones
	$flecha_der.pressed.connect(_on_flecha_der_pressed)
	$flecha_izq.pressed.connect(_on_flecha_izq_pressed)
	$salir.pressed.connect(_on_salir_pressed)

func _input(event):
	# Navegar con teclado
	if event.is_action_pressed("ui_right"):  # 👉 Flecha Derecha
		_play_click()
		get_tree().change_scene_to_file("res://scenes/coleccionista3.tscn")

	elif event.is_action_pressed("ui_left"):  # 👈 Flecha Izquierda
		_play_click()
		get_tree().change_scene_to_file("res://scenes/coleccionista.tscn")

	elif event.is_action_pressed("ui_cancel"):  # ⎋ tecla Esc
		_play_click()
		get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")

# --- Funciones de botones ---
func _on_flecha_der_pressed():
	_play_click()
	get_tree().change_scene_to_file("res://scenes/coleccionista3.tscn")

func _on_flecha_izq_pressed():
	_play_click()
	get_tree().change_scene_to_file("res://scenes/coleccionista.tscn")

func _on_salir_pressed():
	_play_click()
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")

# --- 🔊 Reproducir sonido ---
func _play_click():
	AudioManager.play_click(click_sound)

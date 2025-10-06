extends Control

@onready var click_sound = preload("res://sonidos/botón2.wav")
@onready var sonido_cambio_pagina = preload("res://sonidos/cambioPagina.wav")

func _ready():
	# Conectar botones
	$flecha_izq.pressed.connect(_on_flecha_izq_pressed)
	$salir.pressed.connect(_on_salir_pressed)

func _input(event):
	# 👈 Navegar con Flecha Izquierda
	if event.is_action_pressed("ui_left"):
		_play_click()
		_play_cambio_pagina_y_cambiar("res://scenes/coleccionista2.tscn")

	# ⎋ Regresar con tecla Esc
	elif event.is_action_pressed("ui_cancel"):
		_play_click()
		get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")

# --- Botones ---
func _on_flecha_izq_pressed():
	_play_click()
	_play_cambio_pagina_y_cambiar("res://scenes/coleccionista2.tscn")

func _on_salir_pressed():
	_play_click()
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")

# --- 🔊 Sonidos ---
func _play_click():
	if AudioManager:
		AudioManager.play_click(click_sound)

func _play_cambio_pagina_y_cambiar(scene_path: String):
	if AudioManager:
		# 🔊 Suena el cambio de página de manera persistente
		AudioManager.play_sfx_persistente(sonido_cambio_pagina)

	# Cambia de escena al instante (el sonido no se corta)
	get_tree().change_scene_to_file(scene_path)

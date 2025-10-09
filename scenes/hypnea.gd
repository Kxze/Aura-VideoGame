extends Control

@export var next_scene_path: String = "res://scenes/menu_tap.tscn"
@export var delay_time: float = 3.0  # Tiempo de espera antes de cambiar automáticamente

func _ready() -> void:
	# Captura clics dentro del área del Control
	gui_input.connect(_on_gui_input)

	# Inicia temporizador para cambio automático con transición
	var timer := get_tree().create_timer(delay_time)
	timer.timeout.connect(_cambiar_a_menu_con_transicion)

func _on_gui_input(event: InputEvent) -> void:
	# Si es clic izquierdo
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_cambiar_a_menu_con_transicion()

func _unhandled_input(event: InputEvent) -> void:
	# Si se presiona cualquier tecla (excepto volumen)
	if event is InputEventKey and event.pressed and event.keycode not in [KEY_VOLUMEUP, KEY_VOLUMEDOWN]:
		_cambiar_a_menu_con_transicion()
	
	# O clic izquierdo
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_cambiar_a_menu_con_transicion()

func _cambiar_a_menu_con_transicion() -> void:
	# Evita múltiples llamadas
	set_process_input(false)

	# Transición fade a negro antes de cambiar de escena
	var fade := ColorRect.new()
	fade.color = Color.BLACK
	fade.modulate.a = 0.0
	fade.size = get_viewport_rect().size
	add_child(fade)

	var tween := create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(func ():
		get_tree().change_scene_to_file(next_scene_path)
	)

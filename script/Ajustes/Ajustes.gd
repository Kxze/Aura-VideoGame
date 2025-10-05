extends Popup

@onready var popup_ajustes: Popup = $"."
@onready var btn_cerrar: Button = $Panel/BtnCerrar
@onready var btn_continuar: Button = $Panel/BtnContinuar
@onready var btn_inicio: Button = $Panel/BtnInicio
@onready var btn_salir: Button = $Panel/BtnSalir

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Conectamos las señales de los botones
	btn_salir.pressed.connect(_on_btn_salir_pressed)
	btn_inicio.pressed.connect(_on_btn_inicio_pressed)
	btn_continuar.pressed.connect(_on_btn_continuar_pressed)
	btn_cerrar.pressed.connect(_on_btn_cerrar_pressed)

# Mostrar los botones del popup dependiendo del contexto
func mostrar(origen: String):
	match origen:
		"inicio":
			btn_cerrar.visible = true
			btn_continuar.visible = false
			btn_inicio.visible = false
			btn_salir.visible = false
		"pausa":
			btn_cerrar.visible = false
			btn_continuar.visible = true
			btn_inicio.visible = true
			btn_salir.visible = true

#para cerrar la ventana del pop up
func _on_btn_cerrar_pressed() -> void:
	popup_ajustes.visible = false
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")

func _on_btn_continuar_pressed() -> void:
	get_tree().paused = false #por si estaba pausado
	if has_node("/root/UiGlobal"):
		get_node("/root/UiGlobal").cerrar_ajustes()
	else:
		hide()

func _on_btn_inicio_pressed() -> void:
	get_tree().paused = false  #por si estaba pausado
	popup_ajustes.visible = false
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")

func _on_btn_salir_pressed() -> void:
	get_tree().quit()

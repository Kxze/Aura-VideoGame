extends Popup

@onready var popup_ajustes: Popup = $"."
@onready var btn_cerrar: Button = $Panel/BtnCerrar
@onready var btn_continuar: Button = $Panel/BtnContinuar
@onready var btn_inicio: Button = $Panel/BtnInicio
@onready var btn_salir: Button = $Panel/BtnSalir

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
			btn_inicio.visible = false
			btn_salir.visible = false

#para cerrar la ventana del pop up (aún no logro entender pq no sirve
func _on_btn_cerrar_pressed() -> void:
	popup_ajustes.visible = false
	popup_ajustes.hide()
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")

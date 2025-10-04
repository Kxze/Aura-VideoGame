extends CanvasLayer

@onready var btn_pausa: Button = $BtnPausa
@onready var popup_ajustes: Popup = $Popup_Ajustes

#Lista de escenas donde el botón de pausa NO debe mostrarse
var escenas_sin_pausa := [
	"res://scenes/coleccionista.tscn",
	"res://scenes/hypneaGames.tscn",
	"res://scenes/menu_principal.tscn",
	"res://scenes/partidas.tscn"
	]

func _ready() -> void:
	if popup_ajustes:
		popup_ajustes.hide()
	if btn_pausa:
		btn_pausa.visible = true
	else:
		push_warning("⚠️ No se encontró el ButtonPause en UI_Global")
	
	#Llamamos a la función para actualizar visibilidad
	_actualizar_visibilidad()
	#Escuchamos cuando cambie la escena para actualizar el botón
	get_tree().connect("current_scene_changed", Callable(self, "_actualizar_visibilidad"))
	
func _actualizar_visibilidad() -> void:
	if not btn_pausa:
		return
	var escena_actual := get_tree().current_scene
	if not escena_actual:
		btn_pausa.visible = false
		return
	var ruta_escena := escena_actual.scene_file_path
	btn_pausa.visible = not escenas_sin_pausa.has(ruta_escena)

	
# Cada vez que cambia la escena, verificamos si debe mostrarse el botón
func _notification(what):
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_actualizar_visibilidad()

func _on_btn_pausa_pressed() -> void:
	get_tree().paused = !get_tree().paused
	popup_ajustes.visible = get_tree().paused
	UiGlobal.popup_ajustes.mostrar("pausa")
	popup_ajustes.visible = true
	btn_pausa.visible = false

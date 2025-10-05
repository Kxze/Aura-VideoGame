extends CanvasLayer

@onready var click_sound = preload("res://sonidos/botón2.wav")
@onready var btn_pausa: Button = $BtnPausa
@onready var popup_ajustes: Popup = $Popup_Ajustes

#Lista de escenas donde el botón de pausa NO debe mostrarse
var escenas_sin_pausa := [
	"res://scenes/coleccionista.tscn",
	"res://scenes/coleccionista2.tscn",
	"res://scenes/coleccionista3.tscn",
	"res://scenes/hypneaGames.tscn",
	"res://scenes/menu_principal.tscn",
	"res://scenes/partidas.tscn",
	"res://scenes/menu_tap.tscn"
	]
	
#Guarda si se abrió desde el menú o desde pausa
var origen_popup := ""

func _ready() -> void:
	popup_ajustes.hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	_actualizar_visibilidad()
	get_tree().connect("scene_changed", Callable(self, "_actualizar_visibilidad"))
	

func _actualizar_visibilidad() -> void:
	var escena_actual = get_tree().current_scene.scene_file_path
	btn_pausa.visible = not escenas_sin_pausa.has(escena_actual)

#Llamado desde cualquier parte (menú o botón pausa)
func mostrar_ajustes(origen: String = "pausa") -> void:
	origen_popup = origen
	popup_ajustes.show()
	if origen == "pausa":
		get_tree().paused = true
		btn_pausa.hide()

#Cierra el popup y actúa según desde dónde se abrió
func cerrar_ajustes() -> void:
	popup_ajustes.hide()
	if origen_popup == "pausa":
		get_tree().paused = false
		btn_pausa.show()

func _on_btn_pausa_pressed() -> void:
	_play_click()
	mostrar_ajustes("pausa")
	UiGlobal.popup_ajustes.mostrar("pausa")

func _play_click():
	return AudioManager.play_click(click_sound)

extends CanvasLayer

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
	"res://scenes/cinematica_incial.tscn",
	"res://scenes/menu_tap.tscn"
	]
	
#Guarda si se abrió desde el menú o desde pausa
var origen_popup := ""

func _ready() -> void:
	popup_ajustes.hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	_actualizar_visibilidad()
	get_tree().connect("scene_changed", Callable(self, "_actualizar_visibilidad"))
	# Conectar la señal del popup para saber cuándo se cerró con ESC
	popup_ajustes.connect("cerrado_por_esc", Callable(self, "_on_popup_ajustes_closed"))	
	
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

func cerrar_ajustes(force_continuar: bool = false) -> void:
	popup_ajustes.hide()
	if origen_popup == "pausa" or force_continuar:
		get_tree().paused = false
		btn_pausa.show()

func _on_popup_ajustes_closed() -> void:
	if origen_popup == "pausa":
		get_tree().paused = false
		btn_pausa.show()

func _on_btn_pausa_pressed() -> void:
	mostrar_ajustes("pausa")
	popup_ajustes.mostrar_banners("pausa")

#Detectar tecla Esc solo para abrir
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			# Abrir popup si no está visible
			if not popup_ajustes.visible and btn_pausa.visible:
				mostrar_ajustes("pausa")
				popup_ajustes.mostrar_banners("pausa")

extends GridContainer

@onready var check_btn: CheckButton = $CheckModo
@onready var option_res: OptionButton = $OptionRES

var prev_selected: int = -1  # Guardará la opción previa

func _ready() -> void:
	check_btn.toggled.connect(_on_check_btn_toggled)
	option_res.item_selected.connect(_on_option_res_item_selected)

func _on_check_btn_toggled(pressed: bool) -> void:
	if pressed:
		# Guardar la opción actual antes de desactivar
		prev_selected = option_res.selected
		option_res.disabled = true
	else:
		# Volver a habilitar y restaurar la opción previa
		option_res.disabled = false
		if prev_selected >= 0:
			option_res.select(prev_selected)
			# Simula que el usuario eligió la opción
			option_res.emit_signal("item_selected", prev_selected)

func _on_option_res_item_selected(index: int) -> void:
	match index:
		2:
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		1:
			DisplayServer.window_set_size(Vector2i(1600, 900))
		0:
			DisplayServer.window_set_size(Vector2i(1152, 648))

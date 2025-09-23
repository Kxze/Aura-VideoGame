extends Popup

#Para cambiar la resolución
func _on_option_res_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(1920,1080))
		1:
			DisplayServer.window_set_size(Vector2i(1600,900))
		2:
			DisplayServer.window_set_size(Vector2i(1152,648))

#Para cambiar el brillo			
func _on_slider_br_value_changed(value: float) -> void:
	AjustesGlobales.update_brillo(value)

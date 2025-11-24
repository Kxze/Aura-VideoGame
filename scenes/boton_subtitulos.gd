extends OptionButton

func _ready() -> void:
	clear()
	add_item("Activados")
	add_item("Desactivados")
	
	if AudioManager.mostrar_subtitulos:
		selected = 0
	else:
		selected = 1

	item_selected.connect(_on_cambio_de_opcion)

func _on_cambio_de_opcion(index: int) -> void:
	if index == 0:
		AudioManager.mostrar_subtitulos = true
	else:
		AudioManager.mostrar_subtitulos = false
	
	# --- PARCHE DE SEGURIDAD ---
	# A veces, al tocar la UI, el foco puede robar input o pausar cosas.
	# Forzamos al AudioManager a actualizar el estado de pausa correctamente.
	if AudioManager.ajustes_popup_abierto:
		# Si el menú está abierto, nos aseguramos de que el audio esté PAUSADO (no detenido/cortado)
		if AudioManager.dialogo_player_actual:
			AudioManager.dialogo_player_actual.stream_paused = true

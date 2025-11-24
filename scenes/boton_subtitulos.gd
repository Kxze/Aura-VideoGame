extends OptionButton

func _ready() -> void:
	# 1. Configurar las opciones (por si no las pusiste en el editor)
	clear()
	add_item("Activados")   # Quedará en índice 0
	add_item("Desactivados") # Quedará en índice 1

	# 2. Leer el estado actual de la memoria (AudioManager)
	# Si ya estaban activados, ponemos la opción 0, si no, la 1.
	if AudioManager.mostrar_subtitulos:
		selected = 0
	else:
		selected = 1

	# 3. Conectamos la señal de cambio
	# Esto avisa a este script cada vez que el jugador cambia la opción
	item_selected.connect(_on_cambio_de_opcion)

func _on_cambio_de_opcion(index: int) -> void:
	# El índice 0 es "Activados", el índice 1 es "Desactivados"
	if index == 0:
		AudioManager.mostrar_subtitulos = true
		print("Opciones: Subtítulos ACTIVADOS")
	else:
		AudioManager.mostrar_subtitulos = false
		print("Opciones: Subtítulos DESACTIVADOS")

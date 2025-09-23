extends Node

signal brillo_actualizado(value)

#Para mandar la señal del brillo
func update_brillo(value):
	emit_signal("brillo_actualizado",value)

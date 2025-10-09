extends Node3D


func _ready() -> void:
	# ⏳ Espera breve antes de reproducir el diálogo (para no solaparlo con transiciones)
	await get_tree().create_timer(1.5).timeout

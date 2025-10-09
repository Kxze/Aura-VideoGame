extends Node3D


func _ready() -> void:
	# ⏳ Espera un poco antes de iniciar el diálogo (para evitar solaparse con efectos de carga)
	await get_tree().create_timer(1.5).timeout

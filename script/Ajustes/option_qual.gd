extends OptionButton

func _ready():
	item_selected.connect(_on_quality_selected)

func _on_quality_selected(index: int) -> void:
	match index:
		0:
			set_calidad_baja()
		1:
			set_calidad_media()
		2:
			set_calidad_alta()

func set_calidad_baja() -> void:
	# Ejemplo: bajar resolución 3D y desactivar efectos
	ProjectSettings.set_setting("rendering/quality/filters/msaa", 0)
	ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", 0)
	ProjectSettings.set_setting("rendering/quality/shadows/directional_shadow_size", 1024)
	print("Calidad baja activada")
	
func set_calidad_media() -> void:
	ProjectSettings.set_setting("rendering/quality/filters/msaa", 2)
	ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", 1)
	ProjectSettings.set_setting("rendering/quality/shadows/directional_shadow_size", 2048)
	print("Calidad media activada")

func set_calidad_alta() -> void:
	ProjectSettings.set_setting("rendering/quality/filters/msaa", 4)
	ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", 2)
	ProjectSettings.set_setting("rendering/quality/shadows/directional_shadow_size", 4096)
	print("Calidad alta activada")

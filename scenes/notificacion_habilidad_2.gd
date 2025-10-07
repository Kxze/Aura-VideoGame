extends CanvasLayer

@onready var img: TextureRect = $Control/TextureRect

@export var fade_in_time := 0.5
@export var visible_time := 4.0     # ⏳ Duración visible en pantalla
@export var fade_out_time := 0.8
@export var slide_pixels := 40.0    # 🎞️ Movimiento vertical durante el fade

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10  # se asegura de flotar sobre todo el HUD
	_start_animation()


func _start_animation() -> void:
	# Estado inicial (transparente y un poco más abajo)
	img.modulate.a = 0.0
	img.position.y += slide_pixels

	var target_y = img.position.y - slide_pixels

	# --- Fade In + subida ---
	var tween_in = create_tween()
	tween_in.tween_property(img, "modulate:a", 1.0, fade_in_time)
	tween_in.parallel().tween_property(img, "position:y", target_y, fade_in_time)
	await tween_in.finished

	# --- Pausa visible ---
	await get_tree().create_timer(visible_time).timeout

	# --- Fade Out + ligera subida final ---
	var tween_out = create_tween()
	tween_out.tween_property(img, "modulate:a", 0.0, fade_out_time)
	tween_out.parallel().tween_property(img, "position:y", target_y - 10, fade_out_time)
	await tween_out.finished

	# 🔚 Liberar nodo cuando termine la animación
	queue_free()

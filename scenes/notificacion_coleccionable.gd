extends CanvasLayer

@onready var img: TextureRect = $Control/TextureRect

@export var fade_in_time := 0.5
@export var visible_time := 4.0
@export var fade_out_time := 0.8
@export var slide_pixels := 40.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10  # Asegura que flote sobre todo
	img.modulate.a = 0.0
	img.position.y += slide_pixels
	_start_animation()

func _start_animation() -> void:
	var tween = create_tween()
	var target_y = img.position.y - slide_pixels

	# Fade in + sube suavemente
	tween.tween_property(img, "modulate:a", 1.0, fade_in_time)
	tween.parallel().tween_property(img, "position:y", target_y, fade_in_time)

	# Visible unos segundos
	tween.tween_interval(visible_time)

	# Fade out + leve subida final
	tween.tween_property(img, "modulate:a", 0.0, fade_out_time)
	tween.parallel().tween_property(img, "position:y", target_y - 10, fade_out_time)

	tween.finished.connect(queue_free)

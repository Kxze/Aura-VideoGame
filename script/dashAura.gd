extends Sprite3D

@export var rainbow_speed := 1.5  # velocidad de cambio de color
var hue := 0.0

func _process(delta):
	# Incrementa el hue con el tiempo
	hue += delta * rainbow_speed
	
	# Mantiene hue entre 0 y 1
	hue = hue - floor(hue)  # equivalente a fract(hue)
	
	# Aplica color arcoíris al sprite
	modulate = Color.from_hsv(hue, 1, 1, 1)

extends Sprite3D

@export var rainbow_speed := 2.0
@export var light_energy := 1.5
@export var light_range := 2.0

var hue := 0.0
var aura_light: OmniLight3D

func _ready():
	# Crear luz que sigue al sprite
	aura_light = OmniLight3D.new()
	add_child(aura_light)
	aura_light.light_energy = light_energy
	aura_light.omni_range = light_range
	aura_light.light_color = Color(1,1,1)

func _process(delta):
	# Cambiar color del sprite
	hue += delta * rainbow_speed
	if hue > 1.0:
		hue = 0.0
	modulate = Color.from_hsv(hue, 1, 1)
	
	# Cambiar color de la luz
	if aura_light:
		aura_light.light_color = Color.from_hsv(hue, 1, 1)

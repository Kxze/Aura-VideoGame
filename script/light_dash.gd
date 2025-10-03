extends SpotLight3D
@onready var dash_light: SpotLight3D = $"."
  # Timer hijo del nodo
@onready var light_timer: Timer = $light_timer

var current_color: Color
var tween : Tween
var current_attenuation: float
var color_blue_light: Color = Color(0.4,0.6,1.0)
func _on_dash_dash_started() -> void:
	current_color = dash_light.light_color
	current_attenuation = dash_light.spot_attenuation
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(dash_light,"light_color",  color_blue_light, .2)\
	.set_ease(Tween.EASE_IN_OUT)\
	.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(dash_light,"spot_attenuation",  -.1, .2)\
	.set_ease(Tween.EASE_IN_OUT)\
	.set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel(false)
	light_timer.start()   # este timer debe tener wait_time = tu duración de dash

func _on_light_timer_timeout() -> void:
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(dash_light,"light_color",  current_color, .2)\
	.set_ease(Tween.EASE_IN_OUT)\
	.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(dash_light,"spot_attenuation",  current_attenuation, .2)\
	.set_ease(Tween.EASE_IN_OUT)\
	.set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel(false)

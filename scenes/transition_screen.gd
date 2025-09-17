extends CanvasLayer

signal transition_finished

@onready var color_rect = $ColorRect
@onready var anim = $AnimationPlayer

func fade_in():
	anim.play("fade_in")

func fade_out():
	anim.play("fade_out")

func _on_animation_finished(anim_name):
	if anim_name == "fade_out":
		emit_signal("transition_finished")

extends PlayerState

@onready var skeleton_sound = preload("res://sonidos/skeleton.mp3")

# ---------------------------------------------------------
func enter(previous_state_path : String, data := {}):
	# 🔊 Reproducir sonido de muerte una sola vez
	_play_skeleton()
	player.animationPlayer.play("Dead")

# ---------------------------------------------------------
func physics_update(delta: float):
	# Evita repetir la animación si ya está sonando o en curso
	if player.health <= 0 and player.animationPlayer.current_animation != "Dead":
		player.animationPlayer.play("Dead")

# ---------------------------------------------------------
func update(_delta: float):
	pass

func handled_input(_event: InputEvent):
	pass

func exit():
	pass

# ---------------------------------------------------------
# Cuando termina la animación "Dead"
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Dead":
		emit_signal("finished", "Idle")

# ---------------------------------------------------------
func _play_skeleton():
	AudioManager.play_skeleton(skeleton_sound)

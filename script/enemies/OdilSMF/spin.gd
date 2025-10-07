extends Odil_state

@onready var giro_sound = preload("res://sonidos/giro1.wav")

var is_spinning_sound_playing := false  # ⚙️ Control interno del sonido
var spin_loop_timer: Timer = null       # ⏱️ Temporizador interno para reiniciar el sonido

func enter(previous_state_path: String, data := {}):
	# 🎬 Animación
	odil.animation.play("Spin")
	odil.isMoving = true

	# 🔊 Reproduce el sonido inicial
	if not is_spinning_sound_playing:
		is_spinning_sound_playing = true
		if AudioManager and AudioManager.has_method("play_spin_odil"):
			AudioManager.play_spin_odil(giro_sound)
			_start_spin_loop(giro_sound)
		else:
			print("⚠️ No se encontró AudioManager o método play_spin_odil().")


func _start_spin_loop(sound: AudioStream) -> void:
	# 🕒 Crear un temporizador que reinicie el sonido antes de que termine
	if spin_loop_timer:
		spin_loop_timer.queue_free()

	spin_loop_timer = Timer.new()
	spin_loop_timer.wait_time = sound.get_length() - 0.05  # reinicia un pelín antes del final
	spin_loop_timer.one_shot = false
	spin_loop_timer.autostart = true
	add_child(spin_loop_timer)
	spin_loop_timer.timeout.connect(
		func ():
			if is_spinning_sound_playing:
				if AudioManager and AudioManager.has_method("play_spin_odil"):
					AudioManager.play_spin_odil(sound)
			else:
				spin_loop_timer.stop()
	)


func physics_update(delta: float):
	# 🩸 Si recibe daño → pasa a estado Angry
	if odil.isHurt:
		emit_signal("finished", "Angry")


func exit():
	# 🛑 Detener loop y sonido
	is_spinning_sound_playing = false
	if spin_loop_timer:
		spin_loop_timer.stop()
		spin_loop_timer.queue_free()
		spin_loop_timer = null

	if AudioManager and AudioManager.has_method("stop_spin_odil"):
		AudioManager.stop_spin_odil()

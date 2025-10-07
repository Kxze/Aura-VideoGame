extends Odil_state
@onready var timer: Timer = $Timer

func enter(previous_state_path: String, data := {}):
	odil.animation.play("Damage")
	odil.isMoving = false
	odil.isInvulnerable = true  # Nueva variable (debes tenerla en el script principal de Odil)
	odil.canDetectPlayer = false  # Si usas detección por área, puedes usar esto
	timer.start()

func physics_update(delta: float):
	pass

func update(_delta: float):
	pass

func handled_input(_event: InputEvent):
	pass

func exit():
	pass

func _on_timer_timeout() -> void:
	odil.isHurt = false
	odil.isInvulnerable = false
	odil.canDetectPlayer = true
	emit_signal("finished", "Spin")

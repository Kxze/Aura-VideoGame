extends Cascanueces_state

@onready var ataque_sound = preload("res://sonidos/ataque.mp3")

func enter(previous_state_path : String, data := {}):
	cascanueces.animaciones.play("Ataque")
	
	# 🔊 Reproduce el sonido de ataque al iniciar la animación
	AudioManager.play_ataque(ataque_sound)

func physics_update(delta: float):
	pass
	
func update(_delta: float):
	pass

func handled_input(_event: InputEvent):
	pass

func exit():
	pass

func _on_espada_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		if cascanueces.animaciones.animation_finished():
			cascanueces.Make_damage(body)
			_play_ataque()

# 🔊 Función interna de sonido al impactar
func _play_ataque():
	AudioManager.play_ataque(ataque_sound)

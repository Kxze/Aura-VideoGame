extends Julieta_state

@onready var julieta_sound = preload("res://sonidos/julieta.ogg")

func enter(previous_state_path : String, data := {}):
	# 🔊 Inicia el llanto en loop al entrar al estado
	AudioManager.play_julieta(julieta_sound)
	julieta.animationPlayer.play("Ataque")

# ---------------------------------------------------------
# Mientras está en este estado, no es necesario repetir el sonido
# porque el AudioManager ya lo mantiene en loop
func physics_update(delta: float):
	pass

func update(_delta: float):
	pass

func handled_input(_event: InputEvent):
	pass

# ---------------------------------------------------------
# 🛑 Cuando sale del estado, detener el sonido
func exit():
	AudioManager.stop_julieta()

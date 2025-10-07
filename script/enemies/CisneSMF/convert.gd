extends CisneState

func enter(previous_state_path: String, data := {}):
	pass
func update(_delta: float):
	cisne.animationCisneBlanco.play("Caminar")
	print("Cisne:curado")
	

func handled_input(_event: InputEvent):
	pass

func exit():
	pass

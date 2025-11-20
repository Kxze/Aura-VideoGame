extends PlayerState

# 1. REFERENCIA AL SONIDO
# Definimos la ruta del sonido que se reproducirá
const LUMIERE_SOUND: AudioStream = preload("res://sonidos/pasDeLumiere4.wav")

var damage: int = 20

#este apartado sobreescribe el estado que viene
func enter(previous_state_path : String, data := {}):
	player.invencible = false
	
#Esta funcion sobreescribe la funcion physics process
func physics_update(delta: float):
	if Input.is_action_pressed("Lumiere"):
		player.animationPlayer.play("Lumiere")
		player.lumiere_area.visible = true
	else:
		emit_signal("finished","Idle")
	
#Esta funcion sobreescribe la funcion process
func update(_delta:float):
	pass
#Esta funcion sobreescribe la funcion Input
func handled_input(_event: InputEvent):
	pass

func exit():
	pass


func _on_lumiere_body_entered(body: Node3D) -> void:
	if body is Cisne and Input.is_action_pressed("Lumiere") and player.can_lumiere:
		
		# Aplica el daño y la transición visual
		body.health -= damage
		body.transitionParticles.emitting = true
		print("HP del cisne:", body.health)
		
		AudioManager.play_sfx(LUMIERE_SOUND)
		
		if body.health <= 0:
			print("Cambiando a cisne blanco")
			
			
			body.isAgressive = false
			body.isPassive = true
			body.change_skins()
			body.area_damage.monitoring = false
			body.collision.set_deferred("disabled",true)

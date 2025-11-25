extends MeshInstance3D

var has_fallen: bool = false
var original_position: Vector3
var damage: int = 1
#cuerdaSaco
@onready var cuerda: MeshInstance3D = $"../cuerdaIz"

@onready var dañoOdette_sound = preload("res://sonidos/golpeOdette.mp3")
@onready var collision_shape_3d: CollisionShape3D = $SacoColIz/CollisionShape3D
@onready var Damage: Area3D = $SacoColIz/Damage
@onready var collision_area: CollisionShape3D = $SacoColIz/Damage/CollisionArea
@onready var luzSaco: SpotLight3D = $"../../SpotSaco"

#Luz y fuego antorchas
@onready var fuego_1: Node3D = $"../../antorcha/Fuego1"
@onready var fuego_2: Node3D = $"../../antorcha2/Fuego2"
@onready var fuego_3: Node3D = $"../../antorcha3/Fuego3"

var upCuerda : Vector3 = Vector3(-16.514,120, -2.316 )
var normalCuerda: Vector3 = Vector3(-16.514,73.339, -2.316 )
var upSaco: Vector3 = Vector3(-15.829, 110, -1.169)
var normalSaco: Vector3 = Vector3(-15.829, 46.806, -1.169)

var luzAmarilla: Color = Color("ffcf81ff")
var luzRoja: Color = Color("ef0030ff")
func _ready():
	original_position = global_position

func _on_activar_plataforma_body_entered(body: Node3D) -> void:
	if body.name == "Player" and not has_fallen:
		has_fallen = true

		var opacity_tween: Tween = create_tween().set_trans(Tween.TRANS_SINE)
		var pos_tween: Tween = create_tween().set_trans(Tween.TRANS_BOUNCE)
		var light_tween: Tween = create_tween().set_trans(Tween.TRANS_SINE)
		
		light_tween.tween_property(luzSaco,"light_color", luzRoja, 0.5)
		opacity_tween.tween_property(self, "transparency", 1, 0.5)
		pos_tween.tween_property(self, "global_position", global_position + Vector3(0, -5, 0), 0.5)
		
		opacity_tween.finished.connect(Callable(self, "_disable_and_respawn"))

func _disable_and_respawn() -> void:
	collision_shape_3d.disabled = true
	collision_area.disabled = true  # 🚫 Desactivar detección del área de daño
	moveUpRope()
	await get_tree().create_timer(5.0).timeout
	_respawn_platform()
	restablecerSaco()
	collision_shape_3d.disabled = false
	collision_area.disabled = false
func _respawn_platform() -> void:
	global_position = upSaco
	transparency = 0
	  # ✅ Volver a activar el área de daño
	var light_tween: Tween = create_tween().set_trans(Tween.TRANS_SINE)
		
	light_tween.tween_property(luzSaco,"light_color", luzAmarilla, 0.5)
	var tween: Tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "transparency", 0, 0.5)
	has_fallen = false
	
# 💢 Reproduce el sonido de daño de Odette y aplica daño
func Make_damage(body: Node3D):
	if not Odil.isInvulnerable:
		_play_dañoOdette()
		Odil.health -= damage
		Odil.isHurt = true
		Odil.isMoving = false
		print("Daño recibido. Salud actual:", Odil.health)
	if Odil.health == 2:
		fuego_1.visible = false
	if Odil.health == 1:
		fuego_2.visible = false
	if Odil.health <= 0:
		fuego_3.visible = false
		print("Odil muere")
		Odil.health = 3
		TransitionScreen.transition()
		await TransitionScreen.on_transition_finished
		get_tree().change_scene_to_file("res://scenes/cinematica_final.tscn")

func _on_damage_body_entered(body: Node3D) -> void:
	if body.name == "Odil" and not collision_area.disabled:
		Make_damage(body)
func restablecerSaco():
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "global_position", normalSaco, 1.5)
	tween.tween_property(cuerda, "global_position", normalCuerda, 1.5)
	
	
func moveUpRope():
	var move: Tween = create_tween().set_trans(Tween.TRANS_ELASTIC)
	move.tween_property(cuerda,"global_position", upCuerda,1)
# 🔊 Llama al AudioManager para reproducir el sonido de daño
func _play_dañoOdette() -> void:
	if AudioManager:
		AudioManager.play_daño_odette(dañoOdette_sound)

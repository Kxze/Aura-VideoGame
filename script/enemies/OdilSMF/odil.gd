extends CharacterBody3D
class_name Odil

static var health = 3
@onready var animation: AnimationPlayer = $Odil/AnimationPlayer
static var isMoving: bool = true
static var isHurt: bool = false
static var isInvulnerable: bool = false
static var canDetectPlayer: bool = true
@onready var target : Node3D = get_tree().get_first_node_in_group("player")
var damage = 1


@export var odilFase3 : bool = false
@export var odilFase2 : bool = false


func Make_damage(body: Node3D):
	Player.health -= damage
	body.jump_side_per_damage(10)
	print("Daño recibido. Salud actual:", Player.health)

	if Player.health <= 0:
		print("Jugador sin vidas... reiniciando nivel")

		if Player.spawnPoint:
			TransitionScreen.transition()
			await TransitionScreen.on_transition_finished
			body.global_position = Player.spawnPoint.global_position
			body.velocity = Vector3.ZERO
			Player.health = 3
			Odil.health = 3
		else:
			TransitionScreen.transition()
			await TransitionScreen.on_transition_finished
			get_tree().reload_current_scene()
			Player.health = 3
			Odil.health = 3


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		Make_damage(body)

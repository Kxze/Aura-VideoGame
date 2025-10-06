class_name CascaNueces
extends CharacterBody3D
#Timer que determina el tiempo que va a estar patrullando el oso
@onready var time_searching: Timer = $StateMachine/Follow/TimeSearching
var player_position: Node3D
@export var speed: float = 25
@onready var navAgent: NavigationAgent3D = $NavigationAgent3D
@export var Target:Node3D
var damage = 1
var Gravity := -1.3
var player
var last_position
@onready var animaciones = $CascanuecesAnimaciones/AnimationPlayer
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var pivot: Node3D = $CascanuecesAnimaciones
#luz que sirve para feeedback visual si el oso detecto al player o no
@onready var estado: OmniLight3D = $estado

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	pass
func _on_cuerpo_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		Make_damage(body)
	
	
func Make_damage(body):
	Player.health -= damage
	body.jump_side_per_damage(1)
	
	print(Player.health)
	if Player.health <= 0:
		print("jugador ya no tiene vidas...muere")
		if Player.spawnPoint:
			TransitionScreen.transition()
			await TransitionScreen.on_transition_finished
			body.global_position = Player.spawnPoint.global_position
			body.velocity = Vector3.ZERO  # Resetear velocidad
			Player.health = 3
		else:
			TransitionScreen.transition()
			await TransitionScreen.on_transition_finished
			get_tree().reload_current_scene()
			Player.health = 3
		


func _on_espada_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		Make_damage(body)

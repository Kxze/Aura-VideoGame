class_name CascaNueces
extends CharacterBody3D

@onready var daño_sound = preload("res://sonidos/daño.wav")

# --- Referencias y parámetros ---
@onready var time_searching: Timer = $StateMachine/Follow/TimeSearching
@onready var navAgent: NavigationAgent3D = $NavigationAgent3D
@onready var animaciones = $CascanuecesAnimaciones/AnimationPlayer
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var pivot: Node3D = $CascanuecesAnimaciones
@onready var estado: OmniLight3D = $estado

@export var Target: Node3D
@export var speed: float = 25
@export var damage: int = 1
var Gravity := -1.3
var player: Node3D
var last_position

# ---------------------------------------------------------
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
	# ✅ Si no se asignó manualmente el Target, buscarlo automáticamente
	if Target == null:
		var player_node = get_tree().get_first_node_in_group("player")
		if player_node:
			Target = player_node
			print("🎯 Cascanueces: Target asignado automáticamente →", Target.name)
		else:
			print("⚠️ Cascanueces: no se encontró el jugador en el grupo 'player'")

# ---------------------------------------------------------
# Cuando el cuerpo del jugador entra en contacto con el área del enemigo
func _on_cuerpo_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		_play_daño()
		Make_damage(body)

# ---------------------------------------------------------
func _on_espada_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		_play_daño()
		Make_damage(body)

# ---------------------------------------------------------
func _play_daño():
	AudioManager.play_daño(daño_sound)

# ---------------------------------------------------------
func Make_damage(body: Node3D):
	Player.health -= damage
	body.jump_side_per_damage(1)
	print("💥 Daño recibido. Salud actual:", Player.health)

	if Player.health <= 0:
		print("☠️ Jugador sin vidas... reiniciando nivel")

		if Player.spawnPoint:
			TransitionScreen.transition()
			await TransitionScreen.on_transition_finished
			body.global_position = Player.spawnPoint.global_position
			body.velocity = Vector3.ZERO
			Player.health = 3
		else:
			TransitionScreen.transition()
			await TransitionScreen.on_transition_finished
			get_tree().reload_current_scene()
			Player.health = 3

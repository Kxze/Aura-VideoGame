class_name Cisne
extends CharacterBody3D


@onready var black: Node3D = $CisneNegro
@onready var white: Node3D = $CisneBlanco
@onready var animationCisneNegro: AnimationPlayer = $CisneNegro/AnimationPlayer
@onready var animationCisneBlanco: AnimationPlayer = $CisneBlanco/AnimationPlayer

@onready var area_damage: Area3D = $AreaDamage
@onready var attack_area: Area3D = $AttackArea

@onready var navAgent: NavigationAgent3D = $NavigationAgent3D
@onready var pivot: Node3D = $CisneNegro


var isAgressive: bool = true
var isPassive: bool = false

@export var Target: Node3D
var speed: int = 20
var health: int = 20
var damage: int = 2
func change_skins():
	black.visible = false
	white.visible = true
	health = 20
	damage = 0
	animationCisneBlanco.play("Caminar")


func Make_damage(body: Node3D):
	Player.health -= damage
	body.jump_side_per_damage(1)
	print("Daño recibido. Salud actual:", Player.health)

	if Player.health <= 0:
		print("Jugador sin vidas... reiniciando nivel")

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


func _on_area_damage_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		Make_damage(body)

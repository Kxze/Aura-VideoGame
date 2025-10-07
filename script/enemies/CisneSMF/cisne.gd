class_name Cisne
extends CharacterBody3D
@onready var black: Node3D = $CisneNegro
@onready var white: Node3D = $CisneBlanco
@onready var animationCisneNegro: AnimationPlayer = $CisneNegro/AnimationPlayer
@onready var animationCisneBlanco: AnimationPlayer = $CisneBlanco/AnimationPlayer
@onready var navAgent: NavigationAgent3D = $NavigationAgent3D

@onready var pivot: Node3D = $CisneNegro
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

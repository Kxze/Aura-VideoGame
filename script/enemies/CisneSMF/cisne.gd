class_name Cisne
extends CharacterBody3D
@onready var black: Node3D = $CisneNegro
@onready var white: Node3D = $CisneBlanco
@onready var animationCisneNegro: AnimationPlayer = $CisneNegro/AnimationPlayer
@onready var animationCisneBlanco: AnimationPlayer = $CisneBlanco/AnimationPlayer

var health: int = 20
var damage: int = 2
func change_skins():
	black.visible = false
	white.visible = true
	health = 20
	damage = 0
	animationCisneBlanco.play("Caminar")

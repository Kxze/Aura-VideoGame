class_name Player
extends CharacterBody3D

signal respawned()

var can_play_steps: bool = true

@export var speed_normal := 4.0
var speed = speed_normal
@export var speed_run := 8.0
@export var jump := 33
@export var GRAVITY := -1.3
@export var acceleration: float = 3
@export var friction: float = 5
@export var color_ghost : Color
var jump_locked := false
var is_dashing := false
static var can_dash := false
var prevVelocity: Vector2 = Vector2.ZERO

# Variable que controla si el jugador puede recibir inputs
var controls_enabled: bool = true

var health: int = 3
var movInput: Vector2 = Vector2.ZERO
var last_facing := 1  # 1 = derecha, -1 = izquierda
static var spawnPoint 

@onready var aura: Node3D = $Aura/player
@onready var animationPlayer = $Aura/player/AnimationPlayer
@onready var sprite: Sprite3D = $AuraGhost
@onready var ray_cast_3d: RayCast3D = $RayCast3D

func _input(_event: InputEvent) -> void:
	movInput.x = Input.get_axis("ui_left","ui_right")

func _process(_delta: float) -> void:
	pass

func take_damage(damage: int):
	health -= damage
	if health <= 0:
		respawned.emit()
		
func set_controls_enabled(enable: bool) -> void:
	controls_enabled = enable
	if not enable:
		# Reiniciar inputs para evitar que el jugador quede flotando
		movInput = Vector2.ZERO
		is_dashing = false
		jump_locked = false
		can_dash = false

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
static var can_lumiere := false
var prevVelocity: Vector2 = Vector2.ZERO
static var lumiere_ready := false
# Variable que controla si el jugador puede recibir inputs
var controls_enabled: bool = true
static var invencible : bool = false
static var health: int = 3
var movInput: Vector2 = Vector2.ZERO
var last_facing := 1  # 1 = derecha, -1 = izquierda
static var spawnPoint 

@onready var aura: Node3D = $Aura/player
@onready var lamp: Sprite3D = $Aura/player/Armature/Skeleton3D/BoneAttachment3D/Sprite3D
@onready var lamp_light: OmniLight3D = $Aura/player/Armature/Skeleton3D/BoneAttachment3D/OmniLight3D2

@onready var animationPlayer = $Aura/player/AnimationPlayer
@onready var sprite: Sprite3D = $AuraGhost
@onready var ray_cast_3d: RayCast3D = $RayCast3D

func _input(_event: InputEvent) -> void:
	movInput.x = Input.get_axis("ui_left","ui_right")

func _process(_delta: float) -> void:
	if can_lumiere:
		lamp.visible = true
		lamp_light.visible = true
	if lumiere_ready:
		_change_light()
	else:
		lamp_light.light_color = Color(0.992,0.862,0.502)
		lamp_light.omni_attenuation = 1
		lamp_light.omni_range = 3.0
		lamp_light.light_energy = 1
	if health < 0:
		animationPlayer.play("Dead")
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

func jump_side_per_damage(x):
	velocity.y = jump
	velocity.x = x

func dead(bool):
	animationPlayer.animation_finished

func _change_light():
	if lumiere_ready:
		lamp_light.light_color = Color(0.4,0.6,1.0)
		lamp_light.omni_attenuation = 1.25
		lamp_light.omni_range = 3.0
		lamp_light.light_energy = 5.0
		


func _on_dash_dash_started() -> void:
	invencible = true


func _on_dash_dash_finished() -> void:
	invencible = false

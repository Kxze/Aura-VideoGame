class_name Player extends CharacterBody3D
#variables for access to the model
@onready var pivot: Sprite3D = $Sprite3D
@onready var animation_player = $Sprite3D/AuraModelo3D/AnimationPlayer
#variables properties for the movement of the player
@export var speed: float = 5
@export var gravity: float = -25
@export var jumpForce: float = 13
@export var jump_Buffer_Time: float = .1  
@export var rotationSpeed: float = 5
var jumpAvailable: bool = true
#variables to improve the experience
var jump_Buffer :  bool = false
@onready var coyote_timer: Timer = $CoyoteTimer
var was_on_floor = is_on_floor()
var direction := Vector3.ZERO

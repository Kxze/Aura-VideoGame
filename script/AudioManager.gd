extends Node

var player: AudioStreamPlayer

func _ready():
	player = AudioStreamPlayer.new()
	add_child(player)

func play_click(sound: AudioStream):
	player.stream = sound
	player.play()

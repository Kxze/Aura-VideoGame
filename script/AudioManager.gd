extends Node

#var player: AudioStreamPlayer
var musica_player: AudioStreamPlayer
var efectos_player: AudioStreamPlayer

func _ready():
	#Player anterior
	#player = AudioStreamPlayer.new()
	#add_child(player)
	
	# Player de música
	musica_player = AudioStreamPlayer.new()
	musica_player.bus = "Musica"
	add_child(musica_player)

	# Player de efectos
	efectos_player = AudioStreamPlayer.new()
	efectos_player.bus = "Efectos"
	add_child(efectos_player)

#func play_click(sound: AudioStream):
	#player.stream = sound
	#player.play()
	
func play_music(sound: AudioStream):
	musica_player.stream = sound
	musica_player.play()

func play_efectos(sound: AudioStream):
	efectos_player.stream = sound
	efectos_player.play()

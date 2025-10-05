extends Node

# --- Players ---
var efectos_player: AudioStreamPlayer
var musica_player: AudioStreamPlayer

# --- Fade config ---
@export var fade_time := 0.8  # segundos para la transición
var fading := false

func _ready():
	# Efectos
	efectos_player = AudioStreamPlayer.new()
	efectos_player.name = "SFX_Player"
	add_child(efectos_player)
	efectos_player.volume_db = +6  # 🔊 volumen normal
	
	# Música
	musica_player = AudioStreamPlayer.new()
	musica_player.name = "Music_Player"
	add_child(musica_player)
	musica_player.volume_db = -4  # 🔉 más bajo que efectos


# --------- SFX ----------
func play_and_get_duration(sound: AudioStream) -> float:
	if sound == null:
		return 0.0
	efectos_player.stream = sound
	efectos_player.play()
	if sound.has_method("get_length"):
		return sound.get_length()
	return 0.0

func play_click(sound: AudioStream) -> float:
	return play_and_get_duration(sound)

func play_hover(sound: AudioStream) -> float:
	return play_and_get_duration(sound)

func play_random_sfx(sounds: Array) -> void:
	if sounds.is_empty():
		return
	var sound = sounds[randi() % sounds.size()]
	play_and_get_duration(sound)


# --------- MÚSICA ----------
func play_music(track: AudioStream, loop := true, crossfade := true) -> void:
	if track == null:
		return
	
	# Si hay música sonando, lanzamos fade out
	if musica_player.playing and crossfade:
		fade_out()  # sin await

	# Configuramos loop
	if track.has_method("set_loop"):
		track.set_loop(loop)
	elif "loop" in track:
		track.loop = loop
	
	musica_player.stream = track
	musica_player.play()
	
	if crossfade:
		fade_in()  # sin await


func stop_music() -> void:
	musica_player.stop()

func pause_music() -> void:
	musica_player.stream_paused = true

func resume_music() -> void:
	musica_player.stream_paused = false


# --------- TRANSICIONES ----------
func fade_out():
	if fading:
		return
	fading = true
	
	var start_vol = musica_player.volume_db
	var timer := 0.0
	
	# usamos un proceso asíncrono manual sin await
	musica_player.set_process(true)
	musica_player.process_mode = Node.PROCESS_MODE_INHERIT
	
	musica_player.connect("process", Callable(self, "_process_fade_out").bind(start_vol), CONNECT_ONE_SHOT)

func _process_fade_out(start_vol: float) -> void:
	var t := 0.0
	while t < fade_time:
		t += get_process_delta_time()
		var vol = lerp(start_vol, -80.0, t / fade_time)
		musica_player.volume_db = vol
		await get_tree().process_frame
	musica_player.stop()
	musica_player.volume_db = start_vol
	fading = false


func fade_in():
	if fading:
		return
	fading = true
	
	musica_player.volume_db = -80.0
	var t := 0.0
	
	# procesar el fade in sin await
	call_deferred("_start_fade_in")

func _start_fade_in():
	var t := 0.0
	while t < fade_time:
		t += get_process_delta_time()
		var vol = lerp(-80.0, -4.0, t / fade_time)
		musica_player.volume_db = vol
		await get_tree().process_frame
	fading = false

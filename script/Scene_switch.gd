extends Node

var next_scene = preload("res://scenes/levels/level_2.tscn")
var current_scene = preload("res://scenes/levels/level_1.tscn")

func _add_a_scene_manually():
	get_tree().root.add_child(next_scene)
	get_tree().root.remove_child(current_scene)

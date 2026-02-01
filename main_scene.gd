extends Node2D

@export var first_level: String = "res://level_0.tscn"

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(first_level)

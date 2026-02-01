extends Node2D

@export var next_scene_path: String

func level_complete():
	get_tree().change_scene_to_file(next_scene_path)

func _ready() -> void:
	$DogCharacter.connect("level_finish_reached", _on_level_finish_reached)

func _on_level_finish_reached() -> void:
	level_complete()

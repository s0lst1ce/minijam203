extends Node2D

@export var next_scene: PackedScene

func level_complete():
	get_tree().change_scene_to_packed(next_scene)

func _ready() -> void:
	$DogCharacter.connect("level_finish_reached", _on_level_finish_reached)

func _on_level_finish_reached() -> void:
	print("ha", next_scene)
	level_complete()

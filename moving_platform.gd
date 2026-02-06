extends Node2D

@export var offset = Vector2(0, -200)
@export var duration = 5.0
@onready var initial_position = position

func _ready() -> void:
	start_tween()

func start_tween():
	var tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_loops().set_parallel(false)
	tween.tween_property($AnimatableBody2D, "position", offset, duration/2)
	tween.tween_property($AnimatableBody2D/Sprite2D, "flip_h", true, 0.1)
	tween.tween_property($AnimatableBody2D, "position", Vector2.ZERO, duration/2)
	tween.tween_property($AnimatableBody2D/Sprite2D, "flip_h", false, 0.1)

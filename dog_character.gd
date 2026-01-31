extends CharacterBody2D

const SPEED: int = 400

var current_mode: int = 0

func set_mode(mode: int):
	current_mode = mode

func refresh_velocity_from_input():
	var input_direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * SPEED

func _physics_process(delta: float) -> void:
	refresh_velocity_from_input()
	move_and_slide()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("cycle_mode"):
		set_collision_layer_value(current_mode + 5, false)
		set_collision_mask_value(current_mode + 5, false)
		current_mode = (current_mode + 1) % 3
		set_collision_layer_value(current_mode + 5, true)
		set_collision_mask_value(current_mode + 5, true)
	

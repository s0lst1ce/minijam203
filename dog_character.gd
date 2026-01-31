extends CharacterBody2D

@onready var screensize = get_viewport_rect().size
@onready var gravity = float(ProjectSettings.get_setting("physics/2d/default_gravity"))


const SPEED: float = 400

var current_mode: int = 0

func set_mode(mode: int):
	current_mode = mode

func refresh_velocity_from_input():
	var input_direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * SPEED


func _physics_process(delta: float) -> void:
	refresh_velocity_from_input()
	#print(velocity)
	
	if not is_on_floor():
		#print(velocity)
		velocity.y += gravity * delta
		#print(velocity)
	
	move_and_slide()
	
	#making sure we stay in-bounds
	position = position.clamp(Vector2(0, 0), screensize)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("cycle_mode"):
		set_collision_layer_value(current_mode + 5, false)
		set_collision_mask_value(current_mode + 5, false)
		current_mode = (current_mode + 1) % 3
		set_collision_layer_value(current_mode + 5, true)
		set_collision_mask_value(current_mode + 5, true)
	

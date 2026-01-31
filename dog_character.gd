extends CharacterBody2D

@onready var screensize = get_viewport_rect().size
@onready var gravity = float(ProjectSettings.get_setting("physics/2d/default_gravity"))

const JUMP_SPEED: float = 300.0
const WALK_POWER: float = 1500.0
const MAX_HSPEED: float = 500.0
const FRICTION: float = 1300.0

# HACK: make this a global so it can be shared across scenes
var current_mode: int = 0

func mode_to_collision(mode: int) -> int:
	assert(mode <=2 and mode >=0)
	return mode + 5

func collision_to_mode(col: int) -> int:
	assert(col>=5 and col<=7)
	return col - 5

func _physics_process(delta: float) -> void:
	#NOTE: float because get_axis may be different than one if we use an analog input (i.e.: joystick)
	var input_way: float = Input.get_axis("left", "right") # which way we point/look to
	var walk_force: float  = WALK_POWER * input_way
	# as such checking if the player wants to move is not simply comparing to +-1
	if abs(input_way) < 0.2:
		# friction -> the player is slowed
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	else:
		velocity.x += walk_force * delta
	
	#we make sure the player can't move too fast (think nominal free-fall velocity, relatetd to friction)
	velocity.x = clamp(velocity.x, -MAX_HSPEED, MAX_HSPEED)

	#apply gravity. We don't need to check for floor because we use a kinematitc body instead of dynamic (=> apply all forces and then get stuff out of objects)
	velocity.y += gravity * delta

	move_and_slide()

	#must be after we apply the other "forces", otherwise the jump will be cut off abruptly
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y -= JUMP_SPEED
	
	#making sure we stay in-bounds
	position = position.clamp(Vector2(0, 0), screensize)

func _process(_delta: float) -> void:
	# TODO: is there a method to test if one of many action is pressed ?
	if Input.is_action_just_pressed("set_to_mode0") or Input.is_action_just_pressed("set_to_mode1") or Input.is_action_just_pressed("set_to_mode2"):
		set_collision_layer_value(mode_to_collision(current_mode), false)
		set_collision_mask_value(mode_to_collision(current_mode), false)

		if Input.is_action_just_pressed("set_to_mode0"):
			current_mode = 0
		elif Input.is_action_just_pressed("set_to_mode1"):
			current_mode = 1
		else:
			current_mode = 2
			

		set_collision_layer_value(mode_to_collision(current_mode), true)
		set_collision_mask_value(mode_to_collision(current_mode), true)

extends CharacterBody2D

@onready var screensize = get_viewport_rect().size
@onready var gravity = float(ProjectSettings.get_setting("physics/2d/default_gravity"))

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: CharacterStateMachine = $CharacterStateMachine

signal level_finish_reached

const WALK_POWER: float = 400.0
const MAX_HSPEED: float = 800.0
const FRICTION: float = 3000.0

# HACK: make this a global so it can be shared across scenes
static var current_mode: int = 0
var last_pushed = []

@onready var sprites_for_each_mode: Array[Sprite2D] = [
	$PurpleSprite2D,
	$GreenSprite2D,
	$OrangeSprite2D,
]

func _ready() -> void:
	animation_tree.active = true

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
	if abs(input_way) < 0.2 || !state_machine.check_if_can_move():
		# friction -> the player is slowed
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	else:
		#if we're changing directions do so immediately, we don't care about inertia
		if velocity.x * input_way< 0:
			velocity.x=0
		velocity.x += walk_force * delta
	
	#we make sure the player can't move too fast (think nominal free-fall velocity, relatetd to friction)
	velocity.x = clamp(velocity.x, -MAX_HSPEED, MAX_HSPEED)

	#apply gravity. We don't need to check for floor because we use a kinematitc body instead of dynamic (=> apply all forces and then get stuff out of objects)
	velocity.y += gravity * delta

	move_and_slide()
	
	# moving obstacles
	var pushed = []
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			var body: RigidBody2D = c.get_collider()
			# we only want to move the obstacles of the same color as the dog
			if shares_mode(body, current_mode):
				# -c because we move the object in the same way as the player. Not the normal which faces the player
				if body.linear_velocity.length() < MAX_HSPEED:
					body.apply_central_force(-c.get_normal()*1000)
					pushed.append(body)

	# removing force if we're not pushing anymore
	for body in last_pushed:
		if !pushed.has(body):
			body.linear_velocity.x = 0
	last_pushed = pushed

	#making sure we stay in-bounds
	position = position.clamp(Vector2(0, 0), screensize)

func shares_mode(collider: CollisionObject2D, mode: int) -> bool:
	return collider.get_collision_layer_value(mode_to_collision(mode))

func _process(_delta: float) -> void:
	# TODO: is there a method to test if one of many action is pressed ?
	if Input.is_action_just_pressed("set_to_mode0") or Input.is_action_just_pressed("set_to_mode1") or Input.is_action_just_pressed("set_to_mode2"):

		var next_mode:int
		if Input.is_action_just_pressed("set_to_mode0"):
			next_mode = 0
		elif Input.is_action_just_pressed("set_to_mode1"):
			next_mode = 1
		else:
			next_mode = 2

		var can_switch = current_mode != next_mode
		# worst shit I ever wrote in Godot
		for body in $ObstacleDetector.get_overlapping_bodies():
			#we don't want to prevent changing mode because of oneself
			if body == self:
				continue
			if shares_mode(body, next_mode):
				can_switch=false
				break

		if can_switch:
			#removing current layer & mask
			set_collision_layer_value(mode_to_collision(current_mode), false)
			set_collision_mask_value(mode_to_collision(current_mode), false)
			sprites_for_each_mode[next_mode].visible = true
			sprites_for_each_mode[current_mode].visible = false
			current_mode = next_mode
			#applying new one
			set_collision_layer_value(mode_to_collision(current_mode), true)
			set_collision_mask_value(mode_to_collision(current_mode), true)
		
	# level completed ?
	if $ObstacleDetector.overlaps_area(%Finish):
		level_finish_reached.emit()
		
	if Input.is_action_just_pressed("reload"):
		get_tree().reload_current_scene()
	
	update_direction()

func update_direction():
	var direction = Input.get_axis("left", "right")
	animation_tree.set("parameters/move/blend_position", direction)
	if direction > 0:
		for sprite in sprites_for_each_mode:
			sprite.flip_h = false
	elif direction < 0:
		for sprite in sprites_for_each_mode:
			sprite.flip_h = true

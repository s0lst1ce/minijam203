extends State

class_name GroundState

@export var jump_velocity: float = -1 * 400.0
@export var air_state: State
# overridable. Nom de l'anim dans l'AnimationPlayer, pas dans l'AnimationTree
@export var jump_animation: String = "jump"

func state_input(event: InputEvent):
	if event.is_action_pressed("jump"):
		jump()

func jump():
	character.velocity.y = jump_velocity
	next_state = air_state
	playback.travel(jump_animation)

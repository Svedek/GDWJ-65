extends CharacterBody2D


const SPEED = 120.0
const JUMP_VELOCITY = -200.0
const MIN_FALL_TIME = 0.15


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var fall_grace = false


func _input(event): # jump, fall, drop_inventory
	if event.is_action_pressed("fall"):
		collision_mask = 1
		fall_grace=true
		get_tree().create_timer(MIN_FALL_TIME).timeout.connect(_on_min_fall_timeout)
	if event.is_action_released("fall") and !fall_grace:
		collision_mask = 3


func _on_min_fall_timeout():
	if Input.is_action_pressed("fall"):
		fall_grace = false
	else:
		collision_mask = 3


func _physics_process(delta): # move_left, move_right
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	_handle_walk()

	move_and_slide()


func _handle_walk():
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		

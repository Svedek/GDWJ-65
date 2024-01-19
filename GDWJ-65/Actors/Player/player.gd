extends CharacterBody2D


const MAX_SPEED = 80.0
const ACCELERATION = 600.0
const FRICTION = 640.0
const JUMP_VELOCITY = -160.0
const MIN_FALL_TIME = 0.15
const GRAVITY = 540.0

@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer

# Get the gravity from the project settings to be synced with RigidBody nodes.
var fall_grace = false

var phy_process_func
var input_func

func _ready():
	_enter_idle()


func _input(event): # jump, fall, drop_inventory
	input_func.call(event)
	if event.is_action_pressed("fall"):
		collision_mask = 1
		fall_grace=true
		get_tree().create_timer(MIN_FALL_TIME).timeout.connect(_on_min_fall_timeout)
	if event.is_action_released("fall") and !fall_grace:
		collision_mask = 3
	
	if event.is_action_pressed("jump"):
		velocity.y = JUMP_VELOCITY


func _on_min_fall_timeout():
	if Input.is_action_pressed("fall"):
		fall_grace = false
	else:
		collision_mask = 3


func _physics_process(delta): # move_left, move_right
	#_handle_jump()
	
	phy_process_func.call(delta)

	move_and_slide()


func _handle_gravity(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta


var was_on_floor = false
var jump_available = true
const COYOTE_TIME = 0.15
func _handle_coyote():
	if is_on_floor() != was_on_floor:
		if was_on_floor: # Start Coyote Time
			get_tree().create_timer(COYOTE_TIME).timeout.connect(_on_coyote_timeout) # Maybe create timer as child of player
		else: # Reset jump
			was_on_floor = true
			jump_available = true


func _on_coyote_timeout():
	if !is_on_floor():
		jump_available = false


func _enter_idle():
	phy_process_func = _phy_process_idle
	input_func = _input_idle
	animation_player.play("idle")


func _phy_process_idle(delta):
	if Input.get_axis("move_left", "move_right"):
		_enter_move()
		_phy_process_move(delta)
	else:
		_handle_gravity(delta)
		
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)


func _input_idle(event):  # TODO
	pass


func _enter_move():
	phy_process_func = _phy_process_move
	input_func = _input_move
	animation_player.play("move")


func _phy_process_move(delta):  # TODO
	var dir = Input.get_axis("move_left", "move_right")
	
	if dir:
		_handle_gravity(delta)
		
		velocity.x = move_toward(velocity.x, dir * MAX_SPEED, ACCELERATION * delta)
		sprite_2d.flip_h = dir < 0
	else:
		_enter_idle()
		_phy_process_idle(delta)


func _input_move(event):  # TODO
	pass
	


func _enter_drop():
	phy_process_func = _phy_process_drop
	input_func = _input_drop
	animation_player.play("drop")


func _phy_process_drop(delta):  # TODO
	if Input.get_axis("move_left", "move_right"):
		_enter_move
	else:
		pass


func _input_drop(event):  # TODO
	pass


func _set_pack_size(size: int):
	if size == 0:
		sprite_2d.texture = load("res://Actors/Player/player_small.png")
	elif size == 1:
		sprite_2d.texture = load("res://Actors/Player/player_medium.png")
	elif size == 2:
		sprite_2d.texture = load("res://Actors/Player/player_large.png")
	else:
		print("player._set_pack_size invalid argument")

extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var player := 1 :
	set(id):
		player = id
		$PlayerInput.set_multiplayer_authority(id)

@onready var input = $PlayerInput
@onready var gun_base = $GunBase
@onready var barrel_pivot = $GunBase/BarrelPivot

# 🚨 Turret rotation parameters
@export var yaw_speed := 60.0 # deg/sec
@export var pitch_speed := 30.0
@export var min_pitch := -10.0
@export var max_pitch := 30.0
var pitch_angle := 0.0

func _ready():
	if player == multiplayer.get_unique_id():
		$Camera3D.current = true

const ROTATION_SPEED = 2.0 # radians per second
const MOVE_SPEED = 5.0

func _physics_process(delta):
	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump
	if input.jumping and is_on_floor():
		velocity.y = JUMP_VELOCITY
	input.jumping = false

	# Get input from PlayerInput
	var horizontal = input.direction.x  # left (-1) or right (+1) from arrows or WASD
	var vertical = input.direction.y    # up (+1) or down (-1)

	# Rotate tank left/right based on horizontal input
	rotation.y -= horizontal * ROTATION_SPEED * delta

	# Calculate forward direction (local -Z axis)
	var forward = transform.basis.z.normalized()

	# Move forward/backward based on vertical input
	velocity.x = forward.x * vertical * MOVE_SPEED
	velocity.z = forward.z * vertical * MOVE_SPEED

	move_and_slide()

	# 🚨 Turret rotation
	if input.gun_yaw != 0.0:
		gun_base.rotate_y(deg_to_rad(input.gun_yaw * -yaw_speed * delta))

	if input.gun_pitch != 0.0:
		pitch_angle += input.gun_pitch * pitch_speed * delta
		pitch_angle = clamp(pitch_angle, min_pitch, max_pitch)
		barrel_pivot.rotation.x = deg_to_rad(pitch_angle)

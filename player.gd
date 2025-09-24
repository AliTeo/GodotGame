extends CharacterBody3D

# ---------------------
# Movement parameters
# ---------------------
const ROTATION_SPEED = 2.0 # radians/sec
const MOVE_SPEED = 5.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# ---------------------
# Player identity
# ---------------------
@export var player := 1 :
	set(id):
		player = id
		$PlayerInput.set_multiplayer_authority(id)
# ---------------------
# Turret
# ---------------------
@onready var input = $PlayerInput
@onready var gun_base = $GunBase
@onready var barrel_pivot = $GunBase/BarrelPivot

@export var yaw_speed := 60.0   # deg/sec
@export var pitch_speed := 30.0 # deg/sec
@export var min_pitch := -10.0
@export var max_pitch := 30.0
var pitch_angle := 0.0

# ---------------------
# Cannonball
# ---------------------
@onready var cannonball_scene = preload("res://scenes/CannonBall.tscn")

# ---------------------
# Initialization
# ---------------------
func _ready():
	# Assign multiplayer authority
	$PlayerInput.set_multiplayer_authority(player)

	# Enable camera for local player
	if player == multiplayer.get_unique_id():
		$Camera3D.current = true

# Optional setter if you want to change player id later
func set_player(id: int):
	player = id
	$PlayerInput.set_multiplayer_authority(player)
	if player == multiplayer.get_unique_id():
		$Camera3D.current = true

# ---------------------
# Physics + movement
# ---------------------
func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Tank movement
	var horizontal = input.direction.x
	var vertical   = input.direction.y

	# Rotate tank left/right
	rotation.y -= horizontal * ROTATION_SPEED * delta

	# Forward/backward
	var forward = transform.basis.z.normalized()
	velocity.x = forward.x * vertical * MOVE_SPEED
	velocity.z = forward.z * vertical * MOVE_SPEED

	move_and_slide()

	# ---------------------
	# Turret rotation
	# ---------------------
	if input.gun_yaw != 0.0:
		gun_base.rotate_y(deg_to_rad(input.gun_yaw * -yaw_speed * delta))
	if input.gun_pitch != 0.0:
		pitch_angle += input.gun_pitch * pitch_speed * delta
		pitch_angle = clamp(pitch_angle, min_pitch, max_pitch)
		barrel_pivot.rotation.x = deg_to_rad(pitch_angle)

	# ---------------------
	# Shooting
	# ---------------------
	if input.shooting:
		if multiplayer.is_server():
			shoot_cannon()
		else:
			rpc_id(1, "request_shoot") # ask server to spawn cannonball

# ---------------------
# Server RPC to handle client shooting requests
# ---------------------
@rpc("any_peer")
func request_shoot():
	if multiplayer.is_server():
		shoot_cannon()

# ---------------------
# Spawn and launch cannonball
# ---------------------
func shoot_cannon():
	# Instantiate cannonball
	var cannonball = cannonball_scene.instantiate() as RigidBody3D

	# Add to scene FIRST so global_transform is valid
	get_tree().current_scene.add_child(cannonball, true)

	# Now compute muzzle position & direction (barrel must be in tree)
	var muzzle_pos = barrel_pivot.global_transform.origin
	var direction = -barrel_pivot.global_transform.basis.z.normalized()

	# Set global position AFTER adding to tree
	cannonball.global_transform.origin = muzzle_pos + direction * 1.5

	# Launch projectile
	if cannonball.has_method("launch"):
		cannonball.launch(direction, player)

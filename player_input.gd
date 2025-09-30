extends MultiplayerSynchronizer

@export var direction := Vector2()

# 🚨 Turret input
@export var gun_yaw := float(0.0)
@export var gun_pitch := float(0.0)

# 🚨 Shooting input
@export var shooting := false

func _ready():
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

func _process(_delta):
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# Turret input
	gun_yaw = Input.get_action_strength("gun_right") - Input.get_action_strength("gun_left")
	gun_pitch = Input.get_action_strength("gun_up") - Input.get_action_strength("gun_down")

	# 🚨 Shooting input
	shooting = Input.is_action_just_pressed("shoot")

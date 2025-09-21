extends MultiplayerSynchronizer

@export var jumping := false
@export var direction := Vector2()

# 🚨 NEW: turret input
@export var gun_yaw := float(0.0)
@export var gun_pitch := float(0.0)

func _ready():
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

@rpc("call_local")
func jump():
	jumping = true

func _process(_delta):
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if Input.is_action_just_pressed("ui_accept"):
		jump.rpc()

	# 🚨 NEW: turret input
	gun_yaw = Input.get_action_strength("gun_right") - Input.get_action_strength("gun_left")
	gun_pitch = Input.get_action_strength("gun_up") - Input.get_action_strength("gun_down")

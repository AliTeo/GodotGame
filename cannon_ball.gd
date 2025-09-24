# CannonBall.gd
extends RigidBody3D
class_name CannonBall

@export var initial_speed: float = 20.0
@export var lifetime: float = 5.0

var shooter_id: int

func _ready():
	# Set mass if you want a custom value
	mass = 1.0  # or any other number

	# Auto-destroy after some time
	await get_tree().create_timer(lifetime).timeout
	if is_instance_valid(self):
		queue_free()

func launch(direction: Vector3, shooter: int):
	shooter_id = shooter
	# Apply impulse along barrel direction
	apply_impulse(Vector3.ZERO, direction * initial_speed * mass)

func _on_body_entered(body):
	if body == null or body == self:
		return
	# TODO: handle damage, knockback, effects etc.
	queue_free()


func _on_hit_area_body_entered(body: Node3D) -> void:
	if body == null or body == self:
		return

	# Optional: ignore shooter
	if body.has_method("player") and body.player == shooter_id:
		return

	# TODO: apply damage, knockback, or special effects here

	# Destroy the cannonball
	queue_free()

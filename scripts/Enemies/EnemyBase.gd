class_name EnemyBase
extends CharacterBody3D

@export_group("Stats")
@export var max_health: int = 30
@export var current_armor: int = 0
@export var speed: float = 5.0
@export var metal_reward: int = 5


@export_group("Target")
@export var target: Node3D

@onready var current_health: int = max_health

var knockback_velocity: Vector3 = Vector3.ZERO
@export var knockback_friction: float = 30.0

func _ready() -> void:
	current_health = max_health
	add_to_group("enemies")

func apply_knockback(impulse: Vector3) -> void:
	impulse.y = 0.0
	
	var push_dir = impulse.normalized()
	global_position += push_dir * 0.3
	
	knockback_velocity = impulse

func _physics_process(delta: float) -> void:
	var ai_velocity: Vector3 = Vector3.ZERO

	if knockback_velocity.length() < 2.0 and is_instance_valid(target):
		var direction: Vector3 = (target.global_position - global_position).normalized()
		direction.y = 0.0
		ai_velocity = direction * speed
		
		if direction != Vector3.ZERO:
			look_at(global_position + direction, Vector3.UP)

	velocity = ai_velocity + knockback_velocity
	move_and_slide()

	if knockback_velocity.length() > 0.01:
		knockback_velocity = knockback_velocity.move_toward(Vector3.ZERO, knockback_friction * delta)
	else:
		knockback_velocity = Vector3.ZERO

func take_damage(amount: int) -> void:
	if current_health <= 0:
		return

	var armor_reduction_percent: float = clamp(current_armor, 0, 100) / 100.0
	var damage_multiplier: float = 1.0 - armor_reduction_percent
	var final_damage: int = max(0, roundi(amount * damage_multiplier))
	
	current_health -= final_damage

	if current_health <= 0:
		die()

func die() -> void:
	MetalManager.add_metal(metal_reward)
	queue_free()

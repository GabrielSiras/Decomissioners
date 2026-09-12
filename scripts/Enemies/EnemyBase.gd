class_name EnemyBase
extends CharacterBody3D

@export var speed: float = 5.0
@export var max_health: int = 10
@export var metal_reward: int = 5
@export var target: Node3D

var current_health: int

func _ready() -> void:
	current_health = max_health
	add_to_group("enemies")

func _physics_process(delta: float) -> void:
	if is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		direction.y = 0 
		velocity = direction * speed
		
		if direction != Vector3.ZERO:
			look_at(global_position + direction, Vector3.UP)
			
		move_and_slide()

func take_damage(amount: int) -> void:
	current_health -= amount
	if current_health <= 0:
		die()

func die() -> void:
	MetalManager.add_metal(metal_reward)
	queue_free()

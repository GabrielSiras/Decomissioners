class_name EnemyBase
extends CharacterBody3D

@export var max_health: int = 30
@onready var current_health: int = max_health
@export var current_armor: int = 0

@export var speed: float = 5.0
@export var metal_reward: int = 5
@export var target: Node3D

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
	if current_health <= 0:
		return

	var armor_reduction_percent: float = clamp(current_armor, 0, 100) / 100.0
	var damage_multiplier: float = 1.0 - armor_reduction_percent
	
	var final_damage: int = max(0, roundi(amount * damage_multiplier))
	
	current_health -= final_damage
	print(name, " (Inimigo) recebeu ", final_damage, " de dano! | Vida: ", current_health)

	if current_health <= 0:
		current_health = 0
		die()

func die() -> void:
	MetalManager.add_metal(metal_reward)
	print(name, " morreu!")
	queue_free()

class_name EnemyBase
extends CharacterBody2D

@export var speed: float = 100.0
@export var max_health: int = 10
@export var metal_reward: int = 5 # qtd de metal q dropa ao morrer

var current_health: int

func _ready() -> void:
	current_health = max_health
	add_to_group("enemies")

func take_damage(amount: int) -> void:
	current_health -= amount
	if current_health <= 0:
		die()

func die() -> void:
	MetalManager.add_metal(metal_reward)
	print(metal_reward) # pra ver funcionando.
	queue_free()

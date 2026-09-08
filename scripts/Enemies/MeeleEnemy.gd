class_name MeleeEnemy
extends EnemyBase

@export var melee_damage: int = 5
@export var attack_cooldown: float = 1.0

func _physics_process(delta: float) -> void:
	velocity = Vector2.LEFT * speed
	move_and_slide()

func attack_target(target: Node2D) -> void:
	if target.has_method("take_damage"):
		target.take_damage(melee_damage)

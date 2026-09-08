class_name RangedEnemy
extends EnemyBase

@export var attack_range: float = 250.0
@export var projectile_scene: PackedScene
@export var target: Node2D # Ver mais tarde sobre o target

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		return
		
	var distance_to_target = global_position.distance_to(target.global_position)
	
	if distance_to_target > attack_range:
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		shoot()

func shoot() -> void:
	pass

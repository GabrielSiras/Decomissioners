class_name RangedEnemy
extends EnemyBase

@export var attack_range: float = 12.0
@export var min_distance: float = 5.0
@export var attack_cooldown: float = 2.0
@export var ranged_damage: int = 5
@export var enemy_projectile_scene: PackedScene

@onready var muzzle: Marker3D = $Muzzle
@onready var attack_timer: Timer = $AttackTimer

var is_attacking: bool = false

func _ready() -> void:
	super._ready()
	
	attack_timer.wait_time = attack_cooldown
	attack_timer.timeout.connect(_on_attack_timer_timeout)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		return

	var distance_to_target = global_position.distance_to(target.global_position)
	var target_pos = target.global_position
	target_pos.y = global_position.y

	if distance_to_target > attack_range:
		is_attacking = false
		attack_timer.stop()
		
		var direction = (target.global_position - global_position).normalized()
		direction.y = 0 
		velocity = direction * (speed * 1.3)
	
	else:
		var train_speed: float = 0.0
		if "current_speed" in target:
			train_speed = target.current_speed
		elif "speed" in target:
			train_speed = target.speed

		if distance_to_target > min_distance:
			var direction = (target.global_position - global_position).normalized()
			direction.y = 0
			velocity = direction * speed
		else:
			velocity = Vector3(0, 0, -train_speed)
		
		if not is_attacking:
			is_attacking = true
			attack_timer.start()

	if global_position.distance_squared_to(target_pos) > 0.01:
		look_at(target_pos, Vector3.UP)

	move_and_slide()

func _on_attack_timer_timeout() -> void:
	shoot_at_target()

func shoot_at_target() -> void:
	if enemy_projectile_scene and is_instance_valid(target):
		var projectile = enemy_projectile_scene.instantiate()
		get_parent().add_child(projectile)
		
		if is_instance_valid(muzzle):
			projectile.global_position = muzzle.global_position
		else:
			projectile.global_position = global_position
		
		if projectile.has_method("setup"):
			projectile.setup(target, ranged_damage)

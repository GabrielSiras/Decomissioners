class_name RangedEnemy
extends EnemyBase

@export var attack_range: float = 10.0
@export var attack_cooldown: float = 2.0
@export var ranged_damage: int = 1
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

	if distance_to_target > attack_range:
		is_attacking = false
		attack_timer.stop()
		
		var direction = (target.global_position - global_position).normalized()
		direction.y = 0 
		velocity = direction * speed
		
		if direction != Vector3.ZERO:
			look_at(global_position + direction, Vector3.UP)
			
		move_and_slide()
	
	else:
		velocity = Vector3.ZERO
		
		var target_pos = target.global_position
		target_pos.y = global_position.y
		look_at(target_pos, Vector3.UP)
		
		if not is_attacking:
			is_attacking = true
			attack_timer.start()

func _on_attack_timer_timeout() -> void:
	shoot_at_target()

func shoot_at_target() -> void:
	if enemy_projectile_scene and is_instance_valid(target):
		var projectile = enemy_projectile_scene.instantiate()
		get_parent().add_child(projectile)
		projectile.global_position = muzzle.global_position
		
		if projectile.has_method("setup"):
			projectile.setup(target, ranged_damage)

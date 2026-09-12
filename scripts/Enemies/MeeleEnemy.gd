class_name MeleeEnemy
extends EnemyBase

@export var melee_damage: int = 5
@export var attack_cooldown: float = 1.0
@export var attack_range: float = 2.0

@onready var attack_timer: Timer = Timer.new()
var can_attack: bool = true

func _ready() -> void:
	super._ready()
	
	add_child(attack_timer)
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	attack_timer.timeout.connect(func(): can_attack = true)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		return

	var distance = global_position.distance_to(target.global_position)

	if distance > attack_range:
		super._physics_process(delta)
	else:
		velocity = Vector3.ZERO
		if can_attack:
			attack_target(target)

func attack_target(target_node: Node3D) -> void:
	if target_node and target_node.has_method("take_damage"):
		target_node.take_damage(melee_damage)
		can_attack = false
		attack_timer.start()

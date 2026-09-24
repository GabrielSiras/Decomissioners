class_name EnemyProjectile
extends Area3D

@export var speed: float = 12.0
@export var lifetime: float = 4.0

var damage_amount: int = 5
var direction: Vector3 = Vector3.ZERO

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func setup(target_node: Node3D, damage: int) -> void:
	damage_amount = damage
	if is_instance_valid(target_node):
		var target_pos = target_node.global_position
		target_pos.y = global_position.y 
		
		direction = (target_pos - global_position).normalized()
		
		if direction.is_zero_approx():
			direction = -global_transform.basis.z

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node3D) -> void:
	_apply_damage_to(body)

func _on_area_entered(area: Area3D) -> void:
	_apply_damage_to(area)
		
func _apply_damage_to(target: Node3D) -> void:
	if target is EnemyBase or target is EnemyProjectile:
		return

	var current_node: Node = target
	while current_node != null:
		if current_node.has_method("take_damage"):
			current_node.take_damage(damage_amount)
			queue_free()
			return
		current_node = current_node.get_parent()

	queue_free()

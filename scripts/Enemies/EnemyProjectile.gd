class_name EnemyProjectile
extends Area3D

@export var speed: float = 12.0
@export var lifetime: float = 4.0

var target_position: Vector3 = Vector3.ZERO
var damage_amount: int = 1
var direction: Vector3 = Vector3.ZERO

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func setup(target_node: Node3D, damage: int) -> void:
	damage_amount = damage
	if is_instance_valid(target_node):
		direction = (target_node.global_position - global_position).normalized()

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage_amount)
		queue_free()

func _on_area_entered(area: Area3D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(damage_amount)
		queue_free()

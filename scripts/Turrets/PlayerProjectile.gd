class_name PlayerProjectile
extends Area3D

@export var speed: float = 15.0
@export var lifetime: float = 5.0 # Segundos até sumir se não acertar nada

var target_node: Node3D = null
var damage_amount: int = 2
var direction: Vector3 = Vector3.ZERO

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func setup(target: Node3D, damage: int) -> void:
	target_node = target
	damage_amount = damage
	
	if is_instance_valid(target_node):
		direction = (target_node.global_position - global_position).normalized()

func _physics_process(delta: float) -> void:
	if is_instance_valid(target_node):
		direction = (target_node.global_position - global_position).normalized()
	
	global_position += direction * speed * delta

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage_amount)
		queue_free()

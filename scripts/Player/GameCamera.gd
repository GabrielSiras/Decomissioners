class_name GameCamera
extends Camera3D

@export var target: Node3D
@export var offset: Vector3 = Vector3(0, 0, 0)

func _ready() -> void:
	make_current()
	rotation_degrees = Vector3(-75, 0, 0)

func _physics_process(_delta: float) -> void:
	if is_instance_valid(target):
		global_position.x = target.global_position.x + offset.x
		global_position.z = target.global_position.z + offset.z

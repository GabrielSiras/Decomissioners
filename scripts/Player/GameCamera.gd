class_name GameCamera
extends Camera3D

@export var target: Node3D
@export var offset: Vector3 = Vector3(0, 0, 0)
@export var smooth_speed: float = 8.0

func _ready() -> void:
	make_current()
	rotation_degrees = Vector3(-75, 0, 0)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		return

	var target_pos: Vector3 = target.global_position
	if target.has_method("get_train_center_position"):
		target_pos = target.get_train_center_position()

	var desired_x: float = target_pos.x + offset.x
	var desired_z: float = target_pos.z + offset.z

	global_position.x = lerp(global_position.x, desired_x, smooth_speed * delta)
	global_position.z = lerp(global_position.z, desired_z, smooth_speed * delta)
	
	if offset.y != 0.0:
		global_position.y = lerp(global_position.y, target_pos.y + offset.y, smooth_speed * delta)

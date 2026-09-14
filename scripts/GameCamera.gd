class_name GameCamera
extends Camera3D

@export var fixed_y_height: float = 15.0

func _ready() -> void:
	make_current()
	
	rotation_degrees = Vector3(-75, 0, 0)
	
	global_position.y = fixed_y_height

func set_height(new_height: float) -> void:
	fixed_y_height = new_height
	global_position.y = fixed_y_height

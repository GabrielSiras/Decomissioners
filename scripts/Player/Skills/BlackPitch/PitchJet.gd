class_name PitchJet
extends Node3D

signal drop_requested(z: float)
signal finished

var train: Node3D
var extra_speed: float = 6.0
var spacing: float = 2.0
var drop_duration: float = 3.0
var exit_time: float = 2.0

var _acc: float = 0.0
var _elapsed: float = 0.0

func launch(train_node: Node3D, start_pos: Vector3, extra: float, space: float, duration: float) -> void:
	train = train_node
	extra_speed = extra
	spacing = space
	drop_duration = duration
	global_position = start_pos
	rotation.y = PI

func _physics_process(delta: float) -> void:
	var train_spd: float = train.current_speed if is_instance_valid(train) and "current_speed" in train else 8.0
	var step: float = (train_spd + extra_speed) * delta
	global_position.z -= step
	if is_instance_valid(train):
		global_position.x = lerp(global_position.x, train.global_position.x, 8.0 * delta)

	_elapsed += delta

	if _elapsed <= drop_duration:
		_acc += step
		while _acc >= spacing:
			_acc -= spacing
			drop_requested.emit(global_position.z + _acc)
	elif _elapsed > drop_duration + exit_time:
		finished.emit()
		queue_free()

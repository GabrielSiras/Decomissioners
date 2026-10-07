class_name PitchSkill
extends Node3D

signal skill_finished

@export_category("Cenas do Piche")
@export var left_puddle_scene: PackedScene
@export var right_puddle_scene: PackedScene

@export var stream_duration: float = 4.0
@export var spawn_interval: float = 0.25

func execute_skill(train_head: Node3D) -> void:
	if not is_instance_valid(train_head):
		return

	var left_window = train_head.find_child("LeftWindowMarker", true, false)
	var right_window = train_head.find_child("RightWindowMarker", true, false)

	_set_window_vfx_emitting(left_window, true)
	_set_window_vfx_emitting(right_window, true)

	var elapsed: float = 0.0
	while elapsed < stream_duration:
		if not is_instance_valid(train_head):
			break

		_spawn_puddle(left_window, left_puddle_scene)
		_spawn_puddle(right_window, right_puddle_scene)
		
		await get_tree().create_timer(spawn_interval).timeout
		elapsed += spawn_interval

	_set_window_vfx_emitting(left_window, false)
	_set_window_vfx_emitting(right_window, false)
	
	skill_finished.emit()
	skill_finished.emit()

func _set_window_vfx_emitting(window_marker: Node3D, active: bool) -> void:
	if is_instance_valid(window_marker):
		var gpu_particles = window_marker.find_children("*", "GPUParticles3D", true, false)
		for p in gpu_particles:
			p.emitting = active
			
		var cpu_particles = window_marker.find_children("*", "CPUParticles3D", true, false)
		for p in cpu_particles:
			p.emitting = active

func _spawn_puddle(marker: Node3D, puddle_scene: PackedScene) -> void:
	if not is_instance_valid(marker) or not puddle_scene:
		return

	var puddle = puddle_scene.instantiate()
	get_tree().current_scene.add_child(puddle)
	
	var spawn_pos = marker.global_position
	spawn_pos.y = 0.02
	puddle.global_position = spawn_pos
	puddle.global_rotation.y = marker.global_rotation.y

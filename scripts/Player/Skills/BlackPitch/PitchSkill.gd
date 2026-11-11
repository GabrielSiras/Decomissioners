class_name PitchSkill
extends Node3D

signal skill_finished

@export var stream_duration: float = 4.0
@export var tail_time: float = 3.0 

var is_running: bool = false

func execute_skill(train_head: Node3D) -> void:
	if not is_instance_valid(train_head) or is_running:
		return
	is_running = true

	var markers: Array = []
	for n in ["LeftWindowMarker", "RightWindowMarker"]:
		var m = train_head.find_child(n, true, false)
		if m:
			markers.append(m)

	_set_particles(markers, true)
	_set_zones(markers, true)
	await get_tree().create_timer(stream_duration).timeout
	_set_particles(markers, false)

	await get_tree().create_timer(tail_time).timeout
	_set_zones(markers, false)
	is_running = false
	skill_finished.emit()

func _set_particles(markers: Array, active: bool) -> void:
	for m in markers:
		if not is_instance_valid(m):
			continue
		for p in m.find_children("*", "GPUParticles3D", true, false):
			p.emitting = active

func _set_zones(markers: Array, active: bool) -> void:
	for m in markers:
		if not is_instance_valid(m):
			continue
		for z in m.find_children("*", "PitchZone", true, false):
			z.set_active(active)

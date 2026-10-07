class_name VFXPrewarmer
extends Node3D

@export_category("Efeitos para Pre-warm")
@export var vfx_scenes: Array[PackedScene] = []

func _ready() -> void:
	prewarm_vfx()

func prewarm_vfx() -> void:
	var temp_instances: Array[Node] = []

	for scene in vfx_scenes:
		if not scene:
			continue
			
		var instance = scene.instantiate()
		add_child(instance)
		
		if instance is Node3D:
			instance.global_position = Vector3(0, -100, 0)
		
		_trigger_particles(instance)
		temp_instances.append(instance)

	await get_tree().process_frame
	await get_tree().process_frame

	for instance in temp_instances:
		if is_instance_valid(instance):
			instance.queue_free()
			
	print("✅ Shaders e VFX pré-compilados com sucesso!")

func _trigger_particles(parent: Node) -> void:
	if parent is GPUParticles3D or parent is CPUParticles3D:
		parent.emitting = true
	for child in parent.get_children():
		_trigger_particles(child)

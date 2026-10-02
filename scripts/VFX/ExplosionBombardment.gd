extends Node3D

@onready var the_big_one: GPUParticles3D = $TheBigOne
@onready var explosion_cloud: GPUParticles3D = $ExplosionCloud
@onready var shockwave_vfx: GPUParticles3D = $ShockwaveVFX
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D2

@export var duration: float = 2.0

func _ready() -> void:
	explode()

func explode() -> void:
	the_big_one.restart()
	explosion_cloud.restart()
	shockwave_vfx.restart()
	
	mesh_instance.visible = true
	mesh_instance.scale = Vector3.ONE * 0.2
	
	var tween = create_tween()
	tween.tween_property(mesh_instance, "scale", Vector3.ONE * 1.5, 0.08)
	tween.tween_property(mesh_instance, "scale", Vector3.ZERO, 0.15)
	
	await get_tree().create_timer(duration).timeout
	queue_free()

extends Node3D

@onready var particles: GPUParticles3D = $PreassureBlast

func _ready() -> void:
	if particles:
		particles.restart()
		particles.emitting = true
		
		var wait_time: float = (particles.lifetime / particles.speed_scale) + 0.2
		await get_tree().create_timer(wait_time).timeout
	
	queue_free()

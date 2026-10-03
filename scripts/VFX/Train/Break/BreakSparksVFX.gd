extends GPUParticles3D

@export var brake_duration: float = 1.0

func _ready() -> void:
	emitting = true
	
	await get_tree().create_timer(brake_duration).timeout
	
	emitting = false
	
	await get_tree().create_timer(lifetime).timeout
	
	queue_free()

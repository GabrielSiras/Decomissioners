class_name TerrainChunk
extends Node3D

@onready var spawn_markers: Array[Node] = $Spawnpoints.get_children()

func get_random_spawn_transform() -> Transform3D:
	if spawn_markers.size() > 0:
		var marker = spawn_markers.pick_random() as Marker3D
		return marker.global_transform
	
	var side_x = [-6.0, 6.0].pick_random()
	var random_z = randf_range(-20.0, 20.0)
	var fallback_pos = global_position + Vector3(side_x, 0.5, random_z)
	return Transform3D(Basis(), fallback_pos)

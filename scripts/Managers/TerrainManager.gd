class_name TerrainManager
extends Node3D

enum Zone { DESOLATION, SCRAP_YARD, FACTORY }

signal zone_changed(new_zone: Zone)

@export var train: Node3D
@export var destination_node: Node3D
@export var chunk_length: float = 50.0

@export var desolation_scenes: Array[PackedScene]
@export var scrap_scenes: Array[PackedScene]
@export var factory_scenes: Array[PackedScene]

var current_zone: Zone = Zone.DESOLATION
var active_chunks: Array[Node3D] = []
var total_distance: float = 0.0

func _ready() -> void:
	if is_instance_valid(train) and is_instance_valid(destination_node):
		total_distance = train.global_position.distance_to(destination_node.global_position)
		
	_spawn_initial_chunks(4)

func _process(_delta: float) -> void:
	if not is_instance_valid(train) or active_chunks.size() == 0:
		return

	_check_current_zone()

	var first_chunk = active_chunks[0]
	if train.global_position.z < first_chunk.global_position.z - chunk_length:
		_recycle_first_chunk()

func _check_current_zone() -> void:
	if active_chunks.size() == 0 or not is_instance_valid(destination_node):
		return

	var generation_z = active_chunks.back().global_position.z
	
	var generation_distance_to_dest = abs(generation_z - destination_node.global_position.z)
	var distance_generated = total_distance - generation_distance_to_dest
	
	var generation_progress = clamp((distance_generated / total_distance) * 100.0, 0.0, 100.0)

	var new_zone: Zone = Zone.DESOLATION
	if generation_progress >= 66.0:
		new_zone = Zone.FACTORY
	elif generation_progress >= 33.0:
		new_zone = Zone.SCRAP_YARD
	else:
		new_zone = Zone.DESOLATION

	if new_zone != current_zone:
		current_zone = new_zone
		zone_changed.emit(current_zone)

func _recycle_first_chunk() -> void:
	var old_chunk = active_chunks.pop_front()
	old_chunk.queue_free()

	var last_chunk = active_chunks.back()
	var new_z_position = last_chunk.global_position.z - chunk_length

	var new_chunk_scene = _get_random_chunk_for_zone(current_zone)
	if new_chunk_scene:
		var new_chunk = new_chunk_scene.instantiate() as Node3D
		add_child(new_chunk)
		new_chunk.global_position = Vector3(0, 0, new_z_position)
		active_chunks.append(new_chunk)

func _get_random_chunk_for_zone(zone: Zone) -> PackedScene:
	var pool: Array[PackedScene] = []
	match zone:
		Zone.DESOLATION:
			pool = desolation_scenes
		Zone.SCRAP_YARD:
			pool = scrap_scenes
		Zone.FACTORY:
			pool = factory_scenes
			
	if pool.size() > 0:
		return pool.pick_random()
	return null

func _spawn_initial_chunks(count: int) -> void:
	for i in range(count):
		var scene = _get_random_chunk_for_zone(Zone.DESOLATION)
		if scene:
			var chunk = scene.instantiate() as Node3D
			add_child(chunk)
			chunk.global_position = Vector3(0, 0, train.global_position.z - (i * chunk_length))
			active_chunks.append(chunk)

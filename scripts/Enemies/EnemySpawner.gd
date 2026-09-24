class_name EnemySpawner
extends Node3D

@export_category("Referências")
@export var terrain_manager: TerrainManager
@export var main_target: Node3D

@export_category("Inimigos por Zona")
@export var desolation_enemies: Array[PackedScene] = []
@export var scrap_enemies: Array[PackedScene] = []
@export var factory_enemies: Array[PackedScene] = []

@export_category("Fallback de Spawn Points")
@export var spawn_points_container: Node3D

@onready var spawn_timer: Timer = $SpawnTimer

var active_enemy_pool: Array[PackedScene] = []
var fallback_spawn_points: Array[Marker3D] = []

func _ready() -> void:
	if spawn_points_container:
		for child in spawn_points_container.get_children():
			if child is Marker3D:
				fallback_spawn_points.append(child)

	if terrain_manager:
		terrain_manager.zone_changed.connect(_on_zone_changed)
		_on_zone_changed(terrain_manager.current_zone)
	else:
		active_enemy_pool = desolation_enemies

	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func _on_zone_changed(new_zone: TerrainManager.Zone) -> void:
	match new_zone:
		TerrainManager.Zone.DESOLATION:
			spawn_timer.wait_time = 4.0
			active_enemy_pool = desolation_enemies
			
		TerrainManager.Zone.SCRAP_YARD:
			spawn_timer.wait_time = 2.5
			active_enemy_pool = scrap_enemies
			
		TerrainManager.Zone.FACTORY:
			spawn_timer.wait_time = 1.2
			active_enemy_pool = factory_enemies

	print("EnemySpawner: Onda alterada para ", TerrainManager.Zone.keys()[new_zone], " | Intervalo: ", spawn_timer.wait_time, "s")

func _on_spawn_timer_timeout() -> void:
	spawn_enemy()

func spawn_enemy() -> void:
	if active_enemy_pool.is_empty():
		return

	var random_enemy_scene: PackedScene = active_enemy_pool.pick_random()
	var enemy_instance = random_enemy_scene.instantiate()

	if "target" in enemy_instance:
		enemy_instance.target = main_target

	var spawn_transform: Transform3D = _get_chunk_spawn_transform()

	get_parent().add_child(enemy_instance)
	
	enemy_instance.global_transform = spawn_transform

func _get_chunk_spawn_transform() -> Transform3D:
	var train_z: float = 0.0
	if is_instance_valid(terrain_manager) and is_instance_valid(terrain_manager.train):
		train_z = terrain_manager.train.global_position.z

	if is_instance_valid(terrain_manager) and not terrain_manager.active_chunks.is_empty():
		for chunk in terrain_manager.active_chunks:
			if chunk.global_position.z < train_z:
				if chunk.has_method("get_random_spawn_transform"):
					var chunk_sp = chunk.get_random_spawn_transform()
					if chunk_sp.origin != Vector3.ZERO:
						return chunk_sp

	var side_x = [-6.0, 6.0].pick_random()
	var fallback_pos = Vector3(side_x, 0.5, train_z - 35.0)
	
	return Transform3D(Basis(), fallback_pos)

	return Transform3D.IDENTITY

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

@export_category("Cena da MachineGun")
@export var machine_gun_scene: PackedScene
@export var shoulder_x_offset: float = 4.5
@export var spawn_z_behind: float = 30.0
@export_range(0.0, 1.0) var machine_gun_spawn_chance: float = 0.1 # 100%

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
	if machine_gun_scene and randf() < machine_gun_spawn_chance:
		try_spawn_machine_gun()
	else:
		spawn_enemy()

func spawn_enemy() -> void:
	if active_enemy_pool.is_empty():
		return

	var random_enemy_scene: PackedScene = active_enemy_pool.pick_random()
	var enemy_instance = random_enemy_scene.instantiate()

	if enemy_instance.has_method("setup_target"):
		enemy_instance.setup_target(main_target)
	elif "target" in enemy_instance:
		enemy_instance.target = main_target

	var spawn_transform: Transform3D = _get_chunk_spawn_transform()

	get_parent().add_child(enemy_instance)
	enemy_instance.global_transform = spawn_transform

func try_spawn_machine_gun(train: Node3D = null) -> void:
	var target_train = train if is_instance_valid(train) else main_target
	
	if not is_instance_valid(target_train) or not machine_gun_scene:
		return
		
	var base_spd = target_train.base_speed if "base_speed" in target_train else 5.0
	var curr_spd = target_train.current_speed if "current_speed" in target_train else 5.0
	
	if curr_spd > base_spd:
		print("Spawn de MachineGun bloqueado: Trem acima da velocidade base.")
		return

	var mg = machine_gun_scene.instantiate()
	get_parent().add_child(mg)
	
	var spawn_pos = Vector3(
		target_train.global_position.x + shoulder_x_offset,
		0.0,
		target_train.global_position.z + spawn_z_behind
	)
	mg.global_position = spawn_pos
	
	if mg.has_method("setup_target"):
		mg.setup_target(target_train)
	elif "target" in mg:
		mg.target = target_train
		
	print("✅ MachineGun spawnada no acostamento!")

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

	var side_x = [-6.0, 6.0].pick_random() + randf_range(-1.0, 1.0)
	var spawn_z = train_z - randf_range(30.0, 40.0)
	var fallback_pos = Vector3(side_x, 0.5, spawn_z)
	
	return Transform3D(Basis(), fallback_pos)

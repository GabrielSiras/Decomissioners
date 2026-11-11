class_name EnemySpawner
extends Node3D

@export_category("Referências")
@export var terrain_manager: TerrainManager
@export var main_target: Node3D

@export_category("Fases")
@export var config: SpawnConfig
@export var start_phase: int = 0
@export var cumulative: bool = true
@export var follow_terrain_zones: bool = false

@export_category("Distância de Spawn")
@export var min_spawn_distance: float = 50.0
@export var max_spawn_distance: float = 90.0

@export_category("Posições especiais")
@export var shoulder_x_offset: float = 4.5
@export var spawn_z_behind: float = 30.0
@export var air_side_distance: float = 20.0
@export var air_height: float = 1.5

@onready var spawn_timer: Timer = $SpawnTimer

var current_phase_index: int = 0
var active_entries: Array[SpawnEntry] = []

func _ready() -> void:
	if follow_terrain_zones and terrain_manager:
		terrain_manager.zone_changed.connect(func(zone): set_phase(int(zone)))
		set_phase(int(terrain_manager.current_zone))
	else:
		set_phase(start_phase)

	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func set_phase(index: int) -> void:
	if config == null or config.phases.is_empty():
		push_warning("EnemySpawner: 'config' vazio ou sem fases.")
		return
	current_phase_index = clampi(index, 0, config.phases.size() - 1)

	active_entries.clear()
	var first: int = 0 if cumulative else current_phase_index
	for i in range(first, current_phase_index + 1):
		active_entries.append_array(config.phases[i].entries)

	spawn_timer.wait_time = config.phases[current_phase_index].spawn_interval
	print("EnemySpawner: fase ", current_phase_index + 1, " | inimigos: ", active_entries.size(), " | intervalo: ", spawn_timer.wait_time)

func _on_spawn_timer_timeout() -> void:
	var entry := _pick_weighted()
	if entry == null or entry.scene == null:
		return
	_spawn(entry)

func _pick_weighted() -> SpawnEntry:
	var total: float = 0.0
	for e in active_entries:
		total += e.weight
	if total <= 0.0:
		return null
	var roll: float = randf() * total
	for e in active_entries:
		roll -= e.weight
		if roll <= 0.0:
			return e
	return active_entries.back()

func _spawn(entry: SpawnEntry) -> void:
	if not is_instance_valid(main_target):
		return

	var enemy: Node = entry.scene.instantiate()

	if enemy.has_method("setup_target"):
		enemy.setup_target(main_target)
	elif "target" in enemy:
		enemy.target = main_target

	var t: Transform3D
	match entry.mode:
		SpawnEntry.Mode.SHOULDER_BEHIND:
			t = Transform3D(Basis(), Vector3(
				main_target.global_position.x + shoulder_x_offset,
				0.0,
				main_target.global_position.z + spawn_z_behind))
		SpawnEntry.Mode.AIR:
			var side: float = [-air_side_distance, air_side_distance].pick_random()
			t = Transform3D(Basis(), Vector3(side, air_height, main_target.global_position.z))
		_:
			t = _get_chunk_spawn_transform()

	if entry.use_lane:
		var lane_side: float = [-1.0, 1.0].pick_random()
		t.origin.x = main_target.global_position.x + lane_side * randf_range(entry.lane_min_x, entry.lane_max_x)

	enemy.transform = t
	get_parent().add_child(enemy)

func start_spawning() -> void:
	spawn_timer.start()

func stop_spawning() -> void:
	spawn_timer.stop()

func _get_chunk_spawn_transform() -> Transform3D:
	var train_z: float = 0.0
	if is_instance_valid(terrain_manager) and is_instance_valid(terrain_manager.train):
		train_z = terrain_manager.train.global_position.z

	if is_instance_valid(terrain_manager) and not terrain_manager.active_chunks.is_empty():
		var candidates: Array[Transform3D] = []
		for chunk in terrain_manager.active_chunks:
			if not is_instance_valid(chunk) or not chunk.has_method("get_random_spawn_transform"):
				continue
			var chunk_sp: Transform3D = chunk.get_random_spawn_transform()
			if chunk_sp.origin == Vector3.ZERO:
				continue
			var dist: float = train_z - chunk_sp.origin.z
			if dist >= min_spawn_distance and dist <= max_spawn_distance:
				candidates.append(chunk_sp)

		if not candidates.is_empty():
			return candidates.pick_random()

	var side_x = [-6.0, 6.0].pick_random() + randf_range(-1.0, 1.0)
	var spawn_z = train_z - randf_range(min_spawn_distance, max_spawn_distance)
	return Transform3D(Basis(), Vector3(side_x, 0.5, spawn_z))

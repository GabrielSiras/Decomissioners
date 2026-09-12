class_name EnemySpawner
extends Node3D

@export_category("Configurações do Spawner")
@export var enemy_scenes: Array[PackedScene] = []

@export var spawn_interval: float = 2.0

## Referência ao alvo principal 3D (ex: a Torre/Base do jogador)
@export var main_target: Node3D 

@onready var spawn_timer: Timer = $SpawnTimer
@onready var spawn_points_container: Node3D = $SpawnPoints

var spawn_points: Array[Marker3D] = []

func _ready() -> void:
	for child in spawn_points_container.get_children():
		if child is Marker3D:
			spawn_points.append(child)
			
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	spawn_enemy()

func spawn_enemy() -> void:
	if enemy_scenes.is_empty() or spawn_points.is_empty():
		return

	var random_enemy_scene: PackedScene = enemy_scenes.pick_random()
	var enemy_instance = random_enemy_scene.instantiate()
	var random_point: Marker3D = spawn_points.pick_random()

	if "target" in enemy_instance:
		enemy_instance.target = main_target

	get_parent().add_child(enemy_instance)

	enemy_instance.global_position = random_point.global_position

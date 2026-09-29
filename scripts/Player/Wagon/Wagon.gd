class_name Wagon
extends Node3D

@export var max_health: int = 100
@export var current_armor: int = 0
@onready var current_health: int = max_health

@export var max_slots: int = 3
@export var slot_z_offsets: Array[float] = [1.5, 0.0, -1.5]

var assigned_enemies: Array[Node3D] = []

func _ready() -> void:
	add_to_group("wagons")
	add_to_group("player_targets")

func _clean_dead_enemies() -> void:
	assigned_enemies = assigned_enemies.filter(func(e): return is_instance_valid(e))

func has_available_slot() -> bool:
	_clean_dead_enemies()
	return assigned_enemies.size() < max_slots

func occupy_slot(enemy: Node3D) -> int:
	_clean_dead_enemies()
	if assigned_enemies.size() < max_slots:
		assigned_enemies.append(enemy)
		return assigned_enemies.size() - 1
	return -1

func release_slot(enemy: Node3D) -> void:
	assigned_enemies.erase(enemy)

func get_slot_z_offset(slot_index: int) -> float:
	if slot_index >= 0 and slot_index < slot_z_offsets.size():
		return slot_z_offsets[slot_index]
	return 0.0

func take_damage(amount: int) -> void:
	var armor_reduction: float = clamp(current_armor, 0, 100) / 100.0
	var final_damage: int = max(1, roundi(amount * (1.0 - armor_reduction)))
	current_health -= final_damage
	if current_health <= 0:
		queue_free()

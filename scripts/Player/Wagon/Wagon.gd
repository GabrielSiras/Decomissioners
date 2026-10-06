class_name Wagon
extends Node3D

@export_category("Wagon Stats")
@export var max_health: int = 100
@export var current_armor: int = 0
@onready var current_health: int = max_health

@export_category("Movement & Following")
@export var target: Node3D
@export var train_head: TrainHead
@export var follow_distance: float = 3.5
@export var follow_speed: float = 12.0

@export_category("Enemy Slots")
@export var max_slots: int = 3
@export var slot_z_offsets: Array[float] = [1.5, 0.0, -1.5]

@onready var turret_slots_container: Node3D = $TurretSlots

var assigned_enemies: Array[Node3D] = []
var slots_status: Dictionary = {}

func _ready() -> void:
	add_to_group("wagons")
	add_to_group("player_targets")
	
	if not is_instance_valid(train_head):
		var parent = get_parent()
		while is_instance_valid(parent):
			if parent is TrainHead:
				train_head = parent
				break
			parent = parent.get_parent()
	
	if is_instance_valid(turret_slots_container):
		for slot in turret_slots_container.get_children():
			slots_status[slot] = _find_turret_in_slot(slot)

func _find_turret_in_slot(slot: Node) -> Node:
	for child in slot.get_children():
		if child.has_method("apply_supercharge") or child is TurretBase:
			return child
		for sub_child in child.get_children():
			if sub_child.has_method("apply_supercharge") or sub_child is TurretBase:
				return sub_child
	return null

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		return
		
	var target_pos = target.global_position + (target.global_transform.basis.z * follow_distance)
	
	global_position = global_position.lerp(target_pos, follow_speed * delta)
	
	global_basis = global_basis.slerp(target.global_basis, follow_speed * delta)

func place_turret_at_slot(target_slot: Node3D, turret_scene: PackedScene, cost: int) -> bool:
	if not slots_status.has(target_slot) or slots_status[target_slot] != null:
		return false

	if MetalManager.spend_metal(cost):
		var turret_instance = turret_scene.instantiate()
		target_slot.add_child(turret_instance)
		turret_instance.position = Vector3.ZERO
		turret_instance.rotation = Vector3.ZERO
		slots_status[target_slot] = turret_instance
		return true
	return false

func demolish_turret_at_slot(target_slot: Node3D) -> void:
	if not slots_status.has(target_slot) or slots_status[target_slot] == null:
		return
		
	var turret_instance = slots_status[target_slot]
	var refund_amount: int = 0
	if "build_cost" in turret_instance:
		refund_amount = int(turret_instance.build_cost * 0.3)
	
	if MetalManager.has_method("add_metal"):
		MetalManager.add_metal(refund_amount)
	elif MetalManager.has_method("gain_metal"):
		MetalManager.gain_metal(refund_amount)
	
	turret_instance.queue_free()
	slots_status[target_slot] = null

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
		destroy_wagon()

func destroy_wagon() -> void:
	# aqui coloca os vfxs
	
	if is_instance_valid(train_head):
		train_head.wagons.erase(self)
		train_head.call_deferred("rearrange_wagons")
		
	queue_free()

func apply_supercharge_to_turrets(damage_mult: float, speed_mult: float, duration: float) -> void:
	if not is_instance_valid(turret_slots_container):
		return

	for slot in turret_slots_container.get_children():
		var turret_instance = slots_status.get(slot)
		
		if not is_instance_valid(turret_instance):
			turret_instance = _find_turret_in_slot(slot)
			if is_instance_valid(turret_instance):
				slots_status[slot] = turret_instance
		
		if is_instance_valid(turret_instance) and turret_instance.has_method("apply_supercharge"):
			turret_instance.apply_supercharge(damage_mult, speed_mult, duration)

func has_any_turret() -> bool:
	if not is_instance_valid(turret_slots_container):
		return false

	for slot in turret_slots_container.get_children():
		var turret_instance = slots_status.get(slot)
		if not is_instance_valid(turret_instance):
			turret_instance = _find_turret_in_slot(slot)
			if is_instance_valid(turret_instance):
				slots_status[slot] = turret_instance
		
		if is_instance_valid(turret_instance):
			return true
			
	return false

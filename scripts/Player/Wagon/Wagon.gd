class_name Wagon
extends Node3D

@export_category("Wagon Stats")
@export var max_health: int = 100
@export var current_armor: int = 0
@onready var current_health: int = max_health
@export var health_bar_scene: PackedScene
var health_bar: HealthBarUI = null
@export var health: float = 100.0:
	set(value):
		health = clamp(value, 0.0, float(max_health))
		if is_instance_valid(health_bar):
			health_bar.health = health
		current_health = int(health)

@export_category("Movement & Following")
@export var target: Node3D
@export var train_head: TrainHead
@export var follow_distance: float = 3.5
@export var follow_speed: float = 12.0

@export_category("Enemy Slots")
@export var max_slots: int = 3
@export var slot_z_offsets: Array[float] = [1.5, 0.0, -1.5]

@export_category("Metal Storage")
@export var metal_capacity: int = 300
@export var starting_metal: int = 300
var stored_metal: int = 0

@onready var turret_slots_container: Node3D = $TurretSlots
@export var bar_offset: Vector3 = Vector3(0, 1.5, 2)

var slots_status: Dictionary = {}
@onready var slot_owners: Array = _make_slots()

func _ready() -> void:
	slot_owners.resize(max_slots)
	stored_metal = min(starting_metal, metal_capacity)
	MetalManager.register_storage(self)
	
	add_to_group("wagons")
	add_to_group("player_targets")
	
	health = float(max_health)
	
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
	
func _make_slots() -> Array:
	var arr := []
	arr.resize(max_slots)
	return arr

func _find_turret_in_slot(slot: Node) -> Node:
	for child in slot.get_children():
		if child.has_method("apply_supercharge") or child is TurretBase:
			return child
		for sub_child in child.get_children():
			if sub_child.has_method("apply_supercharge") or sub_child is TurretBase:
				return sub_child
	return null

func _process(_delta: float) -> void:
	_update_bar_position()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		return
		
	var target_pos = target.global_position + (target.global_transform.basis.z * follow_distance)
	
	global_position = global_position.lerp(target_pos, follow_speed * delta)
	global_basis = global_basis.slerp(target.global_basis, follow_speed * delta)

func _update_bar_position() -> void:
	var camera := get_viewport().get_camera_3d()
	if not is_instance_valid(health_bar) or not is_instance_valid(camera):
		return
	var world_pos = global_position + bar_offset
	health_bar.visible = not camera.is_position_behind(world_pos)
	if health_bar.visible:
		health_bar.position = camera.unproject_position(world_pos) - health_bar.size * 0.5

func _exit_tree() -> void:
	if is_instance_valid(health_bar):
		health_bar.queue_free()

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

func has_available_slot() -> bool:
	for o in slot_owners:
		if not is_instance_valid(o):
			return true
	return false

func occupy_slot(enemy: Node3D) -> int:
	for i in slot_owners.size():
		if not is_instance_valid(slot_owners[i]):
			slot_owners[i] = enemy
			return i
	return -1

func release_slot(enemy: Node3D) -> void:
	var idx := slot_owners.find(enemy)
	if idx >= 0:
		slot_owners[idx] = null

func get_slot_z_offset(slot_index: int) -> float:
	if slot_index >= 0 and slot_index < slot_z_offsets.size():
		return slot_z_offsets[slot_index]
	return 0.0

func take_damage(amount: int) -> void:
	if health <= 0:
		return
		
	var armor_reduction: float = clamp(current_armor, 0, 100) / 100.0
	var final_damage: float = max(1.0, float(amount) * (1.0 - armor_reduction))
	
	health -= final_damage
	
	if health <= 0:
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

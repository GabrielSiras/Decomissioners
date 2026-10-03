class_name TrainHead
extends Node3D

@export_category("Train Status")
@onready var turret_slots_container: Node3D = $TurretSlots
@export var max_health: int = 200
@export var max_speed: float = 15.0
@onready var current_health: int = max_health
@export var current_armor: int = 10
@export var wagons: Array[Wagon] = []
@export var current_speed: float = 0.0
@export var wheel_markers: Array[Marker3D] = []
@export_category("MENUs/HUDs")
@export var defeat_menu: DefeatMenu
@export var speed_lever: SpeedLever
@export var progress_bar: CanvasLayer
@export var destination_node: Node3D
@export_category("EMP SKILL")
@export var emp_radius: float = 12.0
@export var emp_force: float = 25.0
@export_category("VFXs")
@export var brake_vfx_scene: PackedScene
var brake_vfx_cooldown_timer: float = 0.0
var slots_status: Dictionary = {}
var current_speed_factor: float = 0.0
var velocity: Vector3 = Vector3.ZERO
var start_position: Vector3
var total_distance: float = 0.0


func _ready() -> void:
	if is_instance_valid(speed_lever):
		speed_lever.braked.connect(_on_train_braked)
		speed_lever.speed_changed.connect(_on_speed_changed)

	add_to_group("player_base")
	start_position = global_position
	
	_update_wagons_list()
	
	current_speed = max_speed * current_speed_factor
	
	if is_instance_valid(destination_node):
		total_distance = start_position.distance_to(destination_node.global_position)
	
	_register_all_slots()

func _physics_process(delta: float) -> void:
	if brake_vfx_cooldown_timer > 0.0:
		brake_vfx_cooldown_timer -= delta

	var actual_speed = max(0.0, current_speed)
	velocity = -global_transform.basis.z * actual_speed
	global_position += velocity * delta

	if speed_lever and max_speed > 0.0:
		var visual_factor = clamp(current_speed / max_speed, 0.0, 1.0)
		speed_lever.update_slider_visual(visual_factor)

	_update_progress()

func _on_train_braked() -> void:
	trigger_brake_vfx()

func trigger_brake_vfx() -> void:
	if brake_vfx_cooldown_timer > 0.0:
		return

	if not brake_vfx_scene or wheel_markers.is_empty():
		return

	brake_vfx_cooldown_timer = 0.4

	for marker in wheel_markers:
		if is_instance_valid(marker):
			var vfx = brake_vfx_scene.instantiate()
			marker.add_child(vfx)

func _clean_wagons_list() -> void:
	wagons = wagons.filter(func(w): return is_instance_valid(w) and not w.is_queued_for_deletion())

func rearrange_wagons() -> void:
	wagons = wagons.filter(func(w): return is_instance_valid(w) and not w.is_queued_for_deletion())
	
	if wagons.is_empty():
		return
		
	if "target" in wagons[0]:
		wagons[0].target = self
		
	for i in range(1, wagons.size()):
		if "target" in wagons[i]:
			wagons[i].target = wagons[i - 1]

func get_train_center_position() -> Vector3:
	_clean_wagons_list()
	
	if wagons.is_empty():
		return global_position
		
	var last_wagon = wagons[-1]
	if is_instance_valid(last_wagon):
		return (global_position + last_wagon.global_position) * 0.5
		
	return global_position

func _register_all_slots() -> void:
	slots_status.clear()
	
	if is_instance_valid(turret_slots_container):
		for slot in turret_slots_container.get_children():
			slots_status[slot] = null
			
	for wagon in wagons:
		if is_instance_valid(wagon) and wagon.has_node("TurretSlots"):
			for slot in wagon.get_node("TurretSlots").get_children():
				slots_status[slot] = null

func _update_wagons_list() -> void:
	wagons.clear()
	for child in get_children():
		if child is Wagon:
			wagons.append(child)

func _update_progress() -> void:
	if not progress_bar or not is_instance_valid(destination_node) or total_distance <= 0.0:
		return
		
	var current_distance = global_position.distance_to(destination_node.global_position)
	var distance_traveled = total_distance - current_distance
	var progress_percentage = (distance_traveled / total_distance) * 100.0
	
	if progress_bar.has_method("update_progress"):
		progress_bar.update_progress(progress_percentage)
		
	elif progress_bar.has_node("ProgressBar"):
		progress_bar.get_node("ProgressBar").value = progress_percentage
	
	elif progress_bar.has_method("update_progress"):
		progress_bar.update_progress(progress_percentage)
	
	if current_distance <= 1.2:
		_on_destination_reached()

func _on_destination_reached() -> void:
	print("O trem chegou à estação final!")
	
	var win_menu_scene = load("res://scenes/UI-UX/UI/MENUs/WinMenu.tscn")
	if win_menu_scene:
		var win_menu_instance = win_menu_scene.instantiate()
		get_tree().current_scene.add_child(win_menu_instance)
		
		get_tree().paused = true
	
func _on_speed_changed(factor: float) -> void:
	current_speed_factor = factor
	current_speed = max_speed * current_speed_factor

func get_available_slots() -> Array[Marker3D]:
	var available: Array[Marker3D] = []
	for slot in slots_status.keys():
		if slots_status[slot] == null:
			available.append(slot)
	return available

func place_turret_at_slot(target_slot: Node3D, turret_scene: PackedScene, cost: int) -> bool:
	if not slots_status.has(target_slot):
		print("Slot inválido!")
		return false
		
	if slots_status[target_slot] != null:
		print("Este slot já está ocupado!")
		return false

	if MetalManager.spend_metal(cost):
		var turret_instance = turret_scene.instantiate()
		
		target_slot.add_child(turret_instance)
		
		turret_instance.position = Vector3.ZERO
		turret_instance.rotation = Vector3.ZERO
		
		slots_status[target_slot] = turret_instance
		print("Torre construída com sucesso no slot!")
		return true
	else:
		print("Metal insuficiente para construir a torre!")
		return false

func demolish_turret_at_slot(target_slot: Node3D) -> void:
	if not slots_status.has(target_slot) or slots_status[target_slot] == null:
		return
		
	var turret_instance = slots_status[target_slot]
	
	# 30% de reembolso
	var refund_amount: int = 0
	if "build_cost" in turret_instance:
		refund_amount = int(turret_instance.build_cost * 0.3)
	
	if MetalManager.has_method("add_metal"):
		MetalManager.add_metal(refund_amount)
	elif MetalManager.has_method("gain_metal"):
		MetalManager.gain_metal(refund_amount)
	
	turret_instance.queue_free()
	slots_status[target_slot] = null
	
	print("Torre demolida! Reembolso de ", refund_amount, " moedas de metal.")

func take_damage(amount: int) -> void:
	if current_health <= 0:
		return
	
	var armor_reduction_percent: float = clamp(current_armor, 0, 100) / 100.0
	var damage_multiplier: float = 1.0 - armor_reduction_percent
	var final_damage: int = max(0, roundi(amount * damage_multiplier))
	current_health -= final_damage
	print(name, " recebeu ", final_damage, " de dano! (Dano bruto: ", amount, " | Armadura: ", current_armor, "%) | Vida: ", current_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	if(defeat_menu):
		defeat_menu.show_defeat()

func trigger_emp() -> void:
	print("⚡ PULSO EMP ATIVADO!")
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy is Node3D:
			var distance = global_position.distance_to(enemy.global_position)
			
			if distance <= emp_radius:
				var push_dir = (enemy.global_position - global_position).normalized()
				push_dir.y = 0
				
				if enemy.has_method("apply_knockback"):
					enemy.apply_knockback(push_dir * emp_force)

func play_brake_vfx(vfx_scene: PackedScene, spawn_point: Node3D) -> void:
	if not vfx_scene or not is_instance_valid(spawn_point):
		return

	var vfx = vfx_scene.instantiate()
	
	spawn_point.add_child(vfx)
	
	vfx.position = Vector3.ZERO
	vfx.rotation = Vector3.ZERO

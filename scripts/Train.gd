class_name Train
extends Node3D

@onready var turret_slots_container: Node3D = $TurretSlots
@export var defeat_menu: DefeatMenu
@export var max_health: int = 100
@export var max_speed: float = 15.0
@export var speed_lever: SpeedLever
@onready var current_health: int = max_health
@export var current_armor: int = 10
@export var progress_bar: CanvasLayer
@export var destination_node: Node3D

var slots_status: Dictionary = {}
var current_speed_factor: float = 0.0
var velocity: Vector3 = Vector3.ZERO
var start_position: Vector3
var total_distance: float = 0.0

func _ready() -> void:
	add_to_group("player_base")
	
	start_position = global_position
	
	if is_instance_valid(destination_node):
		total_distance = start_position.distance_to(destination_node.global_position)
	
	if speed_lever:
		speed_lever.speed_changed.connect(_on_speed_changed)
	
	for child in turret_slots_container.get_children():
		if child is Marker3D:
			slots_status[child] = null

func _physics_process(delta: float) -> void:
	var actual_speed = max_speed * current_speed_factor
	velocity = -global_transform.basis.z * actual_speed
	global_position += velocity * delta
	
	_update_progress()

func _update_progress() -> void:
	if not progress_bar or not is_instance_valid(destination_node) or total_distance <= 0.0:
		return
		
	var current_distance = global_position.distance_to(destination_node.global_position)
	print("Distância até o destino: ", current_distance)
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
	
	var win_menu_scene = load("res://scenes/UI-UX/UI/WinMenu.tscn")
	if win_menu_scene:
		var win_menu_instance = win_menu_scene.instantiate()
		get_tree().current_scene.add_child(win_menu_instance)
		
		get_tree().paused = true
	
func _on_speed_changed(factor: float) -> void:
	current_speed_factor = factor

## lista com os Marker3D que ainda estão sem torreta
func get_available_slots() -> Array[Marker3D]:
	var available: Array[Marker3D] = []
	for slot in slots_status.keys():
		if slots_status[slot] == null:
			available.append(slot)
	return available

## nova torreta no primeiro slot disponível se houver Metal suficiente
func place_turret(turret_scene: PackedScene, cost: int) -> bool:
	var free_slots = get_available_slots()
	
	if free_slots.is_empty():
		print("Todos os slots do trem estão ocupados!")
		return false

	# Tenta gastar o metal c/Autoload
	if MetalManager.spend_metal(cost):
		var target_slot: Marker3D = free_slots[0]
		var turret_instance = turret_scene.instantiate()
		
		# Posicionando a torretin exatament no marker3d
		turret_instance.global_position = target_slot.global_position
		add_child(turret_instance)
		
		# Marcando o slot como ocupado pela nova torreta
		slots_status[target_slot] = turret_instance
		print("Torreta construída com sucesso!")
		return true
	else:
		print("Metal insuficiente para construir a torreta!")
		return false

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

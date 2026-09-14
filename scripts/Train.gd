class_name Train
extends Node3D

@onready var turret_slots_container: Node3D = $TurretSlots
@export var defeat_menu: DefeatMenu
@export var max_health: int = 100
@onready var current_health: int = max_health
@export var current_armor: int = 10

var slots_status: Dictionary = {}

func _ready() -> void:
	add_to_group("player_base")
	
	for child in turret_slots_container.get_children():
		if child is Marker3D:
			slots_status[child] = null

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

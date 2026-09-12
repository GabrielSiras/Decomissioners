class_name Train
extends Node3D

@onready var turret_slots_container: Node3D = $TurretSlots

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

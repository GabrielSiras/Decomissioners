extends Node

signal metal_changed(new_amount: int)

@export var total_metal: int = 0

func add_metal(amount: int) -> void:
	total_metal += amount
	metal_changed.emit(total_metal)

func spend_metal(amount: int) -> bool:
	if total_metal >= amount:
		total_metal -= amount
		metal_changed.emit(total_metal)
		return true # Compra ok
	return false # Sem metal

func get_metal() -> int:
	return total_metal

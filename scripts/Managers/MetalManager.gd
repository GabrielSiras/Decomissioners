extends Node

signal metal_changed(new_amount: int)
signal metal_lost(amount: int)
signal metal_overflow(amount: int)

var storages: Array[Node] = []

var total_metal: int:
	get: return get_metal()

func register_storage(storage: Node) -> void:
	if storage in storages:
		return
	storages.append(storage)
	storage.tree_exiting.connect(_on_storage_exiting.bind(storage))
	metal_changed.emit(get_metal())

func _on_storage_exiting(storage: Node) -> void:
	storages.erase(storage)
	var lost: int = storage.stored_metal
	storage.stored_metal = 0
	if lost > 0:
		metal_lost.emit(lost)
	metal_changed.emit(get_metal())

func get_metal() -> int:
	var total := 0
	for s in storages:
		if is_instance_valid(s):
			total += s.stored_metal
	return total

func get_total_capacity() -> int:
	var cap := 0
	for s in storages:
		if is_instance_valid(s):
			cap += s.metal_capacity
	return cap

func add_metal(amount: int) -> void:
	if amount <= 0:
		return

	var remaining := amount
	for s in storages:
		if remaining <= 0:
			break
		if not is_instance_valid(s):
			continue
		var free: int = s.metal_capacity - s.stored_metal
		var put: int = min(free, remaining)
		s.stored_metal += put
		remaining -= put

	if remaining > 0:
		metal_overflow.emit(remaining)

	metal_changed.emit(get_metal())

func spend_metal(amount: int) -> bool:
	if get_metal() < amount:
		return false

	var remaining := amount
	for s in storages:
		if remaining <= 0:
			break
		if not is_instance_valid(s):
			continue
		var take: int = min(s.stored_metal, remaining)
		s.stored_metal -= take
		remaining -= take

	metal_changed.emit(get_metal())
	return true

extends Node

var data: Dictionary = {}

func has_checkpoint(level_id: String) -> bool:
	return data.get("level_id", "") == level_id

func clear() -> void:
	print("CHECKPOINT LIMPO")
	data.clear()

func save_checkpoint(train: TrainHead) -> void:
	var wagon_list: Array = []
	for w in train.wagons:
		if is_instance_valid(w):
			wagon_list.append({
				"name": String(w.name),
				"health": w.health,
				"metal": w.stored_metal,
				"turrets": _collect_turrets(w.turret_slots_container),
			})
	data = {
		"level_id": train.level_id,
		"position": train.global_position,
		"health": train.health,
		"head_metal": train.stored_metal,
		"head_turrets": _collect_turrets(train.turret_slots_container),
		"wagons": wagon_list,
	}

func _collect_turrets(container: Node) -> Array:
	var list: Array = []
	if not is_instance_valid(container):
		return list
	for slot in container.get_children():
		for child in slot.get_children():
			if child.has_meta("scene_path") and not child.is_queued_for_deletion():
				list.append({
					"slot": String(slot.name),
					"scene": child.get_meta("scene_path"),
					"level": child.turret_level,
				})
				break
	return list

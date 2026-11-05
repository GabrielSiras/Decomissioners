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
			wagon_list.append({"name": String(w.name), "health": w.health, "metal": w.stored_metal})
	data = {
		"level_id": train.level_id,
		"position": train.global_position,
		"health": train.health,
		"wagons": wagon_list,
	}
	print("CHECKPOINT SALVO: ", data)

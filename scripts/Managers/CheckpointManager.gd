extends Node

const SAVE_PATH := "user://checkpoint.cfg"
const SECTION := "checkpoint"

var data: Dictionary = {}

func _ready() -> void:
	load_checkpoint()

func has_any_checkpoint() -> bool:
	return data.has("level_id") and data.has("position") and data.has("health")

func has_checkpoint_for_level(level_id: String) -> bool:
	return has_any_checkpoint() and str(data.get("level_id", "")) == level_id

func get_level_id() -> String:
	return str(data.get("level_id", ""))

func save_checkpoint(train: TrainHead) -> void:
	data.clear()

	data["level_id"] = str(train.level_id)
	data["position"] = vec3_to_string(train.global_position)
	data["health"] = str(train.health)
	data["head_metal"] = str(train.stored_metal)
	data["head_turrets"] = JSON.stringify(_collect_turrets(train.turret_slots_container))
	data["wagons"] = JSON.stringify(_collect_wagons(train.wagons))
	data["current_gate_index"] = str(train.current_gate_index)
	data["spawner_phase_index"] = str(train.spawner_phase_index + 1)

	var cfg := ConfigFile.new()
	for key in data.keys():
		cfg.set_value(SECTION, key, data[key])
	cfg.save(SAVE_PATH)

func load_checkpoint() -> void:
	data.clear()

	if not FileAccess.file_exists(SAVE_PATH):
		return

	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return

	data["level_id"] = cfg.get_value(SECTION, "level_id", "")
	data["position"] = cfg.get_value(SECTION, "position", "")
	data["health"] = cfg.get_value(SECTION, "health", "")
	data["head_metal"] = cfg.get_value(SECTION, "head_metal", "")
	data["head_turrets"] = cfg.get_value(SECTION, "head_turrets", "")
	data["wagons"] = cfg.get_value(SECTION, "wagons", "")
	data["current_gate_index"] = cfg.get_value(SECTION, "current_gate_index", "")
	data["spawner_phase_index"] = cfg.get_value(SECTION, "spawner_phase_index", "")

func clear() -> void:
	print("CHECKPOINT LIMPO")
	data.clear()
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

func vec3_to_string(v: Vector3) -> String:
	return "%s,%s,%s" % [v.x, v.y, v.z]

func string_to_vec3(s: String) -> Vector3:
	var parts := s.split(",")
	if parts.size() < 3:
		return Vector3.ZERO
	return Vector3(float(parts[0]), float(parts[1]), float(parts[2]))

func _collect_wagons(wagons: Array) -> Array:
	var list: Array = []
	for w in wagons:
		if is_instance_valid(w):
			list.append({
				"name": String(w.name),
				"health": w.health,
				"metal": w.stored_metal,
				"turrets": _collect_turrets(w.turret_slots_container),
			})
	return list

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

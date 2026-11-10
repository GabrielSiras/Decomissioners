class_name RepairSkill
extends Node3D

signal skill_executed
signal cancelled

@export var pick_radius_px: float = 90.0

var targeting: bool = false
var train: Node3D

func get_cost() -> int:
	return int(UpgradeManager.pick(UpgradeManager.REPAIR_COST, "Repair"))

func get_cooldown() -> float:
	return UpgradeManager.pick(UpgradeManager.REPAIR_COOLDOWN, "Repair")

func activate_skill_targeting() -> void:
	if MetalManager.get_metal() < get_cost():
		print("Metal insuficiente para Repair")
		return
	train = get_tree().get_first_node_in_group("player_base")
	targeting = true

func _unhandled_input(event: InputEvent) -> void:
	if not targeting:
		return
	var is_touch: bool = event is InputEventScreenTouch and event.pressed
	var is_click: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	if not (is_touch or is_click):
		return
	get_viewport().set_input_as_handled()
	targeting = false

	var target := _pick_target(event.position)
	if target == null or not MetalManager.spend_metal(get_cost()):
		cancelled.emit()
		return

	var amount: float = UpgradeManager.pick(UpgradeManager.REPAIR_HEAL, "Repair")
	target.health += amount
	skill_executed.emit()

func _pick_target(screen_pos: Vector2) -> Node3D:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return null
	var best: Node3D = null
	var best_d: float = pick_radius_px
	for n in get_tree().get_nodes_in_group("player_targets"):
		if not is_instance_valid(n) or not "health" in n or n.health <= 0.0:
			continue
		var d := camera.unproject_position(n.global_position).distance_to(screen_pos)
		if d < best_d:
			best_d = d
			best = n
	return best

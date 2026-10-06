class_name SuperchargeSkill
extends Node

@export_category("Atributos da Sobrecarga")
@export var damage_multiplier: float = 1.5
@export var attack_speed_multiplier: float = 1.8
@export var duration: float = 8.0
@export var cooldown: float = 15.0

@export_category("Referências")
@export var building_ui: Control

var is_targeting: bool = false
var is_on_cooldown: bool = false

signal skill_executed

func activate_skill_targeting() -> void:
	is_targeting = true
	
	if is_instance_valid(building_ui):
		building_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _unhandled_input(event: InputEvent) -> void:
	if not is_targeting:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_cancel_targeting()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var input_pos = event.position
		var clicked_wagon = _raycast_select_wagon(input_pos)

		if is_instance_valid(clicked_wagon):
			if _apply_supercharge_on_wagon(clicked_wagon):
				_cancel_targeting()
				_start_cooldown()
				skill_executed.emit()
			else:
				print("Escolha um vagão que contenha pelo menos uma torre.")
		else:
			print("O clique funcionou, mas o Raycast NÃO acertou em nada na Layer 2!")

		get_viewport().set_input_as_handled()

func _raycast_select_wagon(screen_pos: Vector2) -> Node3D:
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return null

	var ray_origin = camera.project_ray_origin(screen_pos)
	var ray_end = ray_origin + camera.project_ray_normal(screen_pos) * 2000.0

	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collision_mask = 2
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var space_state = camera.get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)

	if result:
		var hit_collider = result.collider
		var current_node: Node = hit_collider
		while is_instance_valid(current_node):
			if current_node.is_in_group("wagons") or current_node.is_in_group("player_targets"):
				return current_node as Node3D
			current_node = current_node.get_parent()
			
	return null

func _apply_supercharge_on_wagon(target: Node3D) -> bool:
	if not is_instance_valid(target):
		return false

	if target.has_method("has_any_turret"):
		if not target.has_any_turret():
			print("O alvo '", target.name, "' não possui nenhuma torre construída!")
			return false

	if target.has_method("apply_supercharge_to_turrets"):
		target.apply_supercharge_to_turrets(damage_multiplier, attack_speed_multiplier, duration)
		print("Sobrecarga aplicada com sucesso em: ", target.name)
		return true

	return false

func _cancel_targeting() -> void:
	is_targeting = false
	
	if is_instance_valid(building_ui):
		building_ui.mouse_filter = Control.MOUSE_FILTER_STOP

func _start_cooldown() -> void:
	is_on_cooldown = true
	await get_tree().create_timer(cooldown).timeout
	is_on_cooldown = false

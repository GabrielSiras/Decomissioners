class_name ThreatIndicators
extends Control

@export var indicator_scene: PackedScene
@export var train: Node3D
@export var detection_radius: float = 70.0
@export var edge_margin: float = 40.0
@export var tracked_groups: Array[String] = ["enemies"]

@export_category("Pisca por Proximidade")
@export var blink_speed_far: float = 2.0
@export var blink_speed_near: float = 10.0
@export var min_alpha: float = 0.25   

var indicators: Dictionary = {}
var blink_phase: Dictionary = {}

func _process(delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	if not is_instance_valid(camera) or not is_instance_valid(train):
		return

	var screen_rect := Rect2(Vector2.ZERO, get_viewport_rect().size)
	var inner_rect := screen_rect.grow(-edge_margin)
	var seen: Array = []

	for group in tracked_groups:
		for enemy in get_tree().get_nodes_in_group(group):
			if not is_instance_valid(enemy) or not enemy is Node3D:
				continue
			if not _should_warn(enemy):
				continue

			var dist: float = train.global_position.distance_to(enemy.global_position)
			if dist > detection_radius:
				continue

			var world_pos: Vector3 = enemy.global_position
			var behind := camera.is_position_behind(world_pos)
			var screen_pos := camera.unproject_position(world_pos)

			if not behind and screen_rect.has_point(screen_pos):
				continue

			seen.append(enemy)
			var ind := _get_indicator(enemy)
			ind.visible = true
			ind.position = _clamp_to_edge(screen_pos, inner_rect, behind) - ind.size * 0.5

			var closeness: float = 1.0 - clamp(dist / detection_radius, 0.0, 1.0)
			var speed: float = lerp(blink_speed_far, blink_speed_near, closeness)

			blink_phase[enemy] = blink_phase.get(enemy, 0.0) + delta * speed * TAU
			var wave: float = (sin(blink_phase[enemy]) + 1.0) * 0.5   # 0..1
			var alpha: float = lerp(min_alpha, 1.0, wave)
			var tint: float = lerp(1.0, 0.4, closeness)
			ind.modulate = Color(1.0, tint, tint, alpha)
			ind.scale = Vector2.ONE * lerp(0.8, 1.3, closeness)

	for enemy in indicators.keys():
		if not is_instance_valid(enemy) or not seen.has(enemy):
			if is_instance_valid(indicators[enemy]):
				indicators[enemy].queue_free()
			indicators.erase(enemy)
			blink_phase.erase(enemy)

func _should_warn(enemy: Node) -> bool:
	return true

func _get_indicator(enemy: Node3D) -> Control:
	if indicators.has(enemy) and is_instance_valid(indicators[enemy]):
		return indicators[enemy]
	var ind: Control = indicator_scene.instantiate()
	add_child(ind)
	indicators[enemy] = ind
	return ind

func _clamp_to_edge(screen_pos: Vector2, inner: Rect2, behind: bool) -> Vector2:
	var center := inner.get_center()
	var dir := screen_pos - center
	if behind:
		dir = -dir
	if dir.is_zero_approx():
		return center

	var half := inner.size * 0.5
	var scale_x: float = half.x / max(abs(dir.x), 0.001)
	var scale_y: float = half.y / max(abs(dir.y), 0.001)
	return center + dir * min(scale_x, scale_y)

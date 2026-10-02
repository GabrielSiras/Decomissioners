class_name Bombardment
extends Node3D

signal executed
signal cancelled

@export_category("Configurações do Bombardeio")
@export var damage: int = 400
@export var damage_radius: float = 3.0
@export var explosion_effect_scene: PackedScene
@export var lifetime: float = 1.0

var camera: Camera3D

func _ready() -> void:
	camera = get_viewport().get_camera_3d()
	
	for child in get_children():
		if child is GPUParticles3D or child is CPUParticles3D:
			child.restart()
			child.emitting = true
	
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _unhandled_input(event: InputEvent) -> void:
	var is_touch = event is InputEventScreenTouch and event.pressed
	var is_click = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed

	if is_touch or is_click:
		var touch_pos: Vector2 = event.position
		var ground_pos: Vector3 = _get_touch_ground_position(touch_pos)

		if ground_pos != Vector3.ZERO:
			if not _check_train_overlap(ground_pos):
				_execute_attack(ground_pos)
			else:
				print("❌ Não é possível bombardear em cima do comboio!")
				cancelled.emit()
				queue_free()

func _execute_attack(target_position: Vector3) -> void:
	global_position = target_position

	if explosion_effect_scene:
		var explosion = explosion_effect_scene.instantiate()
		get_parent().add_child(explosion)
		explosion.global_position = target_position

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = damage_radius
	query.shape = sphere
	query.transform.origin = target_position

	var results = space_state.intersect_shape(query)
	for result in results:
		var body = result["collider"]
		if is_instance_valid(body) and body.is_in_group("enemies"):
			if body.has_method("take_damage"):
				body.take_damage(damage)

	executed.emit()
	queue_free()

func spawn_explosion_vfx(spawn_position: Vector3) -> void:
	if explosion_effect_scene:
		var explosion = explosion_effect_scene.instantiate()
		
		get_tree().current_scene.add_child(explosion)
		
		explosion.global_position = spawn_position

func _check_train_overlap(pos: Vector3) -> bool:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = damage_radius
	query.shape = sphere
	query.transform.origin = pos

	var results = space_state.intersect_shape(query)
	for result in results:
		var body = result["collider"]
		if is_instance_valid(body):
			if body.is_in_group("player_targets") or body.is_in_group("wagons"):
				return true
	return false

func _get_touch_ground_position(screen_pos: Vector2) -> Vector3:
	if not is_instance_valid(camera): 
		return Vector3.ZERO

	var ray_origin = camera.project_ray_origin(screen_pos)
	var ray_direction = camera.project_ray_normal(screen_pos)

	var ground_plane = Plane(Vector3.UP, 0.1)
	var hit_pos = ground_plane.intersects_ray(ray_origin, ray_direction)

	return hit_pos if hit_pos else Vector3.ZERO

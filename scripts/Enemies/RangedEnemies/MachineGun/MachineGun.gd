class_name MachineGun
extends RangedEnemy

@export_group("Slot & Posicionamento")
@export var shoulder_x_offset: float = 4.5
@export var catch_up_speed_bonus: float = 6.0
@export var x_follow_smoothness: float = 6.0
@export var z_follow_smoothness: float = 4.0

@export_group("Combate & Mira")
@export var attack_distance_threshold: float = 2.5
@export var stop_attack_distance_threshold: float = 4.0
@export var rotation_speed: float = 12.0
@export var mesh_y_offset_deg: float = 0.0

var current_target_node: Node3D = null
var assigned_slot_index: int = -1
var slot_z_offset: float = 0.0

func _ready() -> void:
	super._ready()

func setup_target(train_node: Node3D) -> void:
	target = train_node
	_find_available_slot()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		return

	_ensure_valid_slot()
	var active_target = _get_active_target()

	_update_movement(active_target)
	_update_rotation(active_target, delta)
	_update_attack_state(active_target)
	_apply_physics(delta)

func _ensure_valid_slot() -> void:
	if not is_instance_valid(current_target_node):
		_find_available_slot()

func _find_available_slot() -> void:
	if not is_instance_valid(target):
		return

	if "wagons" in target and target.wagons.size() > 0:
		for i in range(target.wagons.size() - 1, -1, -1):
			var wagon = target.wagons[i]
			if is_instance_valid(wagon) and wagon.has_method("has_available_slot") and wagon.has_available_slot():
				current_target_node = wagon
				assigned_slot_index = wagon.occupy_slot(self)
				if wagon.has_method("get_slot_z_offset"):
					slot_z_offset = wagon.get_slot_z_offset(assigned_slot_index)
				return

	current_target_node = target

func _get_active_target() -> Node3D:
	return current_target_node if is_instance_valid(current_target_node) else target


func _update_movement(active_target: Node3D) -> void:
	if knockback_velocity.length() >= 2.0:
		return

	var train_spd: float = target.current_speed if "current_speed" in target else 8.0

	var target_x = active_target.global_position.x + shoulder_x_offset
	var target_z = active_target.global_position.z + slot_z_offset

	var x_diff = target_x - global_position.x
	var x_vel = clamp(x_diff * x_follow_smoothness, -speed, speed)

	var z_diff = target_z - global_position.z
	var z_correction = clamp(z_diff * z_follow_smoothness, -catch_up_speed_bonus, catch_up_speed_bonus)
	var z_vel = -train_spd + z_correction

	velocity = Vector3(x_vel, 0.0, z_vel)

func _apply_physics(delta: float) -> void:
	var final_velocity = velocity + knockback_velocity
	velocity = final_velocity
	move_and_slide()

	if knockback_velocity.length() > 0.01:
		knockback_velocity = knockback_velocity.move_toward(Vector3.ZERO, knockback_friction * delta)
	else:
		knockback_velocity = Vector3.ZERO

func _update_rotation(active_target: Node3D, delta: float) -> void:
	var target_pos = active_target.global_position
	var look_target = Vector3(target_pos.x, global_position.y, target_pos.z)

	if global_position.distance_squared_to(look_target) > 0.01:
		var target_transform = global_transform.looking_at(look_target, Vector3.UP)
		
		if mesh_y_offset_deg != 0.0:
			target_transform.basis = target_transform.basis.rotated(Vector3.UP, deg_to_rad(mesh_y_offset_deg))
		
		global_transform.basis = global_transform.basis.slerp(target_transform.basis, rotation_speed * delta)

func _update_attack_state(active_target: Node3D) -> void:
	var current_z_target = active_target.global_position.z + slot_z_offset
	var z_diff = current_z_target - global_position.z

	if abs(z_diff) < attack_distance_threshold:
		if not is_attacking:
			is_attacking = true
			shoot_at_target()
			_start_attack_timer()
	elif abs(z_diff) > stop_attack_distance_threshold:
		if is_attacking:
			is_attacking = false
			_stop_attack_timer()

func _start_attack_timer() -> void:
	if attack_timer:
		attack_timer.start(attack_cooldown)

func _stop_attack_timer() -> void:
	if attack_timer and not attack_timer.is_stopped():
		attack_timer.stop()

func _on_attack_timer_timeout() -> void:
	if is_attacking:
		shoot_at_target()
		_start_attack_timer()

func shoot_at_target() -> void:
	if not enemy_projectile_scene:
		print("[MachineGun] enemy_projectile_scene não atribuído!")
		return
	if not is_instance_valid(muzzle):
		return

	var proj = enemy_projectile_scene.instantiate()
	get_parent().add_child(proj)
	proj.global_transform = muzzle.global_transform

	var active_target = _get_active_target()
	if is_instance_valid(active_target) and proj.has_method("setup"):
		proj.setup(active_target, ranged_damage)

func _exit_tree() -> void:
	if is_instance_valid(current_target_node) and current_target_node.has_method("release_slot"):
		current_target_node.release_slot(self)

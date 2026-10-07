class_name Opressor
extends MeleeEnemy

enum State {
	WAITING,
	CHASING,
	WINDUP,
	LUNGE,
	LATCHED,
	COOLDOWN
}

var current_state: State = State.WAITING

@export_group("Acostamento & Movimento")
@export var shoulder_x_offset: float = 5.5
@export var catch_up_speed_bonus: float = 8.0

@export_group("Emboscada")
@export var activation_distance: float = 18.0

@export_group("Agarrão & Ataque")
@export var windup_duration: float = 0.8
@export var lunge_speed: float = 12.0
@export var lunge_max_duration: float = 1.0
@export var grab_distance: float = 2.5
@export var train_slow_amount: float = 1.0

@onready var state_timer: Timer = Timer.new()
@onready var damage_timer: Timer = Timer.new()

var current_target_wagon: Node3D = null
var assigned_slot_index: int = -1
var slot_z_offset: float = 0.0
var attached_slow: bool = false

func _ready() -> void:
	super._ready()
	
	if randf() < 0.5:
		shoulder_x_offset = -abs(shoulder_x_offset)
	else:
		shoulder_x_offset = abs(shoulder_x_offset)

	add_child(state_timer)
	state_timer.one_shot = true
	state_timer.timeout.connect(_on_state_timer_timeout)
	
	add_child(damage_timer)
	damage_timer.wait_time = attack_cooldown
	damage_timer.timeout.connect(_on_damage_timer_timeout)

func setup_target(train_node: Node3D) -> void:
	target = train_node
	_find_available_slot()

func _find_available_slot() -> void:
	if not is_instance_valid(target):
		return

	if "wagons" in target and target.wagons.size() > 0:
		for i in range(target.wagons.size() - 1, -1, -1):
			var wagon = target.wagons[i]
			if is_instance_valid(wagon) and wagon.has_method("has_available_slot") and wagon.has_available_slot():
				current_target_wagon = wagon
				assigned_slot_index = wagon.occupy_slot(self)
				if wagon.has_method("get_slot_z_offset"):
					slot_z_offset = wagon.get_slot_z_offset(assigned_slot_index)
				return

	current_target_wagon = target

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		return

	if not is_instance_valid(current_target_wagon) and current_state != State.LATCHED:
		_find_available_slot()

	var active_target = current_target_wagon if is_instance_valid(current_target_wagon) else target
	var train_spd: float = target.current_speed if "current_speed" in target else 8.0

	if knockback_velocity.length() > 0.5:
		if current_state == State.LATCHED:
			_detach_from_wagon()
		
		velocity = knockback_velocity
		move_and_slide()
		knockback_velocity = knockback_velocity.move_toward(Vector3.ZERO, knockback_friction * delta)
		return

	match current_state:
		State.WAITING:
			_process_waiting(active_target)

		State.CHASING:
			_process_chasing(active_target, train_spd)

		State.WINDUP:
			var target_z = active_target.global_position.z + slot_z_offset
			var z_diff = target_z - global_position.z
			velocity = Vector3(0, 0, -train_spd + clamp(z_diff * 4.0, -catch_up_speed_bonus, catch_up_speed_bonus))
			move_and_slide()

		State.LUNGE:
			_process_lunge(active_target, train_spd, delta)

		State.LATCHED:
			if not is_instance_valid(current_target_wagon):
				_detach_from_wagon()
			else:
				_process_latched(active_target)

		State.COOLDOWN:
			_process_cooldown(active_target, train_spd)

	_update_facing_direction(active_target)

func _process_waiting(active_target: Node3D) -> void:
	velocity = Vector3.ZERO
	move_and_slide()

	var z_dist = abs(global_position.z - active_target.global_position.z)

	if z_dist <= activation_distance:
		_find_available_slot()
		current_state = State.CHASING

func _process_chasing(active_target: Node3D, train_spd: float) -> void:
	var target_x = active_target.global_position.x + shoulder_x_offset
	var target_z = active_target.global_position.z + slot_z_offset

	var x_diff = target_x - global_position.x
	var z_diff = target_z - global_position.z

	var x_vel = clamp(x_diff * 5.0, -speed, speed)
	var z_correction = clamp(z_diff * 4.0, -catch_up_speed_bonus, catch_up_speed_bonus)
	var z_vel = -train_spd + z_correction

	velocity = Vector3(x_vel, 0, z_vel)
	move_and_slide()

	if abs(z_diff) < 2.0 and abs(x_diff) < 1.5:
		current_state = State.WINDUP
		state_timer.start(windup_duration)

func _process_lunge(active_target: Node3D, train_spd: float, delta: float) -> void:
	var dir_to_wagon_x = sign(active_target.global_position.x - global_position.x)
	var x_vel = dir_to_wagon_x * lunge_speed
	var z_vel = -train_spd

	velocity = Vector3(x_vel, 0, z_vel)
	move_and_slide()

	var dist_3d = global_position.distance_to(active_target.global_position)
	if dist_3d <= grab_distance:
		_latch_to_wagon()
	elif abs(global_position.x - active_target.global_position.x) > abs(shoulder_x_offset) * 1.5:
		_miss_lunge()

func _process_latched(active_target: Node3D) -> void:
	global_position = active_target.global_position + Vector3(shoulder_x_offset * 0.3, 0, slot_z_offset)
	velocity = Vector3.ZERO

	var train_node = _find_train_speed_node()
	if train_node and attached_slow == false:
		train_node.max_speed -= train_slow_amount
		train_node.current_speed = train_node.max_speed * train_node.current_speed_factor
		attached_slow = true
		
		if train_node.has_method("trigger_brake_vfx"):
			train_node.trigger_brake_vfx()

func _process_cooldown(active_target: Node3D, train_spd: float) -> void:
	var target_x = active_target.global_position.x + shoulder_x_offset
	var x_diff = target_x - global_position.x
	var x_vel = clamp(x_diff * 4.0, -speed, speed)

	var target_z = active_target.global_position.z + slot_z_offset
	var z_diff = target_z - global_position.z
	var z_vel = -train_spd + clamp(z_diff * 2.0, -catch_up_speed_bonus * 0.5, catch_up_speed_bonus * 0.5)

	velocity = Vector3(x_vel, 0, z_vel)
	move_and_slide()

func _on_state_timer_timeout() -> void:
	match current_state:
		State.WINDUP:
			current_state = State.LUNGE
			state_timer.start(lunge_max_duration)
		State.LUNGE:
			_miss_lunge()
		State.COOLDOWN:
			current_state = State.CHASING

func _find_train_speed_node() -> Node:
	var node: Node = target
	while is_instance_valid(node):
		if "current_speed" in node:
			return node
		node = node.get_parent()
	return null

	var terrain_mgr = get_tree().get_first_node_in_group("terrain_manager")
	if is_instance_valid(terrain_mgr) and "train" in terrain_mgr and is_instance_valid(terrain_mgr.train):
		if "current_speed" in terrain_mgr.train:
			return terrain_mgr.train

	return null

func _get_train_speed() -> float:
	var train_node = _find_train_speed_node()
	if train_node:
		print("Nó do trem encontrado: ", train_node.name)
		return train_node.current_speed
	
	print("⚠️ Não encontrou a variável 'current_speed' em nenhum nó pai!")
	return -1.0

func _latch_to_wagon() -> void:
	state_timer.stop()
	current_state = State.LATCHED
	damage_timer.start()

	var train_node = _find_train_speed_node()
	if train_node:
		print("🛑 Opressor AGARROU no trem! Velocidade atual: ", snapped(train_node.current_speed, 0.01))
		if train_node.has_method("trigger_brake_vfx"):
			train_node.trigger_brake_vfx()

func _miss_lunge() -> void:
	current_state = State.COOLDOWN
	state_timer.start(attack_cooldown)

func _detach_from_wagon() -> void:
	if current_state == State.LATCHED:
		damage_timer.stop()
		current_state = State.COOLDOWN
		
		if attached_slow == true:
			var train_node = _find_train_speed_node()
			train_node.max_speed += train_slow_amount
			train_node.current_speed = train_node.max_speed * train_node.current_speed_factor
			attached_slow = false
		
		state_timer.start(attack_cooldown)

func _on_damage_timer_timeout() -> void:
	if current_state == State.LATCHED and is_instance_valid(current_target_wagon):
		attack_target(current_target_wagon)

func _update_facing_direction(active_target: Node3D) -> void:
	var look_target = Vector3(active_target.global_position.x, global_position.y, active_target.global_position.z)
	if global_position.distance_squared_to(look_target) > 0.01:
		look_at(look_target, Vector3.UP, true)

func _exit_tree() -> void:
	if is_instance_valid(current_target_wagon) and current_target_wagon.has_method("release_slot"):
		current_target_wagon.release_slot(self)

func die() -> void:
	_detach_from_wagon()
	super()

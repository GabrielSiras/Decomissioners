class_name FighterJet
extends RangedEnemy

enum State { FOLLOW, PASS, TURN_BACK, STRAFE, TURN_FORWARD }

@export_category("Voo e Posicionamento")
@export var is_flying: bool = true
@export var side_distance: float = 6.0
@export var height_offset: float = 1.5
@export var smooth_speed: float = 5.0

@export_category("Manobra (Baliza)")
@export var cruise_speed: float = 14.0
@export var turn_rate: float = 2.2
@export var stopped_speed_threshold: float = 1.0
@export var stopped_time_before_pass: float = 1.0
@export var overshoot_front: float = 25.0
@export var overshoot_tail: float = 15.0 
@export var line_lookahead: float = 12.0
@export var fire_range: float = 16.0

@export_category("Rajada de Tiros")
@export var burst_count: int = 3
@export var fire_rate: float = 0.2

@export_category("Troca de Alvo")
@export var switch_time_min: float = 3.0
@export var switch_time_max: float = 6.0

@export_category("Separação")
@export var separation_radius: float = 5.0
@export var separation_strength: float = 10.0

var state: State = State.FOLLOW
var heading: Vector3 = Vector3(0, 0, -1)
var switch_timer: float = 0.0
var stopped_timer: float = 0.0
var is_on_left_side: bool = true
var train_ref: Node3D = null
var lane_offset: float = 0.0

func _ready() -> void:
	super._ready()
	add_to_group("flying")

	is_on_left_side = global_position.x < 0
	side_distance = -abs(side_distance) if is_on_left_side else abs(side_distance)

	_pick_new_wagon()
	
	lane_offset = randf_range(-3.0, 3.0)

func _physics_process(delta: float) -> void:
	var train := _get_train()
	if not is_instance_valid(train):
		return
	if not is_instance_valid(target):
		_pick_new_wagon()
		if not is_instance_valid(target):
			return

	var train_speed: float = train.current_speed if "current_speed" in train else 0.0
	var z_range := _train_z_range(train)
	var side_x: float = train.global_position.x + side_distance
	var ideal_y: float = train.global_position.y + height_offset
	var ai_velocity := Vector3.ZERO

	match state:
		State.FOLLOW:
			switch_timer -= delta
			if switch_timer <= 0.0:
				_pick_new_wagon()

			var ideal_pos := target.global_position
			ideal_pos.x += side_distance
			ideal_pos.y += height_offset + randf_range(0.0, 0.0)
			ideal_pos.z += lane_offset
			ai_velocity = (ideal_pos - global_position) * smooth_speed
			ai_velocity = ai_velocity.limit_length(cruise_speed * 1.5)

			_steer_to_dir(Vector3(0, 0, -1), delta)

			if train_speed < stopped_speed_threshold:
				stopped_timer += delta
				if stopped_timer >= stopped_time_before_pass:
					_set_state(State.PASS)
			else:
				stopped_timer = 0.0

		State.PASS:
			_pick_nearest_wagon()
			_steer_to_point(Vector3(side_x, 0, global_position.z - line_lookahead), delta)
			ai_velocity = _cruise_velocity(ideal_y)
			if global_position.z < z_range.x - overshoot_front:
				_set_state(State.TURN_BACK)

		State.TURN_BACK:
			heading = heading.rotated(Vector3.UP, _away_sign() * turn_rate * delta).normalized()
			ai_velocity = _cruise_velocity(ideal_y)
			if heading.z > 0.95:
				_set_state(State.STRAFE)

		State.STRAFE:
			_pick_nearest_wagon()
			_steer_to_point(Vector3(side_x, 0, global_position.z + line_lookahead), delta)
			ai_velocity = _cruise_velocity(ideal_y)
			if global_position.z > z_range.y + overshoot_tail:
				_set_state(State.TURN_FORWARD)

		State.TURN_FORWARD:
			heading = heading.rotated(Vector3.UP, -_away_sign() * turn_rate * delta).normalized()
			ai_velocity = _cruise_velocity(ideal_y)
			if heading.z < -0.95:
				if train_speed >= stopped_speed_threshold:
					_set_state(State.FOLLOW)
				else:
					_set_state(State.PASS)

	ai_velocity += _separation()
	velocity = ai_velocity + knockback_velocity
	move_and_slide()

	if knockback_velocity.length() > 0.01:
		knockback_velocity = knockback_velocity.move_toward(Vector3.ZERO, knockback_friction * delta)
	else:
		knockback_velocity = Vector3.ZERO

	look_at(global_position + heading, Vector3.UP, true)

	_update_shooting()

func _set_state(new_state: State) -> void:
	state = new_state
	stopped_timer = 0.0
	if state == State.FOLLOW:
		_pick_new_wagon()

func _away_sign() -> float:
	return 1.0 if side_distance < 0.0 else -1.0

func _cruise_velocity(ideal_y: float) -> Vector3:
	var v := heading * cruise_speed
	v.y = (ideal_y - global_position.y) * smooth_speed
	return v

func _steer_to_point(point: Vector3, delta: float) -> void:
	var desired := point - global_position
	desired.y = 0.0
	if desired.length_squared() < 0.001:
		return
	_steer_to_dir(desired.normalized(), delta)

func _steer_to_dir(desired: Vector3, delta: float) -> void:
	var angle := heading.signed_angle_to(desired, Vector3.UP)
	var step: float = clamp(angle, -turn_rate * delta, turn_rate * delta)
	heading = heading.rotated(Vector3.UP, step).normalized()

func _get_train() -> Node3D:
	if is_instance_valid(train_ref):
		return train_ref
	var players := get_tree().get_nodes_in_group("player_base")
	if not players.is_empty():
		train_ref = players[0]
	return train_ref

func _train_z_range(train: Node3D) -> Vector2:
	var head_z: float = train.global_position.z
	var tail_z: float = head_z
	if "wagons" in train:
		for w in train.wagons:
			if is_instance_valid(w):
				tail_z = max(tail_z, w.global_position.z)
	return Vector2(head_z, tail_z)

func _pick_new_wagon() -> void:
	var wagons = get_tree().get_nodes_in_group("wagons")
	wagons = wagons.filter(func(w): return is_instance_valid(w) and not w.is_queued_for_deletion())

	if wagons.is_empty():
		var players = get_tree().get_nodes_in_group("player_base")
		if not players.is_empty():
			target = players[0]
	else:
		var taken: Array = []
		for j in get_tree().get_nodes_in_group("flying"):
			if j != self and is_instance_valid(j) and "target" in j:
				taken.append(j.target)
		var free = wagons.filter(func(w): return not taken.has(w))
		target = (free if not free.is_empty() else wagons).pick_random()

	switch_timer = randf_range(switch_time_min, switch_time_max)

func _pick_nearest_wagon() -> void:
	var best: Node3D = null
	var best_d: float = INF
	for w in get_tree().get_nodes_in_group("wagons"):
		if not is_instance_valid(w) or w.is_queued_for_deletion():
			continue
		var d := global_position.distance_squared_to(w.global_position)
		if d < best_d:
			best_d = d
			best = w
	if best:
		target = best

func _update_shooting() -> void:
	var can_shoot: bool = state in [State.FOLLOW, State.PASS, State.STRAFE] \
		and is_instance_valid(target) \
		and global_position.distance_to(target.global_position) <= fire_range

	if can_shoot and not is_attacking:
		is_attacking = true
		attack_timer.start()
	elif not can_shoot and is_attacking:
		is_attacking = false
		attack_timer.stop()

func _separation() -> Vector3:
	var push := Vector3.ZERO
	for other in get_tree().get_nodes_in_group("flying"):
		if other == self or not is_instance_valid(other) or not other is Node3D:
			continue
		var offset: Vector3 = global_position - other.global_position
		offset.y = 0.0
		var d := offset.length()
		if d < separation_radius:
			if d < 0.01:
				offset = Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0))
				d = 0.01
			push += offset.normalized() * (1.0 - d / separation_radius)
	return push * separation_strength

func _on_attack_timer_timeout() -> void:
	for i in range(burst_count):
		if not is_instance_valid(target) or not is_inside_tree():
			break
		shoot_at_target()
		await get_tree().create_timer(fire_rate).timeout

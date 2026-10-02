class_name FighterJet
extends RangedEnemy

@export_category("Voo e Posicionamento")
@export var side_distance: float = 6.0
@export var height_offset: float = 1.5
@export var smooth_speed: float = 5.0

@export_category("Rajada de Tiros")
@export var burst_count: int = 3
@export var fire_rate: float = 0.2

@export_category("Troca de Alvo")
@export var switch_time_min: float = 3.0
@export var switch_time_max: float = 6.0

var switch_timer: float = 0.0
var is_on_left_side: bool = true

func _ready() -> void:
	super._ready()
	
	is_on_left_side = global_position.x < 0
	side_distance = -abs(side_distance) if is_on_left_side else abs(side_distance)
	
	_pick_new_wagon()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		_pick_new_wagon()
		return

	switch_timer -= delta
	if switch_timer <= 0:
		_pick_new_wagon()

	var ideal_pos = target.global_position
	ideal_pos.x += side_distance
	ideal_pos.y += height_offset

	var ai_velocity = (ideal_pos - global_position) * smooth_speed
	velocity = ai_velocity + knockback_velocity
	move_and_slide()

	if knockback_velocity.length() > 0.01:
		knockback_velocity = knockback_velocity.move_toward(Vector3.ZERO, knockback_friction * delta)
	else:
		knockback_velocity = Vector3.ZERO

	look_at(target.global_position, Vector3.UP, true)
	
	if not is_attacking:
		is_attacking = true
		attack_timer.start()

func _pick_new_wagon() -> void:
	var wagons = get_tree().get_nodes_in_group("wagons")
	wagons = wagons.filter(func(w): return is_instance_valid(w) and not w.is_queued_for_deletion())
	
	if wagons.is_empty():
		var players = get_tree().get_nodes_in_group("player_base")
		if not players.is_empty():
			target = players[0]
	else:
		target = wagons.pick_random()
	
	switch_timer = randf_range(switch_time_min, switch_time_max)

func _on_attack_timer_timeout() -> void:
	for i in range(burst_count):
		if not is_instance_valid(target):
			break
			
		shoot_at_target()
		
		await get_tree().create_timer(fire_rate).timeout

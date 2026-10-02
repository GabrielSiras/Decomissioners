class_name AAA
extends RangedEnemy

@export_category("Muzzles Duplos")
@onready var muzzle_2: Marker3D = $Muzzle2


@export_category("Configurações de Artilharia")
@export var scan_interval: float = 0.5
@export var alternate_fire: bool = false

var scan_timer: float = 0.0
var fire_left_next: bool = true

func _ready() -> void:
	super._ready()
	if attack_range < 25.0:
		attack_range = 30.0

func _physics_process(delta: float) -> void:
	scan_timer -= delta
	if scan_timer <= 0:
		scan_timer = scan_interval
		target = _get_closest_target()
		
	if not is_instance_valid(target):
		if is_attacking:
			is_attacking = false
			attack_timer.stop()
		return
		
	var distance_to_target = global_position.distance_to(target.global_position)
	
	if distance_to_target <= attack_range:
		var look_pos = target.global_position
		look_pos.y = global_position.y
		
		look_at(look_pos, Vector3.UP)
		
		if not is_attacking:
			is_attacking = true
			attack_timer.start()
	else:
		if is_attacking:
			is_attacking = false
			attack_timer.stop()


func shoot_at_target() -> void:
	if not enemy_projectile_scene or not is_instance_valid(target):
		return

	if alternate_fire:
		if fire_left_next:
			_spawn_projectile_at(muzzle)
		else:
			_spawn_projectile_at(muzzle_2)
		fire_left_next = !fire_left_next
	else:
		_spawn_projectile_at(muzzle)
		_spawn_projectile_at(muzzle_2)

func _spawn_projectile_at(spawn_muzzle: Marker3D) -> void:
	var projectile = enemy_projectile_scene.instantiate()
	get_parent().add_child(projectile)
	
	if is_instance_valid(spawn_muzzle):
		projectile.global_position = spawn_muzzle.global_position
	else:
		projectile.global_position = global_position
	
	if projectile.has_method("setup"):
		projectile.setup(target, ranged_damage)

func _get_closest_target() -> Node3D:
	var possible_targets = get_tree().get_nodes_in_group("player_targets")
	var closest_node: Node3D = null
	var shortest_dist: float = INF
	
	for t in possible_targets:
		if is_instance_valid(t) and not t.is_queued_for_deletion():
			var dist = global_position.distance_squared_to(t.global_position)
			if dist < shortest_dist:
				shortest_dist = dist
				closest_node = t
				
	return closest_node

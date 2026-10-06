class_name TurretBase
extends Node3D

@export var fire_rate: float = 0.5
@export var damage: int = 10
@export var build_cost: int = 50
@export var projectile_scene: PackedScene

@export_category("Efeitos de Sobrecarga")
@export var turret_mesh: MeshInstance3D
@export var overcharge_vfx_scene: PackedScene

@onready var range_area: Area3D = $RangeArea
@onready var muzzle: Marker3D = $Muzzle
@onready var shoot_timer: Timer = $ShootTimer

var current_target: Node3D = null
var enemies_in_range: Array[Node3D] = []

var active_vfx_instance: Node3D = null

var is_supercharged: bool = false
var base_damage: int = 10
var base_fire_rate: float = 0.5
var supercharge_timer: Timer

func _ready() -> void:
	range_area.body_entered.connect(_on_range_area_body_entered)
	range_area.body_exited.connect(_on_range_area_body_exited)
	
	base_damage = damage
	base_fire_rate = fire_rate
	shoot_timer.wait_time = fire_rate
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)

	supercharge_timer = Timer.new()
	supercharge_timer.one_shot = true
	supercharge_timer.timeout.connect(_on_supercharge_ended)
	add_child(supercharge_timer)

func _process(_delta: float) -> void:
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))
	
	current_target = get_closest_enemy()
	
	if current_target:
		var target_pos = current_target.global_position
		target_pos.y = global_position.y
		look_at(target_pos, Vector3.UP)
		
		if shoot_timer.is_stopped():
			shoot()
			shoot_timer.start()
	else:
		shoot_timer.stop()

func get_closest_enemy() -> Node3D:
	var closest: Node3D = null
	var min_distance: float = INF
	
	for enemy in enemies_in_range:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < min_distance:
			min_distance = dist
			closest = enemy
			
	return closest

func _on_shoot_timer_timeout() -> void:
	if is_instance_valid(current_target):
		shoot()

func shoot() -> void:
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		get_parent().add_child(projectile)
		projectile.global_position = muzzle.global_position
		
		if projectile.has_method("setup"):
			projectile.setup(current_target, damage)

func _on_range_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemies"):
		enemies_in_range.append(body)

func _on_range_area_body_exited(body: Node3D) -> void:
	if body in enemies_in_range:
		enemies_in_range.erase(body)

func apply_supercharge(damage_mult: float, speed_mult: float, duration: float) -> void:
	if not is_supercharged:
		base_damage = damage
		base_fire_rate = fire_rate
		is_supercharged = true

	damage = int(base_damage * damage_mult)
	var new_wait_time: float = max(0.05, base_fire_rate / speed_mult)
	shoot_timer.wait_time = new_wait_time

	if is_instance_valid(active_vfx_instance):
		active_vfx_instance.queue_free()

	if is_instance_valid(overcharge_vfx_scene):
		active_vfx_instance = overcharge_vfx_scene.instantiate() as Node3D
		add_child(active_vfx_instance)
		active_vfx_instance.position = Vector3.ZERO

	_set_incandescent_vfx(true)
	supercharge_timer.start(duration)

func _on_supercharge_ended() -> void:
	if not is_supercharged:
		return

	is_supercharged = false
	damage = base_damage
	fire_rate = base_fire_rate
	shoot_timer.wait_time = base_fire_rate

	_set_incandescent_vfx(false)

	if is_instance_valid(active_vfx_instance):
		active_vfx_instance.queue_free()
		active_vfx_instance = null

func _set_incandescent_vfx(active: bool) -> void:
	if not is_instance_valid(turret_mesh):
		return

	var base_mat = turret_mesh.get_active_material(0)
	if not is_instance_valid(base_mat):
		return

	if base_mat is StandardMaterial3D:
		var mat = base_mat.duplicate() as StandardMaterial3D
		mat.emission_enabled = active
		
		if active:
			mat.emission = Color(1.0, 0.45, 0.0)
			mat.emission_energy_multiplier = 5.0
		
		turret_mesh.material_override = mat

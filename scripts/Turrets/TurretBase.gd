class_name TurretBase
extends Node3D

@export var fire_rate: float = 0.5
@export var damage: int = 2
@export var projectile_scene: PackedScene

@onready var range_area: Area3D = $RangeArea
@onready var muzzle: Marker3D = $Muzzle
@onready var shoot_timer: Timer = $ShootTimer

var current_target: Node3D = null
var enemies_in_range: Array[Node3D] = []

func _ready() -> void:
	range_area.body_entered.connect(_on_range_area_body_entered)
	range_area.body_exited.connect(_on_range_area_body_exited)
	
	shoot_timer.wait_time = fire_rate
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)

func _process(_delta: float) -> void:
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))
	
	current_target = get_closest_enemy()
	
	if current_target:
		var target_pos = current_target.global_position
		target_pos.y = global_position.y
		look_at(target_pos, Vector3.UP)
		
		if shoot_timer.is_stopped():
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

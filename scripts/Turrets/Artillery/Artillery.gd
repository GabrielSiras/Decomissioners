class_name ArtilleryTurret
extends TurretBase

@export_category("Configurações de Nível")
@export_range(1, 3) var current_level: int = 1

##Lvl 1, Lvl 2, Lvl 3
var level_data: Dictionary = {
	1: {"damage": 25, "cooldown": 5.0, "armor_penetration": 0.40},
	2: {"damage": 35, "cooldown": 4.0, "armor_penetration": 0.60},
	3: {"damage": 50, "cooldown": 3.0, "armor_penetration": 0.80}
}

@export_category("Configurações da Artilharia")
@export var aoe_radius: float = 5.0
@export var shell_scene: PackedScene
@export var flying_group_name: String = "flying"

var current_armor_penetration: float = 0.40
var target: Node3D = null

func _ready() -> void:
	super._ready()
	apply_level_stats(current_level)
	
	if has_node("Model3D"):
		$Model3D.rotate_y(PI)

func _process(delta: float) -> void:
	target = _get_best_target()

	if is_instance_valid(target):
		super._process(delta)

func apply_level_stats(level: int) -> void:
	current_level = clamp(level, 1, 3)
	var stats = level_data[current_level]
	
	damage = stats["damage"]
	
	fire_rate = stats["cooldown"]
	base_fire_rate = fire_rate
	base_damage = damage
	current_armor_penetration = stats["armor_penetration"]
	
	if is_instance_valid(shoot_timer):
		shoot_timer.wait_time = fire_rate

func upgrade_turret() -> void:
	if current_level < 3:
		apply_level_stats(current_level + 1)

func _get_best_target() -> Node3D:
	var valid_ground_targets: Array[Node3D] = []
	
	for enemy in enemies_in_range:
		if not is_instance_valid(enemy):
			continue
			
		if enemy.is_in_group("flying"):
			continue
			
		if "is_flying" in enemy and enemy.is_flying:
			continue
			
		valid_ground_targets.append(enemy)
		
	if valid_ground_targets.is_empty():
		return null
		
	return valid_ground_targets[0]
	
func shoot() -> void:
	var target_enemy = _get_best_target()
	if not target_enemy:
		return

	var target_position = target_enemy.global_position
	target_position.y = 0.0

	_spawn_artillery_shell(target_position)

func _spawn_artillery_shell(target_pos: Vector3) -> void:
	if not shell_scene:
		return

	var spawn_pos = global_position
	if is_instance_valid(muzzle):
		spawn_pos = muzzle.global_position

	var shell = shell_scene.instantiate()
	get_tree().current_scene.add_child(shell)

	if shell.has_method("setup_artillery"):
		shell.setup_artillery(spawn_pos, target_pos, damage, aoe_radius, current_armor_penetration)

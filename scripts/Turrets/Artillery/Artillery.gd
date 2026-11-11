class_name ArtilleryTurret
extends TurretBase

@export_category("Configurações da Artilharia")
@export var aoe_radius: float = 2.5
@export var shell_scene: PackedScene

@export_category("Dados por Nível (índice 0 = T1)")
@export var aoe_radius_per_level: Array[float] = [2.5, 3.0, 3.5]

var target: Node3D = null

func _ready() -> void:
	super._ready()

	if has_node("Model3D"):
		$Model3D.rotate_y(PI)

func set_level(lvl: int) -> void:
	super.set_level(lvl)
	var i: int = turret_level - 1
	aoe_radius = aoe_radius_per_level[mini(i, aoe_radius_per_level.size() - 1)]

func _process(delta: float) -> void:
	target = _get_best_target()
	if is_instance_valid(target):
		super._process(delta)
	else:
		shoot_timer.stop()

func _get_best_target() -> Node3D:
	for enemy in enemies_in_range:
		if not is_instance_valid(enemy):
			continue
		if enemy.is_in_group("flying"):
			continue
		if "is_flying" in enemy and enemy.is_flying:
			continue
		return enemy
	return null

func shoot() -> void:
	var target_enemy: Node3D = _get_best_target()
	if not target_enemy:
		return

	var target_position: Vector3 = target_enemy.global_position
	target_position.y = 0.0
	_spawn_artillery_shell(target_position)

func _spawn_artillery_shell(target_pos: Vector3) -> void:
	if not shell_scene:
		return

	var spawn_pos: Vector3 = muzzle.global_position if is_instance_valid(muzzle) else global_position

	var shell = shell_scene.instantiate()
	get_tree().current_scene.add_child(shell)

	if shell.has_method("setup_artillery"):
		shell.setup_artillery(spawn_pos, target_pos, damage, aoe_radius, penetration)

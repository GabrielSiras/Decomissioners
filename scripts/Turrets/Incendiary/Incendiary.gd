class_name Incendiary
extends TurretBase

@export_category("Configs do Incendiary")
@export var cone_angle_degrees: float = 60.0
@export var flame_vfx: Node3D

@export_category("Debuff de Armadura")
@export var debuff_duration: float = 2.0

@export_category("Dados por Nível (índice 0 = T1)")
@export var cone_angle_per_level: Array[float] = [60.0, 70.0, 80.0]
@export var debuff_duration_per_level: Array[float] = [2.0, 2.5, 3.0]

var is_firing: bool = false

func _ready() -> void:
	super._ready()

	if has_node("Model3D"):
		$Model3D.rotate_y(PI)

	if is_instance_valid(flame_vfx):
		_set_flame_vfx_active(false)

func set_level(lvl: int) -> void:
	super.set_level(lvl)
	var i: int = turret_level - 1
	cone_angle_degrees = cone_angle_per_level[mini(i, cone_angle_per_level.size() - 1)]
	debuff_duration = debuff_duration_per_level[mini(i, debuff_duration_per_level.size() - 1)]

func _process(delta: float) -> void:
	super._process(delta)

	if current_target and not is_firing:
		is_firing = true
		_set_flame_vfx_active(true)
	elif not current_target and is_firing:
		is_firing = false
		_set_flame_vfx_active(false)

func shoot() -> void:
	var forward_dir: Vector3 = -global_transform.basis.z
	forward_dir.y = 0.0
	forward_dir = forward_dir.normalized()

	var half_cone: float = cone_angle_degrees / 2.0
	var zones: Array = get_tree().get_nodes_in_group("pitch_puddles")

	for enemy in enemies_in_range:
		if not is_instance_valid(enemy):
			continue

		var dir_to_enemy: Vector3 = enemy.global_position - global_position
		dir_to_enemy.y = 0.0
		if dir_to_enemy.is_zero_approx():
			continue

		var angle_deg: float = rad_to_deg(forward_dir.angle_to(dir_to_enemy.normalized()))
		if angle_deg > half_cone:
			continue

		if enemy.has_method("take_damage"):
			enemy.take_damage(damage)
		if enemy.has_method("apply_armor_debuff"):
			enemy.apply_armor_debuff(debuff_duration)

		for z in zones:
			if z is PitchZone and z.active and z.inside.has(enemy):
				z.ignite()

func _set_flame_vfx_active(active: bool) -> void:
	if not is_instance_valid(flame_vfx):
		return

	flame_vfx.visible = active

	var particles: Array = flame_vfx.find_children("*", "GPUParticles3D", true, false) \
		+ flame_vfx.find_children("*", "CPUParticles3D", true, false)
	for p in particles:
		p.emitting = active

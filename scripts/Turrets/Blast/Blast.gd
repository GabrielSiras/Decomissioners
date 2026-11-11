class_name Blast
extends TurretBase

@export_category("Configurações de Repulsão")
@export var push_force: float = 25.0
@export var arc_angle_degrees: float = 180.0
@export var push_straight_forward: bool = true
@export var blast_vfx_scene: PackedScene

@export_category("Atordoamento (valores atuais, definidos pelo nível)")
@export_range(0.0, 1.0) var stun_chance: float = 0.3
@export var stun_duration: float = 1.0

@export_category("Dados por Nível (índice 0 = T1)")
@export var stun_chance_per_level: Array[float] = [0.30, 0.40, 0.50]
@export var stun_duration_per_level: Array[float] = [1.0, 1.5, 2.0]
@export var push_force_per_level: Array[float] = [10.0, 14.0, 18.0]

func _ready() -> void:
	super._ready()

	if has_node("Model3D"):
		$Model3D.rotate_y(PI)

func set_level(lvl: int) -> void:
	super.set_level(lvl)
	var i: int = turret_level - 1
	stun_chance = stun_chance_per_level[mini(i, stun_chance_per_level.size() - 1)]
	stun_duration = stun_duration_per_level[mini(i, stun_duration_per_level.size() - 1)]
	push_force = push_force_per_level[mini(i, push_force_per_level.size() - 1)]

func shoot() -> void:
	var forward_dir: Vector3 = -global_transform.basis.z
	if is_instance_valid(muzzle):
		forward_dir = -muzzle.global_transform.basis.z

	forward_dir.y = 0.0
	forward_dir = forward_dir.normalized()

	_play_blast_vfx()

	for enemy in enemies_in_range:
		if not is_instance_valid(enemy):
			continue

		var target_node: Node3D = enemy
		while is_instance_valid(target_node) and not target_node.has_method("apply_knockback") and target_node != get_tree().current_scene:
			target_node = target_node.get_parent()

		if not is_instance_valid(target_node) or target_node == get_tree().current_scene:
			continue

		var diff: Vector3 = target_node.global_position - global_position
		diff.y = 0.0
		var distance: float = diff.length()
		var dir_to_enemy: Vector3 = diff.normalized() if distance > 0.001 else forward_dir

		var angle_deg: float = rad_to_deg(forward_dir.angle_to(dir_to_enemy))
		if angle_deg > arc_angle_degrees / 2.0:
			continue

		var final_push_dir: Vector3 = forward_dir if push_straight_forward else dir_to_enemy
		target_node.apply_knockback(final_push_dir * push_force)

		if randf() <= stun_chance and target_node.has_method("apply_stun"):
			target_node.apply_stun(stun_duration)

		if damage > 0:
			if target_node.has_method("take_damage_with_pen"):
				target_node.take_damage_with_pen(damage, penetration)
			elif target_node.has_method("take_damage"):
				target_node.take_damage(damage)

func _play_blast_vfx() -> void:
	if blast_vfx_scene:
		var vfx = blast_vfx_scene.instantiate()
		get_parent().add_child(vfx)
		vfx.global_transform = muzzle.global_transform if is_instance_valid(muzzle) else global_transform

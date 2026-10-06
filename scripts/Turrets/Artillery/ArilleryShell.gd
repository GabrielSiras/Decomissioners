class_name ArtilleryShell
extends PlayerProjectile

@export_category("Artilharia AoE")
@export var aoe_radius: float = 5.0
@export var arc_height: float = 8.0
@export var explosion_vfx_scene: PackedScene

var armor_penetration: float = 0.40
var start_pos: Vector3
var target_pos: Vector3
var travel_time: float = 1.2
var elapsed_time: float = 0.0
var is_artillery_active: bool = false

func setup_artillery(p_start: Vector3, p_target_pos: Vector3, p_damage: int, p_aoe: float, p_armor_pen: float, p_travel_time: float = 1.2) -> void:
	start_pos = p_start
	target_pos = p_target_pos
	damage_amount = p_damage
	aoe_radius = p_aoe
	armor_penetration = p_armor_pen
	travel_time = p_travel_time
	
	global_position = start_pos
	is_artillery_active = true

func _physics_process(delta: float) -> void:
	if not is_artillery_active:
		return

	elapsed_time += delta
	var progress = clamp(elapsed_time / travel_time, 0.0, 1.0)

	var current_pos = start_pos.lerp(target_pos, progress)

	var height_offset = sin(progress * PI) * arc_height
	current_pos.y += height_offset

	global_position = current_pos

	if progress >= 1.0:
		_explode()

func _on_body_entered(body: Node3D) -> void:
	if is_artillery_active:
		if body.is_in_group("player_base") or body.is_in_group("train"):
			return
		_explode()

func _explode() -> void:
	if not is_artillery_active:
		return
	is_artillery_active = false
	
	if explosion_vfx_scene:
		var vfx = explosion_vfx_scene.instantiate()
		get_tree().current_scene.add_child(vfx)
		vfx.global_position = global_position

	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if not is_instance_valid(enemy) or not (enemy is Node3D):
			continue

		if enemy.is_in_group("flying") or ("is_flying" in enemy and enemy.is_flying):
			continue

		var dist = global_position.distance_to(enemy.global_position)
		if dist <= aoe_radius:
			_apply_artillery_damage(enemy)

	queue_free()

func _apply_artillery_damage(enemy_node: Node3D) -> void:
	if enemy_node.has_method("take_damage_with_pen"):
		enemy_node.take_damage_with_pen(damage_amount, armor_penetration)
	elif enemy_node.has_method("take_damage"):
		if "current_armor" in enemy_node:
			var effective_armor = enemy_node.current_armor * (1.0 - armor_penetration)
			var armor_reduction = clamp(effective_armor, 0.0, 100.0) / 100.0
			var final_damage = max(1, roundi(damage_amount * (1.0 - armor_reduction)))
			enemy_node.take_damage(final_damage)
		else:
			enemy_node.take_damage(damage_amount)

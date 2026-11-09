class_name Incendiary
extends TurretBase

@export_category("Configs do Incendiary")
@export var cone_angle_degrees: float = 60.0 
@export var flame_vfx: Node3D 

@export_category("Debuff de Armadura")
@export var debuff_duration: float = 2.0 # nível1

var is_firing: bool = false

##Lvl 1, Lvl 2, Lvl 3
var level_data: Dictionary = {
	1: {"damage": 25, "debuff_strength": 0.30, "spread_area": 2.0},
	2: {"damage": 35, "debuff_strength": 0.40, "spread_area": 3.0},
	3: {"damage": 50, "debuff_strength": 0.50, "spread_area": 4.0}
}

func _ready() -> void:
	super._ready()
	#apply_level_stats(current_level)
	
	if has_node("Model3D"):
		$Model3D.rotate_y(PI)
	
	if is_instance_valid(flame_vfx):
		_set_flame_vfx_active(false)

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
	
	for enemy in enemies_in_range:
		if not is_instance_valid(enemy):
			continue
			
		var dir_to_enemy: Vector3 = (enemy.global_position - global_position).normalized()
		dir_to_enemy.y = 0.0
		
		var angle_rad: float = forward_dir.angle_to(dir_to_enemy)
		var angle_deg: float = rad_to_deg(angle_rad)
		
		if angle_deg <= (cone_angle_degrees / 2.0):
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage)
			if enemy.has_method("apply_armor_debuff"):
				enemy.apply_armor_debuff(debuff_duration)

func _set_flame_vfx_active(active: bool) -> void:
	if not is_instance_valid(flame_vfx):
		return
		
	flame_vfx.visible = active
	
	var particles = flame_vfx.find_children("*", "GPUParticles3D") + flame_vfx.find_children("*", "CPUParticles3D")
	for p in particles:
		p.emitting = active

func _on_impact(target_area: Node3D) -> void:
	if target_area is PitchPuddle:
		target_area.ignite()
	elif target_area.has_method("ignite"):
		target_area.ignite()

	var space_state = get_world_3d().direct_space_state

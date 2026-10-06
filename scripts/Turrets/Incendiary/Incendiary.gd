class_name Incendiary
extends TurretBase

@export_category("Configs do Incendiary")
@export var cone_angle_degrees: float = 60.0 
@export var flame_vfx: Node3D 

@export_category("Debuff de Armadura")
@export var debuff_duration: float = 2.0 # nível1

var is_firing: bool = false

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

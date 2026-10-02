class_name EmpSkillButton
extends SkillBase

@export var emp_pulse_scene: PackedScene 

func _use_skill() -> bool:
	if not is_instance_valid(train) or emp_pulse_scene == null:
		return false
		print("Não adicionado no editor o train ou o emp_pulse_scene")
	
	var pulse = emp_pulse_scene.instantiate()
	get_tree().current_scene.add_child(pulse)
	pulse.global_position = train.global_position
	
	print("⚡ EMP ativado via cena separada!")
	return true

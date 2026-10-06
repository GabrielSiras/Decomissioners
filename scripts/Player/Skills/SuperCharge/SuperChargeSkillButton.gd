class_name SuperChargeSkillButton
extends SkillBase

@export var supercharge_skill_scene: PackedScene

var supercharge_skill: SuperchargeSkill

func _ready() -> void:
	super._ready()
	
	if supercharge_skill_scene:
		supercharge_skill = supercharge_skill_scene.instantiate() as SuperchargeSkill
		add_child(supercharge_skill)
		
		cooldown_time = supercharge_skill.cooldown
		cooldown_timer.wait_time = cooldown_time
		
		if supercharge_skill.has_signal("skill_executed"):
			supercharge_skill.skill_executed.connect(_on_skill_executed)

func _use_skill() -> bool:
	if not is_instance_valid(supercharge_skill):
		print("⚠️ Referência para SuperchargeSkill não encontrada!")
		return false
	
	supercharge_skill.activate_skill_targeting()
	return false

func _on_skill_executed() -> void:
	_start_cooldown()

class_name RepairSkillButton
extends SkillBase

@export var repair_skill_scene: PackedScene
var repair_skill: RepairSkill

func _ready() -> void:
	super._ready()
	repair_skill = repair_skill_scene.instantiate() as RepairSkill
	add_child(repair_skill)
	cooldown_time = repair_skill.get_cooldown()
	cooldown_timer.wait_time = cooldown_time
	repair_skill.skill_executed.connect(_start_cooldown)

func _use_skill() -> bool:
	repair_skill.activate_skill_targeting()
	return false

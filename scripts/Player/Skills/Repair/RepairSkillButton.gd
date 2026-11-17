class_name RepairSkillButton
extends SkillBase

@export var repair_skill_scene: PackedScene
var repair_skill: RepairSkill
var original_button_text: String = ""

func _ready() -> void:
	super._ready()
	original_button_text = text
	repair_skill = repair_skill_scene.instantiate() as RepairSkill
	add_child(repair_skill)
	cooldown_time = repair_skill.get_cooldown()
	cooldown_timer.wait_time = cooldown_time
	cooldown_timer.one_shot = true
	repair_skill.skill_executed.connect(_on_skill_executed)

func _process(_delta: float) -> void:
	if not cooldown_timer.is_stopped():
		text = "%.1fs" % cooldown_timer.time_left

func _use_skill() -> bool:
	repair_skill.activate_skill_targeting()
	return false

func _on_skill_executed() -> void:
	disabled = true
	cooldown_timer.start(repair_skill.get_cooldown())

func _on_cooldown_finished() -> void:
	disabled = false
	text = original_button_text

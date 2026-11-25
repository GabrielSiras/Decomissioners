class_name SuperChargeSkillButton
extends SkillBase

@export var supercharge_skill_scene: PackedScene

var supercharge_skill: SuperchargeSkill
var original_button_text: String = ""
func _ready() -> void:
	super._ready()
	cooldown_timer.one_shot = true
	original_button_text = text
	if supercharge_skill_scene:
		supercharge_skill = supercharge_skill_scene.instantiate() as SuperchargeSkill
		add_child(supercharge_skill)
		
		cooldown_time = supercharge_skill.cooldown
		cooldown_timer.wait_time = cooldown_time
		
		if supercharge_skill.has_signal("skill_executed"):
			supercharge_skill.skill_executed.connect(_on_skill_executed)

func _process(_delta: float) -> void:
	if not cooldown_timer.is_stopped():
		text = "%.1fs" % cooldown_timer.time_left

func _use_skill() -> bool:
	if not is_instance_valid(supercharge_skill):
		print("⚠️ Referência para SuperchargeSkill não encontrada!")
		return false
	
	supercharge_skill.activate_skill_targeting()
	return false

func _on_skill_executed() -> void:
	_start_cooldown()

func _on_cooldown_finished() -> void:
	is_on_cooldown = false
	disabled = false
	text = original_button_text

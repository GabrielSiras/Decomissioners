class_name BlackPitchSkillButton
extends SkillBase

@export_category("Instância da Habilidade")
@export var pitch_skill_node: PitchSkill
@export var cooldown_duration: float = 10.0

var original_button_text: String = ""

func _ready() -> void:
	super._ready()
	
	original_button_text = text if text != "" else "BlackPitch"
	
	if not is_instance_valid(cooldown_timer):
		cooldown_timer = Timer.new()
		cooldown_timer.one_shot = true
		add_child(cooldown_timer)
	
	if not cooldown_timer.timeout.is_connected(_on_cooldown_finished):
		cooldown_timer.timeout.connect(_on_cooldown_finished)

func _process(_delta: float) -> void:
	if is_on_cooldown and is_instance_valid(cooldown_timer):
		text = "%.1fs" % cooldown_timer.time_left

func _on_pressed() -> void:
	if is_on_cooldown:
		print("⚠️ Habilidade em cooldown!")
		return

	var train_head = get_tree().get_first_node_in_group("train_head")
	if not is_instance_valid(train_head):
		train_head = get_tree().get_first_node_in_group("player_base")

	if not is_instance_valid(train_head):
		print("❌ Locomotiva (TrainHead) não encontrada na cena!")
		return

	if is_instance_valid(pitch_skill_node):
		pitch_skill_node.execute_skill(train_head)
		_start_cooldown()
	else:
		print("❌ O nó 'PitchSkill' não foi atribuído no botão!")

func _start_cooldown() -> void:
	is_on_cooldown = true
	disabled = true
	cooldown_timer.start(cooldown_duration)

func _on_cooldown_finished() -> void:
	is_on_cooldown = false
	disabled = false
	text = original_button_text

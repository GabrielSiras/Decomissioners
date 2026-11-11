class_name BombardmentSkillButton
extends SkillBase

@export var bombardment_scene: PackedScene
@onready var skill_sound: AudioStreamPlayer = $SkillSound

var active_bombardment: Bombardment = null
var original_button_text: String = ""

func _ready() -> void:
	super._ready()
	original_button_text = text if text != "" else "Bombardment"
	cooldown_timer.wait_time = cooldown_time
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_finished)
	pressed.connect(_on_pressed)

func _process(_delta: float) -> void:
	if not cooldown_timer.is_stopped():
		text = "%.1fs" % cooldown_timer.time_left

func _on_pressed() -> void:
	if not cooldown_timer.is_stopped() or active_bombardment != null:
		return

	if bombardment_scene:
		active_bombardment = bombardment_scene.instantiate() as Bombardment
		active_bombardment.executed.connect(_on_skill_executed)
		active_bombardment.cancelled.connect(_on_skill_cancelled)
		get_tree().root.add_child(active_bombardment)

func _on_skill_executed() -> void:
	active_bombardment = null
	disabled = true
	cooldown_timer.start()
	skill_sound.play()

func _on_skill_cancelled() -> void:
	active_bombardment = null

func _on_cooldown_finished() -> void:
	disabled = false
	text = original_button_text

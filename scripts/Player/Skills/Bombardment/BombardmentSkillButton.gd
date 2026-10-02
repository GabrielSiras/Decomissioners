class_name BombardmentSkillButton
extends Button

@export var bombardment_scene: PackedScene
@export var cooldown_time: float = 15.0

@onready var cooldown_timer: Timer = $CooldownTimer

var active_bombardment: Bombardment = null

func _ready() -> void:
	cooldown_timer.wait_time = cooldown_time
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_finished)
	pressed.connect(_on_pressed)

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

func _on_skill_cancelled() -> void:
	active_bombardment = null

func _on_cooldown_finished() -> void:
	disabled = false

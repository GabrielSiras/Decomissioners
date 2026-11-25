class_name CheckpointIndicator
extends Control

@export var spinner: LoadingSpinner
@export var label: Label
@export var fade_time: float = 0.3
@export var reward_time: float = 2.0
@export var done_time: float = 1.2

var tween: Tween

func _ready() -> void:
	modulate.a = 0.0
	visible = false

func show_waiting() -> void:
	spinner.visible = true
	label.text = "Saving..."
	_fade_in()

func show_done_then_reward(reward_text: String = "") -> void:
	if tween and tween.is_valid():
		tween.kill()

	spinner.visible = false
	label.text = "Checkpoint saved"
	visible = true
	modulate.a = 0.0

	tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_time)
	tween.tween_interval(done_time)

	if reward_text != "":
		tween.tween_property(self, "modulate:a", 0.0, fade_time)
		tween.tween_callback(func(): label.text = reward_text)
		tween.tween_property(self, "modulate:a", 1.0, fade_time)
		tween.tween_interval(reward_time)

	tween.tween_property(self, "modulate:a", 0.0, fade_time)
	tween.tween_callback(func(): visible = false)

func _fade_in() -> void:
	if tween and tween.is_valid():
		tween.kill()
	visible = true
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_time)

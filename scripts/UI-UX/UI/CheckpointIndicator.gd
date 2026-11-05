class_name CheckpointIndicator
extends Control

@export var spinner: LoadingSpinner
@export var label: Label
@export var fade_time: float = 0.3

var tween: Tween

func _ready() -> void:
	modulate.a = 0.0
	visible = false

func show_waiting() -> void:
	spinner.visible = true
	label.text = "Checkpoint..."
	_fade_in()

func show_done() -> void:
	spinner.visible = false
	label.text = "Checkpoint saved"
	_fade_in()
	tween = create_tween()
	tween.tween_interval(1.2)
	tween.tween_property(self, "modulate:a", 0.0, fade_time)
	tween.tween_callback(func(): visible = false)

func _fade_in() -> void:
	if tween and tween.is_valid():
		tween.kill()
	visible = true
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_time)

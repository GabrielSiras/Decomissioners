class_name PreGameController
extends Node

signal game_started

@export var train: TrainHead
@export var spawner: EnemySpawner
@export var speed_lever: SpeedLever
@export var start_button: Button
@export var click_sound: AudioStreamPlayer
@export var initial_speed_factor: float = 0.2
@export var skip_if_checkpoint: bool = true
@export var fade_time: float = 0.3

var started: bool = false
var pulse_tween: Tween

func _ready() -> void:
	await get_tree().process_frame

	if skip_if_checkpoint and CheckpointManager.has_checkpoint(train.level_id):
		_begin(false)
		return

	train.pregame = true
	spawner.stop_spawning()
	speed_lever.visible = false
	_set_skills_locked(true)

	start_button.visible = true
	_start_pulse()
	start_button.pressed.connect(_on_start_pressed)

func _on_start_pressed() -> void:
	if started:
		return
	started = true
	start_button.disabled = true
	if is_instance_valid(click_sound):
		click_sound.pitch_scale = randf_range(0.9, 1.1)
		click_sound.play()

	var tw := create_tween()
	tw.tween_property(start_button, "modulate:a", 0.0, fade_time)
	await tw.finished
	start_button.visible = false
	_begin(true)

func _begin(from_pregame: bool) -> void:
	started = true
	start_button.visible = false
	train.pregame = false
	_set_skills_locked(false)
	speed_lever.visible = true
	speed_lever.v_slider.editable = true
	if from_pregame:
		speed_lever.v_slider.value = initial_speed_factor
	spawner.start_spawning()
	game_started.emit()

func _set_skills_locked(locked: bool) -> void:
	for b in get_tree().get_nodes_in_group("skill_buttons"):
		if b is BaseButton:
			b.disabled = locked
			b.modulate.a = 0.4 if locked else 1.0

func _start_pulse() -> void:
	start_button.pivot_offset = start_button.size * 0.5
	pulse_tween = create_tween().set_loops()
	pulse_tween.set_parallel(true)
	pulse_tween.tween_property(start_button, "scale", Vector2(1.06, 1.06), 0.9) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pulse_tween.tween_property(start_button, "modulate:a", 1.0, 0.9) \
		.from(0.8).set_trans(Tween.TRANS_SINE)
	pulse_tween.chain().tween_property(start_button, "scale", Vector2.ONE, 0.9) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pulse_tween.parallel().tween_property(start_button, "modulate:a", 0.8, 0.9) \
		.set_trans(Tween.TRANS_SINE)

func _stop_pulse() -> void:
	if pulse_tween and pulse_tween.is_valid():
		pulse_tween.kill()
	start_button.scale = Vector2.ONE

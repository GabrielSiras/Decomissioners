class_name LevelSelect
extends Control

@export_file("*.tscn") var main_menu_path: String = "res://scenes/UI-UX/UI/MENUs/MainMenu.tscn"
@export var click_delay: float = 0.55
@export var random_pitch: bool = true

@onready var click_sound: AudioStreamPlayer = $MetalClick
@onready var start_timer: Timer = $StartTimer
@onready var back_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/BackButton

@onready var level_buttons: Dictionary = {
	"tutorial": $MarginContainer/VBoxContainer/Tutorial,
	"level01": $MarginContainer/VBoxContainer/Level01,
	"level02": $MarginContainer/VBoxContainer/Level02,
	"level03": $MarginContainer/VBoxContainer/Level03,
}

var is_changing: bool = false

func _ready() -> void:
	CheckpointManager.clear()
	get_tree().paused = false
	back_button.pressed.connect(_go_to.bind(main_menu_path))

	for id in level_buttons:
		var b: Button = level_buttons[id]
		if GameProgress.is_unlocked(id):
			b.pressed.connect(_go_to.bind(GameProgress.LEVELS[id]))
		else:
			b.disabled = true

func _go_to(scene_path: String) -> void:
	if is_changing:
		return
	if scene_path.is_empty() or not ResourceLoader.exists(scene_path):
		push_warning("LevelSelect: cena não encontrada: " + scene_path)
		return

	is_changing = true
	_set_buttons_disabled(true)

	if random_pitch:
		click_sound.pitch_scale = randf_range(0.9, 1.1)
	click_sound.play()

	start_timer.one_shot = true
	start_timer.start(click_delay)
	await start_timer.timeout

	get_tree().paused = false
	get_tree().change_scene_to_file(scene_path)

func _set_buttons_disabled(value: bool) -> void:
	back_button.disabled = value
	for b in level_buttons.values():
		b.disabled = value

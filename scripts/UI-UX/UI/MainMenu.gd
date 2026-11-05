class_name MainMenu
extends Control

@export var start_button: Button
@export var credits_overlay: PackedScene
@export var click_delay: float = 0.55
@export var random_pitch: bool = true

@onready var metal_click: AudioStreamPlayer = $MetalClick
@onready var start_timer: Timer = $StartTimer

var is_changing: bool = false

func _ready() -> void:
	CheckpointManager.clear()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _play_click() -> void:
	if random_pitch:
		metal_click.pitch_scale = randf_range(0.9, 1.1)
	metal_click.play()

func _go_to(scene_path: String) -> void:
	if is_changing:
		return
	if not ResourceLoader.exists(scene_path):
		push_warning("MainMenu: cena não encontrada: " + scene_path)
		return

	is_changing = true
	_set_buttons_disabled(true)
	_play_click()

	start_timer.one_shot = true
	start_timer.start(click_delay)
	await start_timer.timeout

	get_tree().change_scene_to_file(scene_path)

func _set_buttons_disabled(value: bool) -> void:
	for b in find_children("*", "BaseButton", true, false):
		b.disabled = value

func _on_start_button_pressed() -> void:
	_go_to("res://scenes/Levels/Level01.tscn") # depois colocar a cena do tutors

func _on_research_button_pressed() -> void:
	_go_to("res://scenes/UI-UX/UI/MENUs/ResearchMenu.tscn")

func _on_railmap_button_pressed() -> void:
	_go_to("res://scenes/UI-UX/UI/MENUs/RailmapMenu.tscn")

func _on_level_select_button_pressed() -> void:
	_go_to("res://scenes/UI-UX/UI/MENUs/LevelSelect.tscn")

func _on_credits_button_pressed() -> void:
	if is_changing:
		return
	_play_click()
	var credits_instance = credits_overlay.instantiate()
	add_child(credits_instance)

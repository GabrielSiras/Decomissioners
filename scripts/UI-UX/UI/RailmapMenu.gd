class_name RailMapMenu
extends Control

@export var click_delay: float = 0.55
@export var random_pitch: bool = true
@onready var metal_click: AudioStreamPlayer = $MetalClick

@onready var start_timer: Timer = $StartTimer

var is_changing: bool = false

func _ready() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _go_to(scene_path: String) -> void:
	if is_changing:
		return
	if not ResourceLoader.exists(scene_path):
		push_warning("RailMapMenu: cena não encontrada: " + scene_path)
		return

	is_changing = true
	_set_buttons_disabled(true)

	if random_pitch:
		metal_click.pitch_scale = randf_range(0.9, 1.1)
	metal_click.play()

	start_timer.one_shot = true
	start_timer.start(click_delay)
	await start_timer.timeout

	get_tree().change_scene_to_file(scene_path)

func _set_buttons_disabled(value: bool) -> void:
	for b in find_children("*", "BaseButton", true, false):
		b.disabled = value

func _on_return_button_pressed() -> void:
	_go_to("res://scenes/UI-UX/UI/MENUs/MainMenu.tscn")

func _on_research_button_pressed() -> void:
	_go_to("res://scenes/UI-UX/UI/MENUs/ResearchMenu.tscn")

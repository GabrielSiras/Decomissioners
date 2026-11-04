class_name WinMenu
extends CanvasLayer

@export var click_delay: float = 0.55
@export var random_pitch: bool = true

@onready var menu_button: Button = $ColorRect/CenterContainer/VBoxContainer/MenuButton
@onready var next_button: Button = $ColorRect/CenterContainer/VBoxContainer/NextButton
@onready var metal_click: AudioStreamPlayer = $MetalClick

var is_changing: bool = false

func _ready() -> void:
	next_button.pressed.connect(_on_next_button_pressed)

	if GameProgress.get_next_level_path(GameProgress.current_level_id).is_empty():
		next_button.text = "Select Level"

func _go_to(scene_path: String) -> void:
	if is_changing:
		return
	if not ResourceLoader.exists(scene_path):
		push_warning("WinMenu: cena não encontrada: " + scene_path)
		return

	is_changing = true
	menu_button.disabled = true
	next_button.disabled = true

	if random_pitch:
		metal_click.pitch_scale = randf_range(0.9, 1.1)
	metal_click.play()

	await get_tree().create_timer(click_delay, true).timeout

	get_tree().paused = false
	get_tree().change_scene_to_file(scene_path)

func _on_next_button_pressed() -> void:
	var path: String = GameProgress.get_next_level_path(GameProgress.current_level_id)
	if path.is_empty():
		path = GameProgress.LEVEL_SELECT_PATH
	_go_to(path)

func _on_menu_button_pressed() -> void:
	_go_to("res://scenes/UI-UX/UI/MENUs/MainMenu.tscn")

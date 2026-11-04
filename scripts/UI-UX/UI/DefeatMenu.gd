class_name DefeatMenu
extends CanvasLayer

@export var click_delay: float = 0.55
@export var random_pitch: bool = true
@export_file("*.tscn") var main_menu_path: String = "res://scenes/UI-UX/UI/MENUs/MainMenu.tscn"

@onready var restart_button: Button = $CenterContainer/VBoxContainer/RestartButton
@onready var main_menu_button: Button = $CenterContainer/VBoxContainer/MainMenuButton
@onready var metal_click: AudioStreamPlayer = $MetalClick

var is_changing: bool = false

func _ready() -> void:
	hide()

	restart_button.pressed.connect(_on_restart_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)

func _play_click_and_wait() -> void:
	is_changing = true
	restart_button.disabled = true
	main_menu_button.disabled = true

	if random_pitch:
		metal_click.pitch_scale = randf_range(0.9, 1.1)
	metal_click.play()

	await get_tree().create_timer(click_delay, true).timeout

func _on_restart_button_pressed() -> void:
	if is_changing:
		return
	await _play_click_and_wait()
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed() -> void:
	if is_changing:
		return
	if not ResourceLoader.exists(main_menu_path):
		push_warning("DefeatMenu: cena não encontrada: " + main_menu_path)
		return
	await _play_click_and_wait()
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu_path)

func show_defeat() -> void:
	_hide_gameplay_ui()
	show()
	get_tree().paused = true

func _hide_gameplay_ui() -> void:
	for n in get_tree().get_nodes_in_group("hide_on_end"):
		if n is CanvasItem or n is CanvasLayer:
			n.visible = false

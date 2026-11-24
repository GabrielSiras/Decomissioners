class_name MainMenu
extends Control

@export var start_button: Button
@export var credits_overlay: PackedScene
@export var click_delay: float = 0.55
@export var random_pitch: bool = true

@onready var metal_click: AudioStreamPlayer = $MetalClick
@onready var start_timer: Timer = $StartTimer
@export var default_level_path: String = "res://scenes/Levels/Level01.tscn"
@export var level_scenes: Dictionary = {
	"level01": "res://scenes/Levels/Level01.tscn",
	"level02": "res://scenes/Levels/Level02.tscn",
	"level03": "res://scenes/Levels/Level03.tscn",
}

var is_changing: bool = false

func _ready() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_refresh_continue_button()

func _refresh_continue_button() -> void:
	var has_cp := CheckpointManager.has_any_checkpoint()
	start_button.text = "CONTINUE" if has_cp else "START"

func _resolve_start_scene() -> String:
	if CheckpointManager.has_any_checkpoint():
		var id: String = String(CheckpointManager.get_level_id())
		if level_scenes.has(id):
			var path: String = String(level_scenes[id])
			if ResourceLoader.exists(path):
				return path
		push_warning("MainMenu: checkpoint aponta para fase desconhecida: " + id)
	return default_level_path

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
	if CheckpointManager.has_any_checkpoint() and Input.is_key_pressed(KEY_SHIFT):
		CheckpointManager.clear()
		_go_to(default_level_path)
		return
	_go_to(_resolve_start_scene())

func _on_research_button_pressed() -> void:
	_go_to("res://scenes/UI-UX/UI/MENUs/ResearchMenu.tscn")

func _on_railmap_button_pressed() -> void:
	_go_to("res://scenes/UI-UX/UI/MENUs/RailmapMenu.tscn")

func _on_level_select_button_pressed() -> void:
	_go_to("res://scenes/UI-UX/UI/MENUs/RailmapMenu.tscn")

func _on_credits_button_pressed() -> void:
	if is_changing:
		return
	_play_click()
	var credits_instance = credits_overlay.instantiate()
	add_child(credits_instance)

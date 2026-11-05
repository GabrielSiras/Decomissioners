class_name RailMapMenu
extends Control

@export var click_delay: float = 0.55
@export var random_pitch: bool = true

@onready var metal_click: AudioStreamPlayer = $MetalClick
@onready var start_timer: Timer = $StartTimer

# Ajuste os caminhos se os botões estiverem dentro de containers
@onready var wastes_button: BaseButton = find_child("WastesButton", true, false)
@onready var junkyard_button: BaseButton = find_child("JunkyardButton", true, false)
@onready var factory_button: BaseButton = find_child("FactoryButton", true, false)

var is_changing: bool = false

func _ready() -> void:
	CheckpointManager.clear()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_apply_locks()

# Bloqueia visualmente as fases ainda não liberadas
func _apply_locks() -> void:
	var map := {
		"level01": wastes_button,
		"level02": junkyard_button,
		"level03": factory_button,
	}
	for id in map:
		var b: BaseButton = map[id]
		if b and not GameProgress.is_unlocked(id):
			b.disabled = true

func _go_to(scene_path: String) -> void:
	if is_changing:
		return
	if scene_path.is_empty() or not ResourceLoader.exists(scene_path):
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

	get_tree().paused = false
	get_tree().change_scene_to_file(scene_path)

func _set_buttons_disabled(value: bool) -> void:
	for b in find_children("*", "BaseButton", true, false):
		b.disabled = value

func _on_return_button_pressed() -> void:
	_go_to("res://scenes/UI-UX/UI/MENUs/MainMenu.tscn")

func _on_research_button_pressed() -> void:
	_go_to("res://scenes/UI-UX/UI/MENUs/ResearchMenu.tscn")

func _on_wastes_button_pressed() -> void:
	_go_to(GameProgress.LEVELS["level01"])

func _on_junkyard_button_pressed() -> void:
	_go_to(GameProgress.LEVELS["level02"])

func _on_factory_button_pressed() -> void:
	_go_to(GameProgress.LEVELS["level03"])

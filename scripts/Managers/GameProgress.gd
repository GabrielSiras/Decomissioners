extends Node

const SAVE_PATH := "user://progress.cfg"

const LEVELS := {
	"tutorial": "res://scenes/Levels/Tutorial.tscn",   # ajuste quando criar o tutorial
	"level01": "res://scenes/Levels/Level01.tscn",
	"level02": "res://scenes/Levels/Level02.tscn",
	"level03": "res://scenes/Levels/Level03.tscn",
}

const ORDER := ["level01", "level02", "level03"]
const ALWAYS_UNLOCKED := ["tutorial", "level01"]
const LEVEL_SELECT_PATH := "res://scenes/UI-UX/UI/MENUs/RailmapMenu.tscn"

var completed: Array = []
var current_level_id: String = ""

func _ready() -> void:
	load_progress()

func is_unlocked(id: String) -> bool:
	if id in ALWAYS_UNLOCKED:
		return true
	var idx := ORDER.find(id)
	if idx <= 0:
		return false
	return completed.has(ORDER[idx - 1])

func complete_level(id: String) -> void:
	if id.is_empty() or completed.has(id):
		return
	completed.append(id)
	save_progress()

func get_next_level_path(id: String) -> String:
	if id == "tutorial":
		return LEVELS["level01"]
	var idx := ORDER.find(id)
	if idx == -1 or idx + 1 >= ORDER.size():
		return ""
	return LEVELS[ORDER[idx + 1]]

func go_to_next_level() -> void:
	get_tree().paused = false
	var path := get_next_level_path(current_level_id)
	if path.is_empty():
		path = LEVEL_SELECT_PATH
	get_tree().change_scene_to_file(path)

func save_progress() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "completed", completed)
	cfg.save(SAVE_PATH)

func load_progress() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		completed = cfg.get_value("progress", "completed", [])

func reset_progress() -> void:
	completed.clear()
	save_progress()

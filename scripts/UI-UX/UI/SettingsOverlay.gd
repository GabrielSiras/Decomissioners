extends CanvasLayer

@export var close_button: Button
@export var exit_box: HBoxContainer

func _ready() -> void:
	close_button.pressed.connect(_on_close_button_pressed)

func _exit_box_visibility() -> void:
	exit_box.visible = true

func _on_close_button_pressed() -> void:
	SettingsOverlay.visible = false
	get_tree().paused = false
	
func _on_exit_button_pressed(button_name: String) -> void:
	_on_close_button_pressed()
	exit_box.visible = false
	match button_name:
		"RailmapButton":
			get_tree().change_scene_to_file("res://scenes/UI-UX/UI/MENUs/RailmapMenu.tscn")
		"QuitButton":
			get_tree().change_scene_to_file("res://scenes/UI-UX/UI/MENUs/MainMenu.tscn")
	
